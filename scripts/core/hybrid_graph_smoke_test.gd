extends Node

const GENERATOR := preload("res://scripts/world/hybrid_dungeon_generator.gd")
var failures: Array[String] = []

func _ready() -> void:
    for config_path in ["res://data/dungeons/first_accord_hybrid_config.json", "res://data/dungeons/voices_under_sanctuary_hybrid_config.json"]:
        var config: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(config_path))
        for seed_value in 100:
            var state := {"campaign_seed": seed_value, "visit_index": 2}
            var graph := GENERATOR.generate_graph(config, state)
            _check(bool(graph.get("ok", false)), "%s seed %d must generate" % [config_path, seed_value])
            if not bool(graph.get("ok", false)):
                continue
            _check(graph == GENERATOR.generate_graph(config, state), "Same seed must reproduce the complete graph")
            _check(str(graph["entry_id"]) == str(config["protected_story_order"].front()), "Authored entry must be the real graph entry")
            _check(str(graph["objective_id"]) == str(config["protected_story_order"].back()), "Authored finale must be the real objective")
            for room_id in config["mandatory_room_ids"]:
                var broken := graph.duplicate(true)
                var kept_edges: Array = []
                for edge in broken["edges"]:
                    if str(edge["from"]) != str(room_id) and str(edge["to"]) != str(room_id):
                        kept_edges.append(edge)
                broken["edges"] = kept_edges
                _check(not bool(GENERATOR.validate_graph(broken, config)["ok"]), "Disconnected mandatory room must fail: " + str(room_id))
            var dangling := graph.duplicate(true)
            dangling["edges"].append({"from": str(graph["entry_id"]), "to": "missing_room"})
            _check(not bool(GENERATOR.validate_graph(dangling, config)["ok"]), "Dangling edge must fail")
            var duplicate := graph.duplicate(true)
            duplicate["nodes"].append(duplicate["nodes"][0].duplicate(true))
            _check(not bool(GENERATOR.validate_graph(duplicate, config)["ok"]), "Duplicate ID must fail")
            var no_retreat := graph.duplicate(true)
            for node in no_retreat["nodes"]:
                node["retreat"] = false
            _check(not bool(GENERATOR.validate_graph(no_retreat, config)["ok"]), "Stale retreat_count must not satisfy validation")
    if failures.is_empty():
        print("HYBRID_GRAPH_SMOKE_OK: 200 seeded graphs and invalid graph regressions")
        get_tree().quit(0)
    else:
        for failure in failures:
            push_error(failure)
        get_tree().quit(1)

func _check(condition: bool, message: String) -> void:
    if not condition:
        failures.append(message)
