extends Node

const LIBRARY_PATH := "res://data/dungeons/first_accord_module_library.json"
const BUILDER := preload("res://scripts/world/first_accord_dungeon_map_builder.gd")
const RUNTIME := preload("res://scripts/world/first_accord_hybrid_runtime_plan.gd")
const WORLD_SCENE := preload("res://scenes/dungeons/first_accord_playable_blockout.tscn")

func _ready() -> void:
    call_deferred("_test")

func _test() -> void:
    var catalog: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(LIBRARY_PATH))
    var count := 0
    for module in catalog.get("modules", []):
        var id := str(module.get("module_id", ""))
        var room: Node3D = BUILDER.instantiate_module(id)
        if room == null:
            _fail("module cannot be instantiated: " + id)
            return
        add_child(room)
        if str(room.get_meta("module_id", "")) != id:
            _fail("wrong physical module ID: " + id)
            return
        if room.get_node_or_null("Floor") == null and room.get_node_or_null("Floor/Visual") == null:
            _fail("missing walkable floor: " + id)
            return
        var connectors := room.get_node_or_null("Connectors")
        if connectors == null:
            _fail("missing physical connectors: " + id)
            return
        for connector in module.get("connectors", []):
            if connectors.get_node_or_null(str(connector.get("id", ""))) == null:
                _fail("missing physical connector: " + id)
                return
        if id != "accord_entry_vestibule_v1":
            for category in ["scar", "encounter", "resource", "lore"]:
                var anchors := room.get_node_or_null(category.capitalize() + "Anchors")
                if anchors == null or anchors.get_child_count() != module.get(category + "_anchors", []).size():
                    _fail("missing physical anchors: " + id + ":" + category)
                    return
        count += 1
        room.queue_free()
    if BUILDER.instantiate_module("unknown_module") != null:
        _fail("unknown modules must not instantiate")
        return
    var physical_root := Node3D.new()
    add_child(physical_root)
    for seed_value in [1, 7, 42, 1337, 9001]:
        var plan := RUNTIME.build({"campaign_seed":seed_value})
        if not bool(plan.get("ok", false)) or bool(plan.get("fallback", false)):
            _fail("valid runtime plan required: %d" % seed_value)
            return
        var assembled := BUILDER.generate_from_plan(physical_root, plan)
        if not bool(assembled.get("ok", false)) or int(assembled.get("room_count", 0)) != plan.get("nodes", []).size():
            _fail("every generated room must be physical: %d" % seed_value)
            return
        var expected_connections := 0
        for edge in plan.get("edges", []):
            if not bool(edge.get("hidden", false)) and str(edge.get("requires", "")) == "":
                expected_connections += 1
        if int(assembled.get("open_connection_count", 0)) != expected_connections:
            _fail("physical edges must follow open plan edges")
            return
        (assembled["root"] as Node).queue_free()
    physical_root.queue_free()
    var world := WORLD_SCENE.instantiate() as Node3D
    add_child(world)
    var physical: Dictionary = world.get("physical")
    if not bool(physical.get("ok", false)) or world.get("party") == null or world.get("current_room_id") != "vestibule":
        _fail("prototype exploration must load at the physical vestibule")
        return
    world.queue_free()
    print("FIRST_ACCORD_MODULE_BLOCKOUT_OK modules=%d" % count)
    get_tree().quit(0)

func _fail(message: String) -> void:
    push_error(message)
    get_tree().quit(1)
