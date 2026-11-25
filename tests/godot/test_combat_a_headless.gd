extends SceneTree

var failures := 0

func _initialize() -> void:
    call_deferred("_run")

func _check(ok: bool, message: String) -> void:
    if not ok:
        failures += 1
        push_error(message)

func _run() -> void:
    var packed: PackedScene = load("res://scenes/prototype/combat_a.tscn")
    var combat: Control = packed.instantiate()
    root.add_child(combat)
    await process_frame
    _check(combat.heroes.size() == 4, "Canonical roster is loaded")
    _check([combat.heroes[0]["name"], combat.heroes[1]["name"], combat.heroes[2]["name"], combat.heroes[3]["name"]] == ["Mathilde", "Marec", "Anouk", "Aurélien"], "Canonical order")
    _check(not combat.attack(), "Cannot attack without a selected target")
    _check(not combat.select_target(2), "Cannot select a nonexistent target")
    _check(combat.select_target(1), "Select second living enemy")
    _check(combat.attack(), "Attack consumes action")
    _check(combat.actor_index == 1 and combat.enemies[1]["hp"] == 4 and combat.enemies[0]["hp"] == 8, "Only selected enemy is hit")
    _check(combat.guard(), "Second hero protects")
    _check(combat.actor_index == 2 and combat.heroes[1]["guard"], "Guard lasts to enemy turn")
    _check(combat.select_target(1) and combat.attack(), "Third hero eliminates second enemy")
    _check(not combat.select_target(1), "Defeated enemy cannot be selected")
    _check(combat.guard(), "Fourth hero finishes the round")
    _check(combat.round_number == 2 and combat.actor_index == 0 and combat.heroes[0]["hp"] == 9, "Remaining enemy attacks before new round")
    _check(combat.select_target(0) and combat.attack(), "First hero attacks last enemy")
    _check(combat.select_target(0) and combat.attack(), "Second hero wins")
    _check(combat.phase == "victory" and not combat.attack() and not combat.guard(), "Victory stops actions")
    combat.start_encounter()
    _check(combat.phase == "player" and combat.round_number == 1 and combat.heroes[0]["hp"] == 12, "Restart is independent")
    _check(combat.guard() and combat.guard() and combat.guard() and combat.guard(), "Whole party can end turn in guard")
    _check(combat.heroes[0]["hp"] == 8 and not combat.heroes[0]["guard"], "Guard absorbs only the next incoming attack")
    combat.queue_free()
    if failures == 0:
        print("COMBAT_A_EXPERIMENT_OK")
    quit(1 if failures else 0)
