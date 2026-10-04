extends Node

const ID := "dungeon_first_map_hall_of_first_accord"
const PATH := ["vestibule", "gallery_of_names", "debate_chamber", "collapsed_passage", "three_pillars_hall", "warden_sanctum"]
var failures: Array[String] = []

func check(ok: bool, label: String) -> void:
    if not ok:
        failures.append(label)
        push_error(label)

func _ready() -> void:
    var results: Array = []
    for seed in [101, 102, 103, 104, 105, 106]:
        var first := play(seed)
        var replay := play(seed)
        check(first == replay, "playthrough_not_deterministic:%d" % seed)
        results.append(first)
    print("FIRST_ACCORD_PLAYTHROUGH_RESULTS: ", JSON.stringify(results))
    _boss_probe()
    print("FIRST_ACCORD_PLAYTHROUGH: ", "OK" if failures.is_empty() else failures)
    get_tree().quit(0 if failures.is_empty() else 1)

func _boss_probe() -> void:
    RemanenceRuntime.reset_new_game()
    VeilleursRuntime.reset_new_game()
    var ui = load("res://scenes/veilleurs/vertical_slice.tscn").instantiate()
    add_child(ui)
    check(bool(ui.slice.start_dungeon(ID, 101).get("ok", false)), "boss_fixture_start")
    # Isolated authored boss fixture, separate from the expedition results.
    ui.slice.campaign.dungeon.enter("warden_sanctum")
    ui._launch_combat()
    ui.selected_target = ""
    ui._on_cell(ui.slice.combat.grid.position_of("c01_ancient_accord_warden"))
    check(ui.selected_target == "c01_ancient_accord_warden", "warden_cell_selection")
    var actions := 0
    while ui.slice.combat != null and actions < 100:
        var choice := best_attack(ui)
        if choice.is_empty():
            check(approach(ui), "boss_no_path")
            choice = best_attack(ui)
        if choice.is_empty():
            break
        ui._on_cell(ui.slice.combat.grid.position_of(str(choice["watcher"])))
        ui._on_cell(ui.slice.combat.grid.position_of(str(choice["target"])))
        ui._on_zone(str(choice["zone"]))
        ui._on_skill(ui.skill_ids.find(str(choice["skill"])))
        actions += 1
    var won: bool = ui.slice.combat == null and bool(ui.slice.campaign.dungeon.node_flags.get("warden_sanctum", {}).get("completed", false))
    check(won, "isolated_boss_not_completed")
    print("FIRST_ACCORD_ISOLATED_BOSS: ", {"victory":won, "actions":actions})
    ui.free()

func play(seed: int) -> Dictionary:
    RemanenceRuntime.reset_new_game()
    VeilleursRuntime.reset_new_game()
    var ui = load("res://scenes/veilleurs/vertical_slice.tscn").instantiate()
    add_child(ui)
    var run = ui.slice
    check(bool(run.start_dungeon(ID, seed).get("ok", false)), "start")
    ui._render_node()
    var rooms: Array = []
    for room_id in PATH:
        if run.campaign.dungeon.current_node != room_id:
            check(bool(run.enter_next(room_id).get("ok", false)), "enter:" + room_id)
        if run.campaign.dungeon.active_encounter.is_empty():
            check(bool(run.campaign.resolve_current_node("cleared", {}).get("ok", false)), "clear:" + room_id)
            continue
        ui._launch_combat()
        check(run.combat != null, "launch:" + room_id)
        if run.combat == null:
            break
        var actions := 0
        var zones: Dictionary = {}
        var enemy_count: int = run.combat.alive_ids("enemy").size()
        # Drive the same UI callbacks as the player. No HP/stat edits,
        # forced hit rolls, direct victory, or teleporting combatants.
        while run.combat != null and actions < 100:
            var choice := best_attack(ui)
            if choice.is_empty():
                check(approach(ui), "no_legal_attack_or_path:" + room_id)
                choice = best_attack(ui)
            if choice.is_empty():
                break
            ui._on_cell(run.combat.grid.position_of(str(choice["watcher"])))
            ui.selected_target = ""
            ui._on_cell(run.combat.grid.position_of(str(choice["target"])))
            check(ui.selected_target == str(choice["target"]), "enemy_cell_not_selectable:" + str(choice["target"]))
            ui._on_zone(str(choice["zone"]))
            var slot: int = ui.skill_ids.find(str(choice["skill"]))
            check(slot >= 0, "skill_not_in_ui")
            ui._on_skill(slot)
            zones[str(choice["zone"])] = true
            actions += 1
        var won: bool = run.combat == null and bool(run.campaign.dungeon.node_flags.get(room_id, {}).get("completed", false))
        rooms.append({"room":room_id, "enemies":enemy_count, "actions":actions, "victory":won, "zones":zones.keys()})
        if not won:
            break
    var completed: bool = bool(run.campaign.dungeon.node_flags.get("warden_sanctum", {}).get("completed", false))
    var result := {"seed":seed, "rooms":rooms, "completed":completed, "resources":run.campaign.dungeon.collected_rewards()}
    if completed:
        check(bool(run.campaign.complete_expedition().get("ok", false)), "extract")
    ui.free()
    return result

func best_attack(ui) -> Dictionary:
    var combat = ui.slice.combat
    var best: Dictionary = {}
    var score := -1.0
    for watcher in combat.alive_ids("watcher"):
        ui.selected_watcher = watcher
        ui._refresh_combat()
        for skill_id in ui.skill_ids:
            var skill: Dictionary = combat.content_db.skill(skill_id)
            if combat.skill_behavior.effective_action(skill) != "attack":
                continue
            for enemy in combat.alive_ids("enemy"):
                for zone in ["torso", "head", "left_arm", "right_arm", "left_leg", "right_leg"]:
                    var preview: Dictionary = combat.preview_skill(watcher, enemy, skill_id, zone)
                    if not bool(preview.get("ok", false)):
                        continue
                    var value := float(preview.get("damage", 0)) * float(preview.get("hit_chance", 0)) / 100.0
                    if value > score:
                        score = value
                        best = {"watcher":watcher, "target":enemy, "skill":skill_id, "zone":zone}
    return best

func approach(ui) -> bool:
    var combat = ui.slice.combat
    var moved := false
    for watcher in combat.alive_ids("watcher"):
        var origin: Vector2i = combat.grid.position_of(watcher)
        var queue: Array = [origin]
        var parents: Dictionary = {origin:origin}
        var destination := origin
        var shortest := 999
        for enemy in combat.alive_ids("enemy"):
            shortest = mini(shortest, combat.grid.distance(watcher, enemy))
        while not queue.is_empty():
            var cell: Vector2i = queue.pop_front()
            for enemy in combat.alive_ids("enemy"):
                var target: Vector2i = combat.grid.position_of(enemy)
                var distance := absi(cell.x - target.x) + absi(cell.y - target.y)
                if distance < shortest:
                    shortest = distance
                    destination = cell
            for neighbor in combat.grid.neighbors(cell):
                if not parents.has(neighbor) and combat.can_move_to(neighbor):
                    parents[neighbor] = cell
                    queue.append(neighbor)
        if destination == origin:
            continue
        var path: Array[Vector2i] = []
        while destination != origin:
            path.push_front(destination)
            destination = parents[destination]
        ui._on_cell(origin)
        for step in path:
            ui._on_cell(step)
        moved = true
    return moved
