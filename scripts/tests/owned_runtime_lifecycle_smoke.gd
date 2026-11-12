extends Node

const RUNTIMES := [
    preload("res://scripts/core/veilleurs_tactical_combat_runtime.gd"),
    preload("res://scripts/core/veilleurs_tactical_combat_runtime_v2.gd"),
    preload("res://scripts/core/veilleurs_tactical_combat_runtime_v07.gd"),
    preload("res://scripts/core/veilleurs_combat_runtime.gd"),
    preload("res://scripts/core/veilleurs_campaign_runtime_v07.gd"),
    preload("res://scripts/core/veilleurs_hybrid_generation_bridge.gd")
]
const MAIN := preload("res://scripts/ui/main_v47.gd")
var failures: Array[String] = []

func _ready() -> void:
    call_deferred("run")

func run() -> void:
    for runtime_script: Script in RUNTIMES:
        for iteration in range(3):
            var before := Node.get_orphan_node_ids()
            var runtime: RefCounted = runtime_script.new()
            var database: Node = runtime.get("content_db")
            var database_id := database.get_instance_id()
            _check(not database.get("watchers_by_id").is_empty(), "Owned catalog must remain usable while runtime is alive")
            runtime = null
            _check(not is_instance_id_valid(database_id), "Catalog must be freed with its owner: %s" % runtime_script.resource_path)
            _check_no_new_orphans(before, runtime_script.resource_path)
    for iteration in range(3):
        var before := Node.get_orphan_node_ids()
        var main: Node = MAIN.new()
        var positions: Node = main.get("_combat_position_runtime_v47")
        var positions_id := positions.get_instance_id()
        _check(int(positions.call("position_of", {"combat_position": 2})) == 2, "Position helper must remain usable while Main is alive")
        main.free()
        _check(not is_instance_id_valid(positions_id), "Position helper must be freed with Main")
        _check_no_new_orphans(before, "Main")
    if failures.is_empty():
        print("OWNED_RUNTIME_LIFECYCLE_SMOKE_OK: 21 create/destroy cycles")
    else:
        for failure in failures:
            push_error(failure)
    get_tree().quit(0 if failures.is_empty() else 1)

func _check_no_new_orphans(before: Array[int], context: String) -> void:
    for orphan_id in Node.get_orphan_node_ids():
        _check(before.has(orphan_id), "Creation/destruction left a new orphan in %s" % context)

func _check(condition: bool, message: String) -> void:
    if not condition:
        failures.append(message)
