extends Node

const PLANNER := preload("res://scripts/world/first_accord_hybrid_planner.gd")
const DIRECTOR := preload("res://scripts/core/veilleurs_encounter_director.gd")
const RUNTIME_PLAN := preload("res://scripts/world/first_accord_hybrid_runtime_plan.gd")
const SESSION := preload("res://scripts/core/veilleurs_tactical_session_v2.gd")
var failures: Array[String] = []

func _ready() -> void:
    var library := PLANNER._load_json(PLANNER.MODULES_PATH)
    var tables := PLANNER._load_json(PLANNER.ENCOUNTERS_PATH)
    var varied := {}
    var optional_seen := 0
    for seed_value in 1000:
        var plan := PLANNER.build_plan({"campaign_seed":seed_value, "visit_index":seed_value % 7})
        var before := plan.duplicate(true)
        var populated := DIRECTOR.populate_dungeon_plan(plan, library, tables)
        _check(bool(populated.get("ok", false)), "Population must succeed: %d" % seed_value)
        _check(plan == before, "Director must not mutate source plan")
        _check(populated == DIRECTOR.populate_dungeon_plan(plan, library, tables), "Complete encounter plan must reproduce")
        _check(populated["edges"] == plan["edges"], "Population must preserve every edge")
        var signature := ""
        for node in populated.get("nodes", []):
            var encounter: Dictionary = node.get("encounter", {})
            var source := _node(plan, str(node["id"]))
            _check(node["module_id"] == source["module_id"] and node["variation_seed"] == source["variation_seed"], "Population must preserve rooms/variations")
            if str(node["role"]) in ["entry", "rest", "secret", "exit"]:
                _check(encounter.is_empty(), "Safe roles must have no encounter")
            if encounter.is_empty():
                continue
            signature += str(node["id"]) + ":" + str(encounter["id"]) + "|"
            if bool(encounter.get("fixed_boss", false)):
                _check(str(encounter["materialization_status"]) == "definition_only", "Authored boss stays on its existing route")
            elif float(encounter.get("threat", 0)) > 0:
                _check(str(encounter["materialization_status"]) == "composition_ready", "Normal encounters need resolved compositions")
                _check((encounter.get("composition", []) as Array).size() == int(encounter["enemy_count"]), "Composition respects reserved ranks")
            else:
                _check(str(encounter["materialization_status"]) == "definition_only", "Empty rooms have no combat")
            if float(encounter["threat"]) > 0:
                _check(int(encounter["enemy_count"]) <= int(encounter["capacity"]) and int(encounter["enemy_count"]) <= 4, "Slots must respect physical capacity and R1-R4")
                _check(str(encounter["anchor_id"]) != "", "Combat reservation must resolve an anchor")
                if bool(encounter["fixed_boss"]):
                    _check(str(encounter["id"]) == str(tables["boss"]["encounter_id"]) and float(encounter["threat"]) == 7, "Boss must remain authored")
                else:
                    var budget: Array = encounter["budget"]
                    _check(float(encounter["threat"]) >= float(budget[0]) and float(encounter["threat"]) <= float(budget[1]), "Normal encounter must fit depth budget")
        varied[signature] = true
        var report: Dictionary = populated["encounter_report"]
        _check(int(report["critical_count"]) == 5, "Four protected encounters plus authored boss must persist")
        optional_seen += int(report["optional_count"])
    _check(varied.size() > 10 and optional_seen > 0, "Seeds must produce encounter variety and optional reservations")
    var plan := PLANNER.build_plan({"campaign_seed":42})
    var relief := DIRECTOR.populate_dungeon_plan(plan, library, tables, {"injury_pressure":0.9})
    _check(bool(relief["ok"]) and int(relief["encounter_report"]["optional_count"]) == 0 and int(relief["encounter_report"]["critical_count"]) == 5, "Injury relief only suppresses optional encounters")
    var supplies := DIRECTOR.populate_dungeon_plan(plan, library, tables, {"supplies_ratio":0.1, "blocked_encounter_ids":[tables["boss"]["encounter_id"]]})
    _check(bool(supplies["ok"]) and int(supplies["encounter_report"]["optional_count"]) == 0, "Low supplies cannot remove fixed boss")
    var reordered := tables.duplicate(true)
    for candidates in reordered["room_tables"].values():
        candidates.reverse()
    _check(DIRECTOR.populate_dungeon_plan(plan, library, tables) == DIRECTOR.populate_dungeon_plan(plan, library, reordered), "Table order must not change selection or report")
    var blocked := tables.duplicate(true)
    for candidate in blocked["room_tables"]["accord_gallery"]:
        candidate["enemy_count"] = 99
    _check(not bool(DIRECTOR.populate_dungeon_plan(plan, library, blocked)["ok"]), "Impossible required capacity must fail")
    blocked = tables.duplicate(true)
    for candidate in blocked["room_tables"]["accord_gallery"]:
        candidate["required_formation_tags"] = ["impossible_formation"]
    _check(not bool(DIRECTOR.populate_dungeon_plan(plan, library, blocked)["ok"]), "Unsupported required formation must fail")
    blocked = tables.duplicate(true)
    for candidate in blocked["room_tables"]["accord_gallery"]:
        candidate["weight"] = 0
    _check(not bool(DIRECTOR.populate_dungeon_plan(plan, library, blocked)["ok"]), "Disabled critical table must fail")
    blocked = tables.duplicate(true)
    for candidate in blocked["room_tables"]["accord_gallery"]:
        candidate["enemy_ids"] = ["ENT_ENEMY_NOT_IN_CATALOG", "ENT_ENEMY_NOT_IN_CATALOG"]
    _check(not bool(DIRECTOR.populate_dungeon_plan(plan, library, blocked)["ok"]), "Unknown canonical enemies must fail closed")
    blocked = tables.duplicate(true)
    for candidate in blocked["room_tables"]["accord_gallery"]:
        candidate["enemy_ids"] = []
    _check(not bool(DIRECTOR.populate_dungeon_plan(plan, library, blocked)["ok"]), "Incomplete compositions must fail closed")
    blocked = tables.duplicate(true)
    blocked["boss"]["enemy_count"] = 2
    _check(not bool(DIRECTOR.populate_dungeon_plan(plan, library, blocked)["ok"]), "Boss must fit authored one-slot anchor")
    var unknown := plan.duplicate(true)
    unknown["nodes"][0]["module_id"] = "unknown"
    _check(not bool(DIRECTOR.populate_dungeon_plan(unknown, library, tables)["ok"]), "Unknown module must fail closed")
    var weighted := [{"id":"light", "weight":1.0}, {"id":"heavy", "weight":9.0}]
    var heavy := 0
    for seed_value in 10000:
        var selected := DIRECTOR._pick_room_encounter(weighted, {"encounter_seed":seed_value})
        heavy += 1 if str(selected["id"]) == "heavy" else 0
    _check(heavy > 8500 and heavy < 9500, "Encounter weights must affect distribution")
    var decorated := plan.duplicate(true)
    decorated["remanence"] = {"applied":[{"anchor_id":"test", "type":"old_blood"}]}
    _node(decorated, "debate_chamber")["environment_tags"] = ["nemesis_presence"]
    var with_scars := DIRECTOR.populate_dungeon_plan(decorated, library, tables)
    _check(with_scars["remanence"] == decorated["remanence"] and _node(with_scars, "debate_chamber")["environment_tags"] == ["nemesis_presence"], "Population must preserve Remanence decorations")
    var failed_runtime := RUNTIME_PLAN.build({"campaign_seed":42, "blocked_encounter_ids":["accord_scavengers_01", "accord_watchers_names"]})
    _check(bool(failed_runtime.get("fallback", false)) and str(failed_runtime.get("fallback_reason", "")) == "encounter_population_failed", "Runtime must fall back when a required encounter cannot resolve")
    _check(not bool(failed_runtime.get("encounter_report", {}).get("ok", true)), "Fallback must retain failed encounter evidence")
    var runtime_plan := RUNTIME_PLAN.build({"campaign_seed":42})
    _check(bool(runtime_plan.get("ok", false)) and not bool(runtime_plan.get("fallback", false)) and runtime_plan.has("encounter_report"), "Runtime must invoke encounter stage after Remanence")
    for node in runtime_plan.get("nodes", []):
        var encounter: Dictionary = node.get("encounter", {})
        if str(encounter.get("materialization_status", "")) != "composition_ready":
            continue
        var session := SESSION.new() as VeilleursTacticalSessionV2
        var started := session.start_authored_encounter(encounter, "first_accord:%s" % node.get("id", ""), "first_accord")
        _check(bool(started.get("ok", false)) and (started.get("enemies", []) as Array).size() == int(encounter.get("enemy_count", 0)), "Real tactical runtime must accept every selected composition")
    var fallback := {"ok":true, "fallback":true, "fallback_reason":"test"}
    _check(DIRECTOR.populate_dungeon_plan(fallback, library, tables) == fallback, "Authored fallback must remain untouched")
    if failures.is_empty():
        print("DUNGEON_ENCOUNTER_PIPELINE_OK: 1000 plans, constraints, deterministic weights, runtime integration")
        get_tree().quit(0)
    else:
        for failure in failures:
            push_error(failure)
        get_tree().quit(1)

func _node(plan: Dictionary, id_value: String) -> Dictionary:
    for node in plan["nodes"]:
        if str(node["id"]) == id_value:
            return node
    return {}

func _check(condition: bool, message: String) -> void:
    if not condition:
        failures.append(message)
