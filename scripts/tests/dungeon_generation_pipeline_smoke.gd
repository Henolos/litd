extends Node

const SEEDS := preload("res://scripts/world/dungeon_run_seed.gd")
const PLANNER := preload("res://scripts/world/first_accord_hybrid_planner.gd")
const ENCOUNTERS := preload("res://scripts/world/first_accord_encounter_planner.gd")
var failures: Array[String] = []

func _ready() -> void:
    var config: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(PLANNER.CONFIG_PATH))
    var catalog: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(PLANNER.ENCOUNTERS_PATH))
    var library: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(PLANNER.MODULES_PATH))
    var secret_pools := {}
    var resource_pools := {}
    for seed_value in 1000:
        var state := {"campaign_seed": seed_value, "visit_index": seed_value % 7}
        var plan := PLANNER.build_plan(state)
        _check(bool(plan.get("ok", false)) and not bool(plan.get("fallback", false)), "Generated plan must resolve all modules: %d" % seed_value)
        if bool(plan.get("fallback", false)) or not bool(plan.get("ok", false)):
            continue
        _check(plan == PLANNER.build_plan(state), "Complete plan must reproduce exactly")
        var report: Dictionary = plan.get("generation_report", {})
        _check(int(report.get("room_count", 0)) == plan["nodes"].size(), "Report must count final rooms")
        _check(bool(report.get("validation", {}).get("ok", false)), "Report must contain final validation")
        var populated := ENCOUNTERS.populate(plan, catalog, library)
        _check(populated == ENCOUNTERS.populate(plan, catalog, library), "Encounter plans reproduce exactly")
        _check(bool(populated["encounter_report"]["ok"]), "Critical encounter quota must hold")
        _check(populated["edges"] == plan["edges"], "Population must preserve topology")
        var reversed := plan.duplicate(true)
        reversed["nodes"].reverse()
        reversed = ENCOUNTERS.populate(reversed, catalog, library)
        for room in populated["nodes"]:
            for other in reversed["nodes"]:
                if room["id"] == other["id"]:
                    _check(room["encounter_plan"] == other["encounter_plan"], "Encounter selection independent of room order")
            if room["role"] == "boss":
                _check(room["encounter_plan"]["id"] == catalog["boss"]["encounter_id"], "Authored boss remains fixed")
            if room["role"] in ["entry", "secret"]:
                _check(room["encounter_plan"].is_empty(), "Safe roles remain unpopulated")
        var relief := ENCOUNTERS.populate(plan, catalog, library, {"injury_pressure": 0.8})
        _check(bool(relief["encounter_report"]["relief_active"]), "Party pressure enables relief")
        _check(bool(relief["encounter_report"]["ok"]), "Relief preserves critical quota")
        var root_seed := int(plan.get("seed", 0))
        _check(int(plan["stage_seeds"]["layout"]) == root_seed, "Layout seed must preserve historical contract")
        var layout_rng := SEEDS.generator(root_seed, "layout")
        _check(layout_rng.seed == root_seed, "Layout RNG must use the historical seed")
        var layout_control := SEEDS.generator(root_seed, "layout")
        var encounter_rng := SEEDS.generator(root_seed, "encounter")
        for i in 50:
            encounter_rng.randi()
        _check(layout_rng.randi() == layout_control.randi(), "Encounter draws must not change layout stream")
        var distinct := {}
        for stream in SEEDS.STREAMS:
            distinct[plan["stage_seeds"][stream]] = true
        _check(distinct.size() == SEEDS.STREAMS.size(), "Named stage seeds must be distinct")
        for node in plan["nodes"]:
            _check(int(node["encounter_seed"]) == SEEDS.derive(root_seed, "encounter", str(node["id"])), "Room encounter seed must be scoped to stable ID")
            if str(node["role"]) == "secret":
                secret_pools[str(node["module_pool"])] = true
        # Exercise a role eligible for multiple pools, independently of layout.
        var pool := PLANNER._optional_pool_for_role(config, "resource", SEEDS.generator(root_seed, "room", "test-resource"))
        resource_pools[pool] = true
        var broken := plan.duplicate(true)
        broken["nodes"].back()["module_id"] = "unknown_module"
        _check(not bool(PLANNER.validate_plan(broken)["ok"]), "Unknown optional module must fail validation")
        broken = plan.duplicate(true)
        broken["nodes"].back()["module_id"] = "accord_entry_vestibule_v1"
        _check(not bool(PLANNER.validate_plan(broken)["ok"]), "Known module from wrong pool must fail")
    var anchor := {"anchor_id": "test", "capacity": 2, "formation_tags": ["frontline"]}
    _check(ENCOUNTERS._compatible_anchor({"enemy_count": 3}, [anchor]).is_empty(), "Oversized compositions rejected")
    _check(ENCOUNTERS._compatible_anchor({"enemy_count": 2, "formation_tags": ["ranged"]}, [anchor]).is_empty(), "Unsupported formations rejected")
    _check(not ENCOUNTERS._compatible_anchor({"enemy_count": 2, "formation_tags": ["frontline"]}, [anchor]).is_empty(), "Compatible compositions accepted")
    var impossible := catalog.duplicate(true)
    impossible["director_rules"]["critical_path_min_encounters"] = 99
    _check(not bool(ENCOUNTERS.populate(PLANNER.build_plan(), impossible, library)["encounter_report"]["ok"]), "Impossible quota fails explicitly")
    _check(secret_pools.size() == 2, "Both authored secret pools must be reachable")
    _check(resource_pools.size() == 3, "All eligible resource pools must be reachable")
    var disabled_config := config.duplicate(true)
    for pool in disabled_config["optional_room_pools"]:
        pool["weight"] = 0
    _check(PLANNER._optional_pool_for_role(disabled_config, "resource", SEEDS.generator(42, "room")).is_empty(), "Disabled compatible pools must not use implicit fallback")
    var weighted := [{"id":"disabled", "weight":0}, {"id":"light", "weight":1}, {"id":"heavy", "weight":9}]
    var rng := SEEDS.generator(42, "room", "weights")
    var heavy := 0
    for i in 10000:
        var selected := PLANNER._weighted_pick(weighted, rng)
        _check(str(selected.get("id", "")) != "disabled", "Zero weight must never be selected")
        heavy += 1 if str(selected.get("id", "")) == "heavy" else 0
    _check(heavy > 8500 and heavy < 9500, "Weights must influence distribution")
    _check(PLANNER._weighted_pick([{"weight":0}, {"weight":-1}], rng).is_empty(), "No positive weight means no candidate")
    if failures.is_empty():
        print("DUNGEON_GENERATION_PIPELINE_OK: 1000 plans, isolated streams, weighted pools, encounter quotas, capacity, room-order isolation, invalid data")
        get_tree().quit(0)
    else:
        for failure in failures:
            push_error(failure)
        get_tree().quit(1)

func _check(condition: bool, message: String) -> void:
    if not condition:
        failures.append(message)
