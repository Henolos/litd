extends Node

const STATUS := preload("res://scripts/core/combat/veilleurs_status_resolver.gd")

var failures: Array[String] = []

func check(condition: bool, label: String) -> void:
    if not condition:
        failures.append(label)
        push_error(label)

func _ready() -> void:
    var patient := {"id":"injury_affliction_probe","hp":60,"max_hp":60,"persistent_injuries":[],"afflictions":{}}
    var applied: Dictionary = PersistentInjuryRuntime.apply_injury(patient, "sprain", "minor")
    check(not applied.is_empty(), "sprain_applied")
    patient.afflictions = STATUS.apply_affliction(patient, "poison", 2).afflictions
    check(STATUS.has(patient, "poison"), "poison_applied")
    check((patient.persistent_injuries as Array).size() == 1, "injury_and_poison_coexist")

    check(PersistentInjuryRuntime.stabilize_in_field(patient, "sprain"), "field_stabilization")
    check(STATUS.has(patient, "poison"), "stabilization_does_not_cleanse_poison")
    check((patient.persistent_injuries as Array).size() == 1, "stabilization_does_not_remove_injury")

    var treated: Dictionary = PersistentInjuryRuntime.treat_injury(patient, "sprain", [], true)
    check(bool(treated.get("ok", false)), "infirmary_treats_sprain")
    check((patient.persistent_injuries as Array).is_empty(), "sprain_removed")
    check(STATUS.has(patient, "poison"), "injury_treatment_does_not_cleanse_poison")

    patient.afflictions = STATUS.finish_turn(patient)
    check(STATUS.has(patient, "poison"), "poison_remains_after_first_turn")
    patient.afflictions = STATUS.finish_turn(patient)
    check(not STATUS.has(patient, "poison"), "poison_expires_on_second_turn")

    var amputated := PersistentInjuryRuntime.apply_injury(patient, "arm_lost", "critical")
    check(bool(amputated.get("permanent", false)), "amputation_is_permanent")
    var amputation_treatment := PersistentInjuryRuntime.treat_injury(patient, "arm_lost", [], true)
    check(bool(amputation_treatment.get("ok", false)) and bool(amputation_treatment.get("stabilized", false)), "amputation_stabilized")
    check((patient.persistent_injuries as Array).size() == 1, "amputation_not_regrown")
    check(bool((patient.persistent_injuries[0] as Dictionary).get("stabilized", false)), "amputation_stays_stabilized")

    print("VEILLEURS_INJURY_AFFLICTION_TREATMENT_", "OK" if failures.is_empty() else "FAILED")
    get_tree().quit(0 if failures.is_empty() else 1)
