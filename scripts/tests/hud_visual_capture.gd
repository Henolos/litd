extends SceneTree

const OUTPUT := "res://reports/hud_visual/captures"
var captures: Array[Dictionary] = []

func _initialize() -> void:
    call_deferred("_capture_hud")

func _capture_hud() -> void:
    root.content_scale_size = Vector2i(1280, 720)
    root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
    var main := load("res://scenes/Main.tscn").instantiate() as Control
    root.add_child(main)
    await _settle()
    main.call("show_screen", "combat_sandbox")
    await _settle()
    var runtime: RefCounted = main.get("_sandbox")
    var actions: Array = runtime.call("available_actions")
    var action_id := ""
    for action: Dictionary in actions:
        if str(action.get("target", "")).begins_with("enemy"):
            action_id = str(action.get("id", ""))
            break
    assert(action_id != "", "capture requires a real enemy action")
    var before := {"heroes":runtime.get("heroes").duplicate(true), "enemies":runtime.get("enemies").duplicate(true)}
    for resolution: Vector2i in [Vector2i(1280, 720), Vector2i(1920, 1080)]:
        root.size = resolution
        await _settle()
        main.set("_sandbox_selected_action", "")
        main.call("show_screen", "combat_sandbox")
        await _settle()
        _check_desktop_controls(main)
        await _save("overview", resolution)
        main.call("_sandbox_select_action", action_id)
        main.call("_sandbox_select_target", 0)
        main.call("_sandbox_select_zone", "torso")
        await _settle()
        var preview: Dictionary = main.call("_sandbox_build_preview_v51")
        assert(bool(preview.get("ready", false)), "prepared action must be valid")
        assert(preview.has("hit_chance") and preview.has("damage_on_hit"), "capture must show canonical preview")
        _check_desktop_controls(main)
        await _save("prepared", resolution)
        main.call("_sandbox_open_inspection", "hero", 0)
        await _save("sandbox_inspection", resolution)
        main.call("_sandbox_close_inspection")
        var inspector := root.get_node("CombatantInspectionUI")
        inspector.call("open_detail", runtime.call("active_hero"), false)
        await _settle()
        var close: Button = inspector.get("detail_close_button")
        assert(close.has_focus(), "inspection must focus its close button")
        await _save("contextual_inspection", resolution)
        inspector.call("close_detail")
    assert(before.heroes == runtime.get("heroes") and before.enemies == runtime.get("enemies"), "visual preparation must not execute combat")
    var manifest := {"revision":OS.get_environment("LITD_HUD_REVISION"), "renderer":RenderingServer.get_video_adapter_name(), "logical_size":[1280,720], "captures":captures, "scope":"Rendered PC viewport and simulated input; physical-device playtest is separate."}
    var file := FileAccess.open(OUTPUT + "/manifest.json", FileAccess.WRITE)
    file.store_string(JSON.stringify(manifest, "  ") + "\n")
    main.queue_free()
    await process_frame
    print("HUD_VISUAL_CAPTURE_OK captures=" + str(captures.size()))
    quit(0)

func _settle() -> void:
    for _frame in range(4):
        await process_frame
    await RenderingServer.frame_post_draw

func _check_desktop_controls(main: Control) -> void:
    var content: Control = main.get("content")
    var result: Control = content.get_node("SandboxResultPanelV50")
    var viewport_rect := root.get_visible_rect()
    var zones := 0
    var ranks := 0
    for button: Button in content.find_children("*", "Button", true, false):
        if button.is_queued_for_deletion() or not button.is_visible_in_tree():
            continue
        var rect := button.get_global_rect()
        if str(button.name).begins_with("SandboxRankR"):
            ranks += 1
            assert(viewport_rect.encloses(rect), "formation control must fit inside PC viewport")
        if button.text.trim_prefix("◆ ") in ["Tête", "Torse", "Bras gauche", "Bras droit", "Jambe gauche", "Jambe droite"]:
            zones += 1
            assert(not rect.intersects(result.get_global_rect()), "feedback must not cover anatomical targeting")
        if button.name == "SandboxConfirmV51":
            assert(not rect.intersects(result.get_global_rect()), "feedback must not cover confirmation")
    assert(zones == 6 and ranks == 4, "all body zones and formation ranks must remain visible")

func _save(state: String, resolution: Vector2i) -> void:
    await _settle()
    var image := root.get_texture().get_image()
    assert(image != null and not image.is_empty(), "real rendered viewport is required")
    assert(image.get_width() == resolution.x and image.get_height() == resolution.y, "capture must match requested desktop resolution")
    DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT))
    var filename := "%s_%dx%d.png" % [state, resolution.x, resolution.y]
    assert(image.save_png(OUTPUT + "/" + filename) == OK, "capture must save successfully")
    captures.append({"state":state,"resolution":[resolution.x,resolution.y],"file":filename})
