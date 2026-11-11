extends SceneTree

# The same real combat scene is checked headlessly and rendered for visual review.
# A successful layout/input check is deliberately not a claim of human approval.
var main: Control
var captures: Array = []
var output := "res://reports/combat_portrait_hud"

func _initialize() -> void:
    call_deferred("_run")

func _settle() -> void:
    for frame in range(12):
        await process_frame
    if DisplayServer.get_name() != "headless":
        await RenderingServer.frame_post_draw

func _run() -> void:
    root.content_scale_size = Vector2i(1280, 720)
    root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
    root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP
    var state := root.get_node("GameState")
    state.call("reset_new_game")
    var enemies: Array = []
    var loader := root.get_node("DataLoader")
    for index in range(4):
        var enemy: Dictionary = loader.get("enemies")[index].duplicate(true)
        enemy["combat_position"] = index
        enemies.append(enemy)
    state.set("battle_enemies", enemies)
    main = load("res://scenes/Main.tscn").instantiate()
    root.add_child(main)
    main.call("_apply_logical_starting_formation_v47")
    main.call("show_screen", "combat")
    await _settle()
    var before_party: Array = state.get("party").duplicate(true)
    var fullscreen := OS.get_environment("LITD_COMBAT_FULLSCREEN") == "1"
    var resolutions: Array[Vector2i] = [Vector2i(960, 540), Vector2i(1280, 720), Vector2i(1920, 1080), Vector2i(844, 390)]
    if fullscreen:
        resolutions = [root.size]
    for resolution: Vector2i in resolutions:
        if not fullscreen:
            root.size = resolution
        main.call("show_screen", "combat")
        await _settle()
        _check_layout()
        await _save("fullscreen" if fullscreen else "overview", resolution)
        var skill := _button("1 · ")
        skill.grab_focus()
        await _settle()
        assert("Rangs :" in str((main.get("content") as Control).get_node("CombatReachHintV52").text), "keyboard and touch focus expose reach")
        await _click(skill.get_global_rect().get_center())
        assert(int(main.get("pending_target_skill_slot")) == 0, "actual skill click opens the target selector")
        await _save("targeting", resolution)
        main.call("_cancel_pending_target")
        await _settle()
        var content: Control = main.get("content")
        var inspect := content.get_node("InspectHeroV45_0") as Button
        await _click(inspect.get_global_rect().get_center())
        assert(str(main.get("inspected_combat_key")) != "", "portrait hotspot opens the correct inspector")
        await _save("inspection", resolution)
        main.call("_close_combat_inspection")
        await _settle()
        await _click(_button("POSITION").get_global_rect().get_center())
        assert(bool(main.get("combat_position_menu")), "position menu remains clickable")
        await _save("formation", resolution)
        main.set("combat_position_menu", false)
        main.call("show_screen", "combat")
        await _settle()
        await _click(_button("OBJETS").get_global_rect().get_center())
        assert(bool(main.get("combat_item_menu")), "item menu remains clickable")
        await _save("items", resolution)
        main.set("combat_item_menu", false)
    assert(before_party == state.get("party"), "viewing, targeting and inspection must not mutate hero gameplay data")
    var file := FileAccess.open(output + "/manifest.json", FileAccess.WRITE)
    if file != null:
        file.store_string(JSON.stringify({"revision":OS.get_environment("LITD_HUD_REVISION"), "renderer":RenderingServer.get_video_adapter_name(), "captures":captures, "scope":"Real Godot scene, simulated mouse/keyboard; physical Windows and touch remain separate."}, "  ") + "\n")
    main.queue_free()
    await process_frame
    print("COMBAT_PORTRAIT_HUD_OK captures=" + str(captures.size()))
    quit()

func _button(prefix: String) -> Button:
    var content: Control = main.get("content")
    for candidate: Button in content.find_children("*", "Button", true, false):
        if not candidate.is_queued_for_deletion() and candidate.is_visible_in_tree() and candidate.text.begins_with(prefix):
            return candidate
    assert(false, "missing combat command " + prefix)
    return null

