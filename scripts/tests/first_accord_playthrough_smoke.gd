extends Node

const ID := "dungeon_first_map_hall_of_first_accord"
const PATH := ["vestibule", "gallery_of_names", "debate_chamber", "collapsed_passage", "three_pillars_hall", "warden_sanctum"]
var failures: Array[String] = []
var coverage: Dictionary = {}

func check(ok: bool, label: String) -> void:
    if not ok:
        failures.append(label)
        push_error(label)

func _ready() -> void:
    var results: Array = []
    for policy in ["offense", "heal", "guard_control", "mixed", "focus", "limbs", "focus_limbs_mixed", "head", "legs"]:
        for seed in [101, 102, 103, 104, 105, 106]:
            var first := play(seed, policy)
            var replay := play(seed, policy)
            check(first == replay, "playthrough_not_deterministic:%s:%d" % [policy, seed])
            results.append(first)
    print("FIRST_ACCORD_PLAYTHROUGH_RESULTS: ", JSON.stringify(results))
    for action in ["heal", "guard", "control", "ally_healed", "focused_attack", "limb_attack", "head_attack", "leg_attack"]:
        check(int(coverage.get(action, 0)) > 0, "survival_action_not_exercised:" + action)
    print("FIRST_ACCORD_SURVIVAL_COVERAGE: ", coverage)
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

