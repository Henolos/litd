extends RefCounted
class_name FirstAccordHybridRuntimePlan

const EVENT_DIRECTOR := preload("res://scripts/world/dungeon_event_director.gd")

const ENCOUNTER_DIRECTOR := preload("res://scripts/core/veilleurs_encounter_director.gd")
const COMPOSITION_RESOLVER := preload("res://scripts/core/veilleurs_encounter_composition_resolver.gd")

const PLANNER := preload("res://scripts/world/first_accord_hybrid_planner.gd")

const ROLE_FALLBACKS := {
    "transit": "accord_guardroom_v1",
    "combat": "accord_guardroom_v1",
    "resource": "accord_memory_vault_v1",
    "narrative": "accord_memory_vault_v1",
    "hazard": "accord_collapsed_passage_v1",
    "choice": "accord_debate_chamber_v1",
    "elite": "accord_three_pillars_v1",
    "secret": "accord_sealed_archive_v1",
    "entry": "accord_entry_vestibule_v1",
    "boss": "accord_warden_sanctum_boss_v1"
}

static func build(run_state: Dictionary = {}) -> Dictionary:
    var plan := PLANNER.build_plan(run_state)
    if not bool(plan.get("ok", false)) or bool(plan.get("fallback", false)):
        return plan

    plan["generation_report"]["world_state_revision"] = _world_state_revision()
    for path in ["res://data/remanence_rules.json", "res://data/remanence_world_rules.json", COMPOSITION_RESOLVER.ENEMIES_PATH, COMPOSITION_RESOLVER.TREE_PATH]:
        plan["generation_report"]["data_revisions"][path] = FileAccess.get_file_as_string(path).sha256_text()
    plan = HybridDungeonGenerator.apply_remanence(plan, _active_world_scars())
    if RemanenceCombatBridge.world_director != null and RemanenceCombatBridge.world_director.has_method("decorate_plan"):
        plan = RemanenceCombatBridge.world_director.call("decorate_plan", plan)

    var unresolved: Array[String] = []
    for node in plan.get("nodes", []):
        if str(node.get("module_id", "")) != "":
            continue
        var role := str(node.get("role", "transit"))
        var fallback_id := str(ROLE_FALLBACKS.get(role, "accord_guardroom_v1"))
        node["module_id"] = fallback_id
        node["module_fallback"] = true
        unresolved.append(str(node.get("id", "")))

    plan["module_fallback_nodes"] = unresolved
    plan["production_warning"] = "temporary_role_fallback_modules" if not unresolved.is_empty() else ""
    plan["all_nodes_have_modules"] = _all_nodes_have_modules(plan.get("nodes", []))
    if not bool(plan["all_nodes_have_modules"]):
        return {
            "ok": true,
            "fallback": true,
            "fallback_reason": "unresolved_module_after_runtime_resolution",
            "fallback_authored_map": plan.get("fallback_authored_map", "")
        }
    var final_validation := PLANNER.validate_plan(plan)
    if not bool(final_validation.get("ok", false)):
        return PLANNER._fallback_plan(PLANNER._load_json(PLANNER.CONFIG_PATH), "post_remanence_validation_failed", final_validation)
    plan["validation"] = final_validation
    plan["generation_report"]["validation"] = final_validation
    plan = ENCOUNTER_DIRECTOR.populate_dungeon_plan(plan, PLANNER._load_json(PLANNER.MODULES_PATH), PLANNER._load_json(PLANNER.ENCOUNTERS_PATH), run_state)
    if not bool(plan.get("ok", false)):
        var fallback := PLANNER._fallback_plan(PLANNER._load_json(PLANNER.CONFIG_PATH), "encounter_population_failed", plan.get("encounter_report", {}))
        fallback["encounter_report"] = plan.get("encounter_report", {}).duplicate(true)
        return fallback
    plan = COMPOSITION_RESOLVER.resolve_plan(plan)
    if not bool(plan.get("ok", false)):
        var fallback := PLANNER._fallback_plan(PLANNER._load_json(PLANNER.CONFIG_PATH), "encounter_composition_failed", plan.get("composition_report", {}))
        fallback["composition_report"] = plan.get("composition_report", {}).duplicate(true)
        return fallback
    plan = EVENT_DIRECTOR.populate(plan, PLANNER._load_json(PLANNER.MODULES_PATH))
    var validation := validate_final(plan, run_state)
    plan["generation_report"]["stages"].append_array(["remanence", "encounter_director", "encounter_composition", "event_director", "final_validation"])
    plan["generation_report"]["validation"] = validation.duplicate(true)
    plan["validation"] = validation
    if not bool(validation.get("ok", false)):
        var fallback := PLANNER._fallback_plan(PLANNER._load_json(PLANNER.CONFIG_PATH), "final_validation_failed", validation)
        fallback["failed_generation_report"] = plan.get("generation_report", {}).duplicate(true)
        return fallback
    return plan

