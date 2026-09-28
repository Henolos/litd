extends SceneTree

const SYNERGY := preload("res://scripts/core/combat/veilleurs_affliction_synergy_runtime.gd")

func _init() -> void:
    var failures: Array[String] = []
    var wounded := {
        "hp": 50,
        "bleeding_state": "important",
        "afflictions": {"bleed": 2},
        "anatomy": {"left_leg": {"state": "cut", "function": "impaired"}}
    }
    var open_state := SYNERGY.inspect(wounded)
    if not bool(open_state.get("open_wound_team", false)):
        failures.append("open_wound_team_not_detected")

    var breaker_target := {"hp": 50, "afflictions": {"vulnerability": 2, "weakness": 2}}
    var precision := {"id":"AU-ANA-09","accuracy":80,"canonical_tags":["PRÉCISION","LÉSION"]}
    var decorated := SYNERGY.decorate_action({"name":"Aurélien"}, breaker_target, precision)
    if not bool(decorated.get("synergy_breaker_window", false)):
        failures.append("breaker_window_not_consumable")
    if int(decorated.get("accuracy", 0)) != 90:
        failures.append("breaker_window_accuracy_not_applied")

    var control_target := {"hp": 50, "afflictions": {"stun": 1, "silence": 2}}
    var control_state := SYNERGY.inspect(control_target)
    if not bool(control_state.get("control_window", false)):
        failures.append("control_window_not_detected")
    if (control_state.get("active_controls", []) as Array).size() != 2:
        failures.append("control_roles_collapsed")

    if failures.is_empty():
        print("VEILLEURS_AFFLICTION_SYNERGY_RUNTIME_OK")
        quit(0)
    for failure in failures:
        push_error(failure)
    quit(1)