func play(seed: int, policy: String = "offense") -> Dictionary:
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
        var skill_actions: Dictionary = {}
        var trace_hashes: Array[String] = []
        var stop_reason := "action_limit"
        var focus := ""
        var impairments: Dictionary = {}
        var limb_ripostes := 0
        var inventory := available_actions(ui)
        # Drive the same UI callbacks as the player. No HP/stat edits,
        # forced hit rolls, direct victory, or teleporting combatants.
        while run.combat != null and actions < 100:
            if policy in ["focus", "focus_limbs_mixed"] and not run.combat.alive_ids("enemy").has(focus):
                focus = weakest_enemy(run.combat)
            var choice := survival_action(ui, "mixed" if policy == "focus_limbs_mixed" else policy, actions, skill_actions)
            if choice.is_empty():
                choice = best_attack(ui, policy, focus)
            if choice.is_empty():
                approach(ui, focus)
                choice = best_attack(ui, policy, focus)
            if choice.is_empty():
                stop_reason = "no_attack_available_to_survivors"
                break
            ui._on_cell(run.combat.grid.position_of(str(choice["watcher"])))
            ui.selected_target = ""
            if str(run.combat.combatants[str(choice["target"])].get("team", "")) == "enemy":
                ui._on_cell(run.combat.grid.position_of(str(choice["target"])))
                check(ui.selected_target == str(choice["target"]), "enemy_cell_not_selectable:" + str(choice["target"]))
            ui._on_zone(str(choice["zone"]))
            for index in range(ui.ally_target.item_count):
                if str(ui.ally_target.get_item_metadata(index)) == str(choice["target"]):
                    ui._on_ally_target(index)
                    break
            var slot: int = ui.skill_ids.find(str(choice["skill"]))
            check(slot >= 0, "skill_not_in_ui")
            var action_type: String = run.combat.skill_behavior.effective_action(run.combat.content_db.skill(str(choice["skill"])))
            var active_combat = run.combat
            var before: int = active_combat.action_log.size()
            ui._on_skill(slot)
            check(active_combat.action_log.size() > before, "ui_action_refused:" + str(choice))
            if active_combat.action_log.size() > before:
                var event: Dictionary = active_combat.action_log[before]
                check(str(event.get("attacker", "")) == str(choice["watcher"]), "wrong_action_actor")
                check(str(event.get("target", "")) == str(choice["target"]), "wrong_action_target")
                coverage[action_type] = int(coverage.get(action_type, 0)) + 1
                if action_type == "attack" and focus != "":
                    check(str(event.get("target", "")) == focus, "focus_target_changed_while_alive")
                    coverage["focused_attack"] = int(coverage.get("focused_attack", 0)) + 1
                if action_type == "attack" and str(choice["zone"]) in ["left_arm", "right_arm", "left_leg", "right_leg"]:
                    coverage["limb_attack"] = int(coverage.get("limb_attack", 0)) + 1
                if action_type == "attack" and str(choice["zone"]) == "head":
                    coverage["head_attack"] = int(coverage.get("head_attack", 0)) + 1
                if action_type == "attack" and str(choice["zone"]) in ["left_leg", "right_leg"]:
                    coverage["leg_attack"] = int(coverage.get("leg_attack", 0)) + 1
                var body_result: Dictionary = event.get("body", {})
                if bool(event.get("hit", false)) and str(body_result.get("state", "L0")) in ["L3", "L4", "L5"]:
                    impairments[str(choice["target"]) + ":" + str(choice["zone"])] = str(body_result.get("state"))
                if action_type == "heal" and str(event.get("attacker", "")) != str(event.get("target", "")) and int(event.get("healed", 0)) > 0:
                    coverage["ally_healed"] = int(coverage.get("ally_healed", 0)) + 1
            # Observe enemy damage after severe limb trauma without inventing
            # a new action restriction or damage multiplier.
            for index in range(before + 1, active_combat.action_log.size()):
                var reply: Dictionary = active_combat.action_log[index]
                var actor := str(reply.get("attacker", ""))
                if not active_combat.combatants.has(actor) or int(reply.get("damage", 0)) <= 0:
                    continue
                var actor_row: Dictionary = active_combat.combatants[actor]
                if str(actor_row.get("team", "")) != "enemy":
                    continue
                var actor_body: Variant = actor_row.get("body")
                if actor_body != null and not bool(actor_body.functional_flags().get("can_use_two_handed", true)):
                    limb_ripostes += 1
                    coverage["damaging_reply_after_arm_l4"] = int(coverage.get("damaging_reply_after_arm_l4", 0)) + 1
            trace_hashes.append(JSON.stringify(active_combat.serialize()).sha256_text())
            skill_actions[action_type] = int(skill_actions.get(action_type, 0)) + 1
            zones[str(choice["zone"])] = true
            actions += 1
        var won: bool = run.combat == null and bool(run.campaign.dungeon.node_flags.get(room_id, {}).get("completed", false))
        rooms.append({"room":room_id, "enemies":enemy_count, "actions":actions, "victory":won, "zones":zones.keys(), "skill_actions":skill_actions, "available_actions":inventory, "impairments":impairments, "damaging_replies_after_arm_l4":limb_ripostes, "trace_hash":JSON.stringify(trace_hashes).sha256_text(), "stop_reason":"victory" if won else ("defeat" if run.combat == null else stop_reason)})
        if not won:
            break
    var completed: bool = bool(run.campaign.dungeon.node_flags.get("warden_sanctum", {}).get("completed", false))
    var result := {"seed":seed, "policy":policy, "rooms":rooms, "completed":completed, "resources":run.campaign.dungeon.collected_rewards()}
    if completed:
        check(bool(run.campaign.complete_expedition().get("ok", false)), "extract")
    ui.free()
    return result

func best_attack(ui, policy: String = "offense", focus: String = "") -> Dictionary:
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
                if focus != "" and enemy != focus:
                    continue
                var target_zones := attack_zones(combat, enemy, policy)
                for zone in target_zones:
                    var preview: Dictionary = combat.preview_skill(watcher, enemy, skill_id, zone)
                    if not bool(preview.get("ok", false)):
                        continue
                    var value := float(preview.get("damage", 0)) * float(preview.get("hit_chance", 0)) / 100.0
                    if value > score:
                        score = value
                        best = {"watcher":watcher, "target":enemy, "skill":skill_id, "zone":zone}
    return best

func approach(ui, focus: String = "") -> bool:
    var combat = ui.slice.combat
    var moved := false
    for watcher in combat.alive_ids("watcher"):
        var origin: Vector2i = combat.grid.position_of(watcher)
        var queue: Array = [origin]
        var parents: Dictionary = {origin:origin}
        var destination := origin
        var shortest := 999
        for enemy in combat.alive_ids("enemy"):
            if focus != "" and enemy != focus:
                continue
            shortest = mini(shortest, combat.grid.distance(watcher, enemy))
        while not queue.is_empty():
            var cell: Vector2i = queue.pop_front()
            for enemy in combat.alive_ids("enemy"):
                if focus != "" and enemy != focus:
                    continue
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

