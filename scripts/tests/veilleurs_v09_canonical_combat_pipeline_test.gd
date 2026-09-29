extends SceneTree

const ProductionRuntime := preload("res://scripts/core/veilleurs_runtime.gd")
const VerticalV09 := preload("res://scripts/core/veilleurs_vertical_slice_runtime_v09.gd")
const TacticalV09 := preload("res://scripts/core/veilleurs_tactical_combat_runtime_v09.gd")
const AuthoredV09 := preload("res://scripts/core/veilleurs_authored_encounter_runtime_v09.gd")
const TacticalV2 := preload("res://scripts/core/veilleurs_tactical_combat_runtime_v2.gd")
const MobileCombatUX := preload("res://scripts/ui/veilleurs_mobile_combat_ux_v09.gd")

func _init() -> void:
    var facade := ProductionRuntime.new()
    assert(facade.runtime is VerticalV09, "Production facade must be backed by vertical-slice V09")

    var tactical := TacticalV09.new()
    assert(tactical is TacticalV2, "Boss tactical V09 must inherit the canonical V2 combat pipeline")
    assert(bool(tactical.setup_first_combat().get("ok", false)), "Tactical V09 setup must succeed")
    var mathilde := "ENT_WATCHER_mathilde"
    var aurelien := "ENT_WATCHER_aurelien"
    var enemy := "ENT_ENEMY_GOULE_AFFAMEE"
    var enemy_row: Dictionary = tactical.combatants[enemy]
    enemy_row["afflictions"] = {"bleed":2}
    tactical.combatants[enemy] = enemy_row
    var no_lesion := tactical.skill_synergy_preview(mathilde, enemy, "MA-ENT-09")
    assert(int(no_lesion.get("accuracy_bonus", -1)) == 0, "Pristine L0 anatomy must not activate open-wound synergy")
    var body: VeilleursBodyComponent = (tactical.combatants[enemy] as Dictionary).get("body") as VeilleursBodyComponent
    body.apply_trauma("left_leg", 8)
    enemy_row = tactical.combatants[enemy]
    enemy_row["body"] = body
    tactical.combatants[enemy] = enemy_row
    var wound_window := tactical.skill_synergy_preview(mathilde, enemy, "MA-ENT-09")
    assert(int(wound_window.get("accuracy_bonus", 0)) == 5, "Canonical open-wound synergy must be consumed by V09")
    enemy_row = tactical.combatants[enemy]
    enemy_row["afflictions"] = {"vulnerability":2, "weakness":2}
    tactical.combatants[enemy] = enemy_row
    var breaker_window := tactical.skill_synergy_preview(aurelien, enemy, "AU-ANA-09")
    assert(int(breaker_window.get("accuracy_bonus", 0)) == 10, "Canonical breaker window must be consumed by V09")

    var mobile_ux := MobileCombatUX.new()
    var wound_text := str(mobile_ux.call("_synergy_preview_text", tactical, mathilde, enemy, "MA-ENT-09"))
    assert(wound_text.contains("Plaie ouverte") and wound_text.contains("+5"), "Mobile preview must explain open-wound synergy")
    var breaker_text := str(mobile_ux.call("_synergy_preview_text", tactical, aurelien, enemy, "AU-ANA-09"))
    assert(breaker_text.contains("Fenêtre de brisure") and breaker_text.contains("+10"), "Mobile preview must explain breaker synergy")
    mobile_ux.free()

    var authored := AuthoredV09.new()
    assert(authored is TacticalV2, "Authored V09 must inherit the canonical V2 combat pipeline")

    var source := FileAccess.get_file_as_string("res://scripts/core/veilleurs_tactical_combat_runtime_v2.gd")
    for symbol in [
        "TARGET_RESOLVER_SCRIPT.normalize_zone",
        "HIT_RESOLVER_SCRIPT.resolve_tactical",
        "DAMAGE_RESOLVER_SCRIPT.resolve_tactical_skill",
        "ANATOMY_RESOLVER_SCRIPT.resolve",
        "STATUS_RESOLVER_SCRIPT.resolve_after_hit",
        "REACTION_RESOLVER_SCRIPT.observe_enemy",
        "COMBAT_EVENT_SCRIPT.from_attack",
        "SYNERGY_RUNTIME_SCRIPT.decorate_action",
        "skill_synergy_preview",
    ]:
        assert(source.contains(symbol), "Canonical production combat pipeline missing: %s" % symbol)

    print("VEILLEURS_V09_CANONICAL_COMBAT_PIPELINE_OK")
    quit(0)
