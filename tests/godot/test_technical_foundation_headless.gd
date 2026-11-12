extends SceneTree

# Loading in the real project context resolves the retained technical autoloads.
const TECHNICAL_SCRIPTS := [
    "res://scripts/core/data_loader.gd",
    "res://scripts/core/game_settings.gd",
    "res://scripts/core/music_library.gd",
    "res://scripts/core/prototype_audio_bank.gd",
    "res://scripts/core/save_manager.gd",
    "res://scripts/core/sfx_library.gd",
    "res://scripts/core/sfx_runtime.gd",
    "res://scripts/visual/canonical_art_registry.gd",
    "res://scripts/visual/validated_glb_loader.gd",
    "res://scripts/world/dungeon_event_director.gd",
    "res://scripts/world/dungeon_profile.gd",
    "res://scripts/world/dungeon_room_resolver.gd",
    "res://scripts/world/dungeon_run_seed.gd",
    "res://scripts/world/hybrid_dungeon_generator.gd",
    "res://scripts/world/isometric_camera_rig.gd",
    "res://scripts/world/isometric_occludable.gd",
    "res://scripts/world/isometric_occlusion_manager.gd",
]
const FLOW := preload("res://scripts/world/hybrid_dungeon_generator.gd")
var failures := 0

func _initialize() -> void:
    call_deferred("_run")

func _check(ok: bool, message: String) -> void:
    if not ok:
        failures += 1
        push_error(message)

func _run() -> void:
    for path: String in TECHNICAL_SCRIPTS:
        var script: Script = load(path)
        _check(script != null and script.can_instantiate(), "Retained script must compile: " + path)
    var config: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/dungeons/first_accord_hybrid_config.json"))
    config["mandatory_room_ids"] = config.get("protected_story_order", [])
    for seed_value in 100:
        var state := {"campaign_seed": seed_value, "visit_index": seed_value % 7}
        var first := FLOW.generate_graph(config, state)
        _check(bool(first.get("ok", false)), "Technical graph generation: %d" % seed_value)
        _check(first == FLOW.generate_graph(config, state), "Deterministic graph: %d" % seed_value)
    if failures == 0:
        print("TECHNICAL_FOUNDATION_OK scripts=%d seeds=100" % TECHNICAL_SCRIPTS.size())
    quit(1 if failures else 0)