# Policies use only the four displayed skills and the UI's ally selector. Support is bounded to every third action to avoid endless healing loops.
func survival_action(ui, policy: String, actions: int, used: Dictionary) -> Dictionary:
    if policy == "offense" or actions % 3 != 0:
        return {}
    var combat = ui.slice.combat
    var best: Dictionary = {}
    var score := -1.0
    for watcher in combat.alive_ids("watcher"):
        ui.selected_watcher = watcher
        ui._refresh_combat()
        var row: Dictionary = combat.combatants[watcher]
        var missing := int(row.get("max_hp", 1)) - int(row.get("hp", 0))
        for skill_id in ui.skill_ids:
            var skill: Dictionary = combat.content_db.skill(skill_id)
            var action: String = combat.skill_behavior.effective_action(skill)
            var target: String = watcher
            var value := -1.0
            if action == "heal" and policy in ["heal", "mixed"]:
                for ally in combat.alive_ids("watcher"):
                    var patient: Dictionary = combat.combatants[ally]
                    var deficit := int(patient.get("max_hp", 1)) - int(patient.get("hp", 0))
                    var urgency := float(deficit) / float(patient.get("max_hp", 1)) * 100.0
                    if deficit >= 10 and urgency > value and bool(combat.preview_skill(watcher, ally, skill_id, "torso").get("ok", false)):
                        target = ally
                        value = urgency
            elif action == "guard" and policy in ["guard_control", "mixed"] and int(used.get("guard", 0)) < 2:
                value = 20.0 + float(missing) / float(row.get("max_hp", 1)) * 20.0
            elif action == "control" and policy in ["guard_control", "mixed"] and int(used.get("control", 0)) < 2:
                for enemy in combat.alive_ids("enemy"):
                    if bool(combat.preview_skill(watcher, enemy, skill_id, "torso").get("ok", false)):
                        target = enemy
                        value = 30.0
                        break
            if value > score and value >= 0.0 and bool(combat.preview_skill(watcher, target, skill_id, "torso").get("ok", false)):
                score = value
                best = {"watcher":watcher, "target":target, "skill":skill_id, "zone":"torso"}
    return best

func available_actions(ui) -> Array:
    var actions: Array = []
    for watcher in ui.slice.combat.alive_ids("watcher"):
        ui.selected_watcher = watcher
        ui._refresh_combat()
        for skill_id in ui.skill_ids:
            var action: String = ui.slice.combat.skill_behavior.effective_action(ui.slice.combat.content_db.skill(skill_id))
            if not actions.has(action):
                actions.append(action)
    actions.sort()
    return actions

# Finish the lowest-HP target before switching; initial ties use stable IDs.
func weakest_enemy(combat) -> String:
    var ids: Array = combat.alive_ids("enemy")
    ids.sort()
    var chosen := ""
    var hp := 2147483647
    for enemy in ids:
        var value := int(combat.combatants[enemy].get("hp", 0))
        if value < hp:
            chosen = enemy
            hp = value
    return chosen

# Concentrate trauma on one functional arm, then the other, then legs.
# Fall back to torso once all limbs reach L4. No new damage rule is assumed.
func attack_zones(combat, enemy: String, policy: String) -> Array:
    if policy == "head":
        return ["head"]
    if policy not in ["limbs", "focus_limbs_mixed", "legs"]:
        return ["torso", "head", "left_arm", "right_arm", "left_leg", "right_leg"]
    var body: Variant = combat.combatants[enemy].get("body")
    var states: Dictionary = body.serialize().get("states", {})
    var zones := ["left_leg", "right_leg", "left_arm", "right_arm"] if policy == "legs" else ["left_arm", "right_arm", "left_leg", "right_leg"]
    for zone in zones:
        if str(states.get(zone, "L0")) not in ["L4", "L5"]:
            return [zone]
    return ["torso"]
