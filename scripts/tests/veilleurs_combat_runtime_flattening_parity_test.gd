extends Node

const LEGACY := preload("res://scripts/core/veilleurs_tactical_combat_runtime_v09.gd")
const FLAT := preload("res://scripts/core/veilleurs_combat_runtime.gd")

var failures: Array[String] = []

func _ready() -> void:
    _compare_first_combat()
    _compare_boss_contract()
    if failures.is_empty():
        print("VEILLEURS_COMBAT_RUNTIME_FLATTENING_PARITY_OK")
        get_tree().quit(0)
        return
    for failure: String in failures:
        push_error(failure)
    get_tree().quit(1)

func _compare_first_combat() -> void:
    var legacy = LEGACY.new()
    var flat = FLAT.new()
    var legacy_setup: Dictionary = legacy.setup_first_combat()
    var flat_setup: Dictionary = flat.setup_first_combat()
    _expect(bool(legacy_setup.get("ok", false)), "legacy first combat setup")
    _expect(bool(flat_setup.get("ok", false)), "flat first combat setup")
    if not bool(legacy_setup.get("ok", false)) or not bool(flat_setup.get("ok", false)):
        return
    _expect(str(flat_setup.get("version", "")) == "0.9.0", "flat version contract")
    _expect(legacy.alive_ids("watcher").size() == flat.alive_ids("watcher").size(), "watcher count parity")
    _expect(legacy.alive_ids("enemy").size() == flat.alive_ids("enemy").size(), "enemy count parity")
    _expect(int(legacy.behavior_coverage().get("skills", 0)) == int(flat.behavior_coverage().get("skills", -1)), "skill coverage parity")
    _expect(bool(flat.behavior_coverage().get("complete", false)), "flat canonical 180-skill coverage")

    var attacker_id := "ENT_WATCHER_mathilde"
    var target_id := "ENT_ENEMY_GOULE_AFFAMEE"
    var skill_id := "MA-ENT-01"
    var adjacent := Vector2i(1, 0)
    _expect(legacy.grid.move(target_id, adjacent), "legacy target reposition")
    _expect(flat.grid.move(target_id, adjacent), "flat target reposition")
    var legacy_preview: Dictionary = legacy.preview_skill(attacker_id, target_id, skill_id, "right_leg")
    var flat_preview: Dictionary = flat.preview_skill(attacker_id, target_id, skill_id, "right_leg")
    _expect(bool(legacy_preview.get("ok", false)) == bool(flat_preview.get("ok", false)), "preview legality parity")
    if bool(legacy_preview.get("ok", false)) and bool(flat_preview.get("ok", false)):
        _expect(int(legacy_preview.get("hit_chance", -1)) == int(flat_preview.get("hit_chance", -2)), "preview hit parity")
        _expect(int(legacy_preview.get("damage", -1)) == int(flat_preview.get("damage", -2)), "preview damage parity")

    var legacy_result: Dictionary = legacy.resolve_skill(attacker_id, target_id, skill_id, "right_leg", 1)
    var flat_result: Dictionary = flat.resolve_skill(attacker_id, target_id, skill_id, "right_leg", 1)
    for key: String in ["ok", "hit", "damage", "target_hp", "functional_loss"]:
        _expect(legacy_result.get(key) == flat_result.get(key), "resolve parity: %s" % key)

    var legacy_enemy: Dictionary = legacy.combatants[target_id]
    var flat_enemy: Dictionary = flat.combatants[target_id]
    legacy_enemy["resolve_current"] = 0
    flat_enemy["resolve_current"] = 0
    legacy.combatants[target_id] = legacy_enemy
    flat.combatants[target_id] = flat_enemy
    var legacy_subdue: Dictionary = legacy.subdue_status(target_id)
    var flat_subdue: Dictionary = flat.subdue_status(target_id)
    _expect(bool(legacy_subdue.get("ok", false)) == bool(flat_subdue.get("ok", false)), "submission parity")

    var legacy_save: Dictionary = legacy.serialize()
    var flat_save: Dictionary = flat.serialize()
    for key: String in ["v07_active_boss_id", "v07_boss_rules", "v07_ultimates", "v08_region_id", "v08_last_boss_mechanics", "v09_boss_phase", "v09_last_phase_event"]:
        _expect(legacy_save.has(key), "legacy save key: %s" % key)
        _expect(flat_save.has(key), "flat save key: %s" % key)

func _compare_boss_contract() -> void:
    var legacy = LEGACY.new()
    var flat = FLAT.new()
    var context := {"region_id":"parity_region"}
    var legacy_setup: Dictionary = legacy.setup_boss_combat("ENT_BOSS_GARDIEN_SEUIL", context)
    var flat_setup: Dictionary = flat.setup_boss_combat("ENT_BOSS_GARDIEN_SEUIL", context)
    _expect(bool(legacy_setup.get("ok", false)), "legacy boss setup")
    _expect(bool(flat_setup.get("ok", false)), "flat boss setup")
    if not bool(legacy_setup.get("ok", false)) or not bool(flat_setup.get("ok", false)):
        return
    _expect(str(flat_setup.get("version", "")) == "0.9.0", "flat boss version")
    _expect(str(legacy_setup.get("chosen_tree", "")) == str(flat_setup.get("chosen_tree", "")), "boss tree parity")
    _expect(str((legacy_setup.get("boss_mechanics", {}) as Dictionary).get("mechanic", "")) == str((flat_setup.get("boss_mechanics", {}) as Dictionary).get("mechanic", "")), "boss mechanic parity")
    _expect(int((legacy_setup.get("boss_phase", {}) as Dictionary).get("phase", 0)) == int((flat_setup.get("boss_phase", {}) as Dictionary).get("phase", -1)), "boss phase parity")
    legacy.next_round()
    flat.next_round()
    _expect(int(legacy.round_index) == int(flat.round_index), "round parity")
    _expect(int(legacy.boss_phase_snapshot().get("phase", 0)) == int(flat.boss_phase_snapshot().get("phase", -1)), "boss phase snapshot parity")

func _expect(value: bool, message: String) -> void:
    if not value:
        failures.append(message)
