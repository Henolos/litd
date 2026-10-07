extends SceneTree

const RUNTIME := preload("res://scripts/core/veilleurs_combat_runtime.gd")

func _initialize() -> void:
    var runtime := RUNTIME.new()
    assert(bool(runtime.setup_first_combat().get("ok", false)), "combat setup must succeed")
    var enemy_ids: Array[String] = runtime.alive_ids("enemy")
    assert(not enemy_ids.is_empty(), "test requires an enemy")
    var enemy_id := enemy_ids[0]
    var before_size := runtime.action_log.size()
    var result: Dictionary = runtime._fallback_enemy_action(enemy_id, {"reason":"forced_invalid_decision","doctrine_used":true}, "forced_test_failure")
    assert(bool(result.get("ok", false)), "canonical fallback must be a legal hold")
    assert(str(result.get("action", "")) == "hold", "fallback must hold instead of executing legacy AI")
    assert(str(result.get("decision_reason", "")) == "canonical_fallback", "fallback provenance must be explicit")
    assert(bool(result.get("generated_skill_fallback", false)), "fallback marker must be preserved")
    assert(str(result.get("generated_skill_reason", "")) == "forced_test_failure", "failure reason must be preserved")
    assert(runtime.action_log.size() == before_size + 1, "canonical hold must be journaled exactly once")
    assert(runtime.action_log[-1] == result, "journal must contain the canonical fallback snapshot")
    print("VEILLEURS_ENEMY_CANONICAL_FALLBACK_OK")
    quit(0)
