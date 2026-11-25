extends SceneTree

const LOOP_SCENE := preload("res://scenes/prototype/litd1_node_map_loop.tscn")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var loop: Control = LOOP_SCENE.instantiate()
	root.add_child(loop)
	await process_frame
	if not _expect(String(loop.phase) == "guild", "prototype starts at the guild"):
		quit(1)
		return
	if not _expect(not loop.select_node("return_to_guild"), "locked node cannot be selected"):
		quit(1)
		return
	if not _expect(loop.start_expedition(), "start expedition"):
		quit(1)
		return
	if not _expect(loop.phase == "map", "guild opens the node map"):
		quit(1)
		return
	var first_choices: Array[String] = loop.available_node_ids()
	if not _expect(first_choices.has("ash_path") and first_choices.has("shelter"), "map exposes two branches"):
		quit(1)
		return
	if not _expect(loop.select_node("ash_path") and loop.phase == "combat", "combat node opens encounter"):
		quit(1)
		return
	if not _expect(not loop.select_target(10), "invalid combat target is rejected"):
		quit(1)
		return
	if not _expect(loop.guard() and bool(loop.party[0]["guard"]), "guard consumes the protagonist action"):
		quit(1)
		return
	for target_index in [0, 0, 1]:
		loop.select_target(target_index)
		loop.attack()
	if not _expect(loop.phase == "combat" and int(loop.party[0]["hp"]) == 12 and not bool(loop.party[0]["guard"]), "guard absorbs one incoming test attack"):
		quit(1)
		return
	var actions_taken := 0
	while loop.phase == "combat" and actions_taken < 20:
		var target_index := -1
		for index in range(loop.enemies.size()):
			if int(loop.enemies[index]["hp"]) > 0:
				target_index = index
				break
		if target_index < 0:
			break
		loop.select_target(target_index)
		loop.attack()
		actions_taken += 1
	if not _expect(loop.phase == "map", "winning combat returns to the node map"):
		quit(1)
		return
	if not _expect(loop.completed_node_ids.has("ash_path"), "victory resolves the encounter node"):
		quit(1)
		return
	if not _expect(loop.select_node("ash_path") and loop.phase == "node_complete", "visited resolved node can be reopened"):
		quit(1)
		return
	if not _expect(loop.return_to_map(), "resolved node returns to map without replay"):
		quit(1)
		return
	if not _expect(loop.select_node("guild_road"), "visited entry node can be revisited"):
		quit(1)
		return
	if not _expect(loop.select_node("shelter") and loop.phase == "node_event", "alternate branch opens its rest node"):
		quit(1)
		return
	if not _expect(loop.resolve_node_event() and loop.phase == "map", "rest node resolves"):
		quit(1)
		return
	if not _expect(loop.select_node("crossroads") and loop.phase == "map", "branches meet at the crossroads"):
		quit(1)
		return
	if not _expect(loop.available_node_ids().has("return_to_guild"), "exit node is available"):
		quit(1)
		return
	if not _expect(loop.select_node("return_to_guild") and loop.phase == "guild", "return node leads back to the guild"):
		quit(1)
		return
	print("LITD1_NODE_MAP_LOOP_PASS")
	quit(0)

func _expect(condition: bool, label: String) -> bool:
	if not condition:
		push_error("LITD1_NODE_MAP_LOOP_FAIL: " + label)
		return false
	return true
