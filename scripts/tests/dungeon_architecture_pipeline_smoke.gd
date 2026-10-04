extends Node

const RUNTIME := preload("res://scripts/world/first_accord_hybrid_runtime_plan.gd")
const PLANNER := preload("res://scripts/world/first_accord_hybrid_planner.gd")
const PROFILE := preload("res://scripts/world/dungeon_profile.gd")
const ROOMS := preload("res://scripts/world/dungeon_room_resolver.gd")
const EVENTS := preload("res://scripts/world/dungeon_event_director.gd")
const FLOW := preload("res://scripts/world/hybrid_dungeon_generator.gd")
var failures: Array[String] = []

func _ready() -> void:
    var config := PLANNER._load_json(PLANNER.CONFIG_PATH)
    var library := PLANNER._load_json(PLANNER.MODULES_PATH)
    var rules := PLANNER._load_json(FLOW.RULES_PATH)
    var variants := {}
    for seed_value in 1000:
        var state := {"campaign_seed":seed_value, "visit_index":seed_value % 11, "difficulty_band":"hard" if seed_value % 2 else "normal", "story_epoch":seed_value % 3}
        var plan := RUNTIME.build(state)
        _check(bool(plan.get("ok", false)) and not bool(plan.get("fallback", false)), "Final pipeline must succeed: %d" % seed_value)
        if bool(plan.get("fallback", false)) or not bool(plan.get("ok", false)):
            continue
        _check(plan == RUNTIME.build(state), "All stages and reports must replay exactly")
        _check(bool(RUNTIME.validate_final(plan, state)["ok"]), "Independent final validation must pass")
        _check(plan["generation_report"]["stages"] == ["seed", "dungeon_profile", "flow_generator", "critical_path_validation", "room_resolver", "remanence", "encounter_director", "encounter_composition", "event_director", "final_validation"], "Stage order must be explicit")
        _check(plan["nodes"].size() >= 13 and plan["nodes"].size() <= 19, "Final profile room bounds must hold after rebuilding")
        _check(int(plan["generation_report"]["loop_count"]) >= 1 and int(plan["generation_report"]["loop_count"]) <= 2, "Final loop range must hold")
        _check(plan["generation_report"]["run_state"] == state and plan["generation_report"]["data_revisions"].size() == 9, "Replay must record input and catalogue revisions")
        var before := plan.duplicate(true)
        var changed_order := library.duplicate(true)
        changed_order["modules"].reverse()
        for module in changed_order["modules"]:
            module["variation_slots"].reverse()
            for slot in module["variation_slots"]:
                slot["allowed_variants"].reverse()
        _check(EVENTS.populate(plan, library) == EVENTS.populate(plan, changed_order), "Catalogue/slot/variant order must not change events")
        var resolved := plan.duplicate(true)
        ROOMS._assign_modules(resolved, config, changed_order)
        _check(resolved == plan, "Catalogue order must not change room resolution")
        _check(before == plan, "Stages must not mutate their input")
        variants[str(plan["nodes"][0]["room_events"])] = true
    _check(variants.size() > 1, "Seeds must vary authored events")
    var plan := RUNTIME.build({"campaign_seed":42})
    _check(RUNTIME.replay(plan["generation_report"]) == plan, "Stored report must reconstruct the complete plan with the same campaign")
    var stale_report: Dictionary = plan["generation_report"].duplicate(true)
    stale_report["data_revisions"][PLANNER.CONFIG_PATH] = "old_revision"
    _check(not bool(RUNTIME.replay(stale_report)["ok"]), "Replay must refuse changed data")
    stale_report = plan["generation_report"].duplicate(true)
    stale_report["world_state_revision"] = "different_campaign"
    _check(not bool(RUNTIME.replay(stale_report)["ok"]), "Replay must refuse changed campaign state")
    var broken := plan.duplicate(true)
    broken["nodes"].append(broken["nodes"][0].duplicate(true))
    _check(not bool(RUNTIME.validate_final(broken)["ok"]), "Duplicate room must fail final validation")
    broken = plan.duplicate(true)
    broken["edges"].append({"from":"vestibule", "to":"missing", "kind":"loop"})
    _check(not bool(RUNTIME.validate_final(broken)["ok"]), "Dangling connection must fail")
    broken = plan.duplicate(true)
    broken["edges"][0]["requires"] = "unobtainable_key"
    _check(not bool(RUNTIME.validate_final(broken)["ok"]), "Impossible required lock must fail")
    broken = plan.duplicate(true)
    broken["nodes"][0]["room_events"][0]["variant"] = "unknown_variant"
    _check(not bool(RUNTIME.validate_final(broken)["ok"]), "Unknown event must fail")
    broken = plan.duplicate(true)
    broken["nodes"][0]["resource_reservations"] = [{"anchor_id":"invented_reward"}]
    _check(not bool(RUNTIME.validate_final(broken)["ok"]), "Reward slots must come from existing library")
    broken = plan.duplicate(true)
    broken["nodes"][1]["encounter"]["enemy_count"] = 5
    _check(not bool(RUNTIME.validate_final(broken)["ok"]), "Final selection must respect authored composition and R1-R4")
    broken = plan.duplicate(true)
    broken["nodes"][0]["encounter"] = broken["nodes"][1]["encounter"].duplicate(true)
    _check(not bool(RUNTIME.validate_final(broken)["ok"]), "Entry remains safe")
    broken = plan.duplicate(true)
    var kept_edges: Array = []
    for edge in broken["edges"]:
        if str(edge.get("kind", "")) != "retreat_shortcut":
            kept_edges.append(edge)
    broken["edges"] = kept_edges
    _check(not bool(RUNTIME.validate_final(broken)["ok"]), "Deep physical retreat must not disappear behind stale flags")
    broken = plan.duplicate(true)
    broken["nodes"][0]["event_seed"] = 1234
    _check(not bool(RUNTIME.validate_final(broken)["ok"]), "Room streams must remain derived from root seed and stable ID")
    var disabled := library.duplicate(true)
    disabled["modules"][0]["biome_tags"] = ["unrelated_biome"]
    _check(not bool(PLANNER.validate_plan(plan, config, disabled)["ok"]), "Wrong biome module must fail")
    var bad_config := config.duplicate(true)
    bad_config["loop_target"] = [3, 1]
    _check(not bool(PROFILE.resolve(bad_config, rules)["ok"]), "Inverted ranges must fail before RNG")
    _check(not bool(FLOW.generate_graph(bad_config)["ok"]), "Invalid profile must not enter retries")
    bad_config = config.duplicate(true)
    bad_config["secret_target"] = [1]
    _check(not bool(PROFILE.resolve(bad_config, rules)["ok"]), "Malformed ranges must fail")
    bad_config = config.duplicate(true)
    bad_config["profile"] = "unknown"
    _check(not bool(PROFILE.resolve(bad_config, rules)["ok"]), "Unknown profile must fail")
    var overrides := PROFILE.resolve(config, rules)
    _check(overrides["profile"]["critical_length"] == [6,6], "Protected authored spine must override generic length")
    if failures.is_empty():
        print("DUNGEON_ARCHITECTURE_PIPELINE_OK: 1000 full replays, profile bounds, events, corrupt-plan rejection")
        get_tree().quit(0)
    else:
        for failure in failures.slice(0, 30):
            push_error(failure)
        print("DUNGEON_ARCHITECTURE_PIPELINE_FAILED: %d" % failures.size())
        get_tree().quit(1)

func _check(condition: bool, message: String) -> void:
    if not condition:
        failures.append(message)
