extends SceneTree

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var vr := root.get_node("VeilleursRuntime")
    vr.reset_new_game()
    var world: Node3D = load("res://scenes/dungeons/first_accord_playable_blockout.tscn").instantiate()
    root.add_child(world)
    current_scene = world
    var exit: Area3D = world.get_node("ExtractionInteractions").get_node(str(world.plan["entry_id"]) + "_exit")
    world.party.global_position = exit.global_position + Vector3(0, -0.3, 1.0)
    var result: Dictionary = exit.perform_interaction(world.party)
    if not bool(result.get("success", false)):
        push_error("extraction failed")
        quit(1)
        return
    await scene_changed
    await process_frame
    if current_scene.scene_file_path != "res://scenes/Main.tscn" or root.get_node("GameState").current_screen != "sanctuary" or vr.is_active() or not vr.physical_state.is_empty():
        push_error("sanctuary routing or state failed")
        quit(1)
        return
    var saves := root.get_node("SaveManager")
    if saves.last_operation != "save":
        push_error("extraction was not saved")
        quit(1)
        return
    vr.reset_new_game()
    if not saves.load_game() or vr.is_active() or not vr.physical_state.is_empty():
        push_error("extracted save resumes an active dungeon")
        quit(1)
        return
    print("FIRST_ACCORD_EXTRACTION_ROUTE: OK")
    quit(0)
