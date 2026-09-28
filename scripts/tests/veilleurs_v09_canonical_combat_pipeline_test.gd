extends SceneTree

const ProductionRuntime := preload("res://scripts/core/veilleurs_runtime.gd")
const VerticalV09 := preload("res://scripts/core/veilleurs_vertical_slice_runtime_v09.gd")
const TacticalV09 := preload("res://scripts/core/veilleurs_tactical_combat_runtime_v09.gd")
const AuthoredV09 := preload("res://scripts/core/veilleurs_authored_encounter_runtime_v09.gd")
const TacticalV2 := preload("res://scripts/core/veilleurs_tactical_combat_runtime_v2.gd")

func _init() -> void:
    var facade := ProductionRuntime.new()
    assert(facade.runtime is VerticalV09, "Production facade must be backed by vertical-slice V09")

    var tactical := TacticalV09.new()
    assert(tactical is TacticalV2, "Boss tactical V09 must inherit the canonical V2 combat pipeline")

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
    ]:
        assert(source.contains(symbol), "Canonical production combat pipeline missing: %s" % symbol)

    print("VEILLEURS_V09_CANONICAL_COMBAT_PIPELINE_OK")
    quit(0)
