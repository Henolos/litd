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

    var wound_skill := {"id":"MA-ENT-09","accuracy":80,"canonical_tags":["SAIGNEMENT","MEMBRE_BLESSÉ","EXPOSÉ"]}
    var wound_decorated := SYNERGY.decorate_action({"name":"Mathilde"}, wounded, wound_skill)
    if not bool(wound_decorated.get("synergy_open_wound", false)):
        failures.append("open_wound_not_consumable")
    if int(wound_decorated.get("accuracy", 0)) != 85:
        failures.append("open_wound_accuracy_not_applied")

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

    var control_skill := {"id":"MA-TRA-13","accuracy":82,"canonical_tags":["PRÉCISION","EXPOSÉ"]}
    var control_decorated := SYNERGY.decorate_action({"name":"Mathilde"}, control_target, control_skill)
    if not bool(control_decorated.get("synergy_control_exploit", false)):
        failures.append("control_window_not_exploitable")
    if int(control_decorated.get("accuracy", 0)) != 87:
        failures.append("control_window_accuracy_not_applied")

    var mathilde_payoff := SYNERGY.decorate_action({"name":"Mathilde"}, wounded, {"id":"MA-ENT-09","tree":"Entaille","accuracy":80,"canonical_tags":["SAIGNEMENT","MEMBRE_BLESSÉ"]})
    if str(mathilde_payoff.get("synergy_tree_payoff", "")) != "mathilde_hemorrhage":
        failures.append("mathilde_tree_payoff_missing")

    var marec_payoff := SYNERGY.decorate_action({"name":"Marec"}, breaker_target, {"id":"MR-BRI-14","tree":"Brisure","accuracy":80,"canonical_tags":["EXPOSÉ"]})
    if str(marec_payoff.get("synergy_tree_payoff", "")) != "marec_breaker":
        failures.append("marec_tree_payoff_missing")

    var silence_target := {"hp":50,"afflictions":{"silence":2}}
    var anouk_payoff := SYNERGY.decorate_action({"name":"Anouk"}, silence_target, {"id":"AN-DIS-14","tree":"Dissidence","accuracy":80,"canonical_tags":["INTERROMPU"]})
    if str(anouk_payoff.get("synergy_tree_payoff", "")) != "anouk_disruptor":
        failures.append("anouk_tree_payoff_missing")

    var snared_target := {"hp":50,"afflictions":{"snare":2}}
    var aurelien_control := SYNERGY.decorate_action({"name":"Aurélien"}, snared_target, {"id":"AU-ANA-14","tree":"Anatomie","accuracy":80,"canonical_tags":["MEMBRE_BLESSÉ"]})
    if str(aurelien_control.get("synergy_tree_payoff", "")) != "aurelien_anatomical_control":
        failures.append("aurelien_anatomy_payoff_missing")

    var aurelien_blood := SYNERGY.decorate_action({"name":"Aurélien"}, wounded, {"id":"AÏ-HÉM-14","tree":"Hémocorde","accuracy":80,"canonical_tags":["SAIGNEMENT","VASCULAIRE"]})
    if str(aurelien_blood.get("synergy_tree_payoff", "")) != "aurelien_hemocorde":
        failures.append("aurelien_hemocorde_payoff_missing")

    var plain_skill := {"id":"TEST-PLAIN","accuracy":82,"canonical_tags":["GARDE"]}
    var plain_decorated := SYNERGY.decorate_action({"name":"Marec"}, control_target, plain_skill)
    if bool(plain_decorated.get("synergy_control_exploit", false)):
        failures.append("control_window_applied_to_unrelated_skill")
    if int(plain_decorated.get("accuracy", 0)) != 82:
        failures.append("control_window_changed_unrelated_accuracy")

    if failures.is_empty():
        print("VEILLEURS_AFFLICTION_SYNERGY_RUNTIME_OK")
        quit(0)
        return
    for failure in failures:
        push_error(failure)
    quit(1)
