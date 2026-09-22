extends SceneTree

const TEST_SCRIPTS := [
    "res://scripts/tests/veilleurs_anatomy_resolver_contract_test.gd",
    "res://scripts/tests/veilleurs_status_resolver_contract_test.gd",
    "res://scripts/tests/veilleurs_reaction_resolver_contract_test.gd",
    "res://scripts/tests/veilleurs_combat_command_event_contract_test.gd",
    "res://scripts/tests/veilleurs_target_resolver_contract_test.gd"
]

func _init() -> void:
    for path in TEST_SCRIPTS:
        assert(ResourceLoader.exists(path), "Missing combat pipeline contract test: %s" % path)
    print("VEILLEURS_COMBAT_PIPELINE_TEST_SET_PRESENT")
    quit(0)