static func validate_final(plan: Dictionary, context: Dictionary = {}) -> Dictionary:
    var errors: Array[String] = []
    var report: Dictionary = plan.get("generation_report", {})
    var effective_context: Dictionary = context if not context.is_empty() else report.get("run_state", {})
    var root_seed := int(plan.get("seed", 0))
    var expected_seeds := PLANNER.RUN_SEED.streams(root_seed)
    var saved_seeds: Dictionary = plan.get("stage_seeds", {})
    if saved_seeds.size() != expected_seeds.size():
        errors.append("invalid_stage_seeds")
    for stream in expected_seeds:
        var value: Variant = saved_seeds.get(stream)
        if not (value is int or value is float) or value != expected_seeds[stream]:
            errors.append("invalid_stage_seeds:" + str(stream))
    for node in plan.get("nodes", []):
        var room_id := str(node.get("id", ""))
        for stream in ["encounter", "event", "loot", "ai"]:
            if not node.has(stream + "_seed") or int(node.get(stream + "_seed", 0)) != PLANNER.RUN_SEED.derive(root_seed, stream, room_id):
                errors.append("invalid_room_seed:" + room_id + ":" + stream)
    var config := PLANNER._load_json(PLANNER.CONFIG_PATH)
    var library := PLANNER._load_json(PLANNER.MODULES_PATH)
    var tables := PLANNER._load_json(PLANNER.ENCOUNTERS_PATH)
    errors.append_array(PLANNER.validate_plan(plan, config, library).get("errors", []))
    errors.append_array(ENCOUNTER_DIRECTOR.validate_dungeon_plan(plan, library, tables, effective_context).get("errors", []))
    errors.append_array(COMPOSITION_RESOLVER.validate_plan(plan).get("errors", []))
    errors.append_array(EVENT_DIRECTOR.validate(plan, library).get("errors", []))
    return {"ok":errors.is_empty(), "errors":errors}

# Replay against the same loaded campaign, refusing changed inputs instead of
# silently claiming an old seed is sufficient across data or engine revisions.
static func replay(report: Dictionary) -> Dictionary:
    if int(report.get("version", -1)) != PLANNER.GENERATOR_VERSION or str(report.get("engine_version", "")) != str(Engine.get_version_info().get("string", "")):
        return {"ok":false, "error":"replay_version_mismatch"}
    if report.get("world_state_revision", "") != _world_state_revision():
        return {"ok":false, "error":"replay_world_state_mismatch"}
    var expected_paths := [PLANNER.CONFIG_PATH, PLANNER.MODULES_PATH, PLANNER.ENCOUNTERS_PATH, PLANNER.REMANENCE_PATH, HybridDungeonGenerator.RULES_PATH, COMPOSITION_RESOLVER.ENEMIES_PATH, COMPOSITION_RESOLVER.TREE_PATH, "res://data/remanence_rules.json", "res://data/remanence_world_rules.json"]
    var revisions: Dictionary = report.get("data_revisions", {})
    for path in expected_paths:
        if str(revisions.get(path, "")) != FileAccess.get_file_as_string(path).sha256_text():
            return {"ok":false, "error":"replay_data_mismatch", "path":path}
    var plan := build(report.get("run_state", {}))
    if bool(plan.get("fallback", false)) or plan.get("generation_report", {}) != report:
        return {"ok":false, "error":"replay_report_mismatch"}
    return plan

static func _world_state_revision() -> String:
    # Read the logical inputs directly: serialize() enforces caps and can mutate.
    var state := {"world_scars":RemanenceRuntime.world_scars, "entities":RemanenceRuntime.entities, "run_index":RemanenceRuntime.run_index, "director_available":RemanenceCombatBridge.world_director != null}
    return JSON.stringify(state).sha256_text()

static func _active_world_scars() -> Array:
    var scars: Array = []
    for scar_value: Variant in RemanenceRuntime.world_scars.values():
        if scar_value is Dictionary:
            scars.append((scar_value as Dictionary).duplicate(true))
    return scars

static func _all_nodes_have_modules(nodes: Array) -> bool:
    for node in nodes:
        if str(node.get("module_id", "")) == "":
            return false
    return true