func _check_layout() -> void:
    var content: Control = main.get("content")
    var portraits: Array[TextureRect] = []
    var ordered: Array = main.call("_heroes_by_position")
    for texture: TextureRect in content.find_children("*", "TextureRect", true, false):
        if not texture.has_meta("canonical_hero_id") or texture.is_queued_for_deletion():
            continue
        var index := portraits.size()
        var identity := str(ordered[index].get("canonical_id", ordered[index].get("id", "")))
        assert(str(texture.get_meta("canonical_hero_id")) == identity, "portrait must follow actual rank order and saved identity")
        assert(texture.texture is AtlasTexture, "no complete reference sheet in a combat slot")
        var crop := texture.texture as AtlasTexture
        assert(crop.atlas.resource_path == "res://art/library/heroes/%s/reference.jpg" % identity, "portrait must come from the approved original")
        assert(crop.region.has_area() and crop.region.size.x < crop.atlas.get_width() / 2.0, "portrait is a real individual crop")
        for previous in portraits:
            assert(not previous.get_global_rect().intersects(texture.get_global_rect()), "hero portraits must not overlap")
        portraits.append(texture)
    assert(portraits.size() == 4, "all four canonical heroes must be visible")
    var skills := content.get_node("CombatSkillsRow") as Control
    var utility := content.get_node("CombatUtilityRow") as Control
    assert(not skills.get_global_rect().intersects(utility.get_global_rect()), "skills must not cover utility commands")
    assert(skills.get_child_count() == 4, "four existing skill callbacks must be preserved")
    for button: Button in skills.get_children():
        assert(not button.text.contains("\n"), "reach belongs in contextual help, not oversized buttons")
        assert(button.size.y >= 48 and button.size.y <= 60, "keep the existing logical touch minimum")
    for command in ["OBJETS", "POSITION", "CAPTURER", "PASSER"]:
        var button := _button(command)
        assert(main.get_viewport_rect().encloses(button.get_global_rect()), "command must remain inside logical viewport")
    assert(content.get_node("CombatBackgroundV52") is ColorRect, "baked concept fighters and fake HP must not appear as a live battlefield")

func _click(at: Vector2) -> void:
    var motion := InputEventMouseMotion.new()
    motion.position = at
    motion.global_position = at
    root.push_input(motion, true)
    for pressed in [true, false]:
        var event := InputEventMouseButton.new()
        event.position = at
        event.global_position = at
        event.button_index = MOUSE_BUTTON_LEFT
        event.pressed = pressed
        root.push_input(event, true)
        await process_frame
    await _settle()

func _save(state: String, resolution: Vector2i) -> void:
    var content: Control = main.get("content")
    for panel_name in ["CombatItemMenuV42", "CombatPositionMenuV42"]:
        var panel := content.get_node_or_null(panel_name) as Control
        if panel != null:
            assert(main.get_viewport_rect().encloses(panel.get_global_rect()), "popup must fit inside viewport")
            var skills := content.get_node("CombatSkillsRow") as Control
            assert(not panel.get_global_rect().intersects(skills.get_global_rect()), "popup must not cover skill commands")
    for button: Button in content.find_children("*", "Button", true, false):
        if button.is_visible_in_tree() and not button.is_queued_for_deletion():
            assert(main.get_viewport_rect().encloses(button.get_global_rect()), "visible command clipped in " + state + ": " + button.text)
    DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output))
    if DisplayServer.get_name() == "headless":
        return
    await _settle()
    var rendered := root.get_texture().get_image()
    assert(rendered != null, "capture must use the actual viewport")
    assert(rendered.get_width() <= resolution.x and rendered.get_height() <= resolution.y, "letterboxed viewport must fit requested window")
    assert(absf(float(rendered.get_width()) / rendered.get_height() - 1280.0 / 720.0) < 0.01, "keep the actual canvas aspect instead of resizing evidence")
    var filename := "%s_%dx%d.png" % [state, resolution.x, resolution.y]
    assert(rendered.save_png(output + "/" + filename) == OK)
    captures.append({"file":filename, "window_size":[resolution.x,resolution.y], "rendered_size":[rendered.get_width(),rendered.get_height()]})
