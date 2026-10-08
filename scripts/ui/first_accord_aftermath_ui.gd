extends Control

var world: FirstAccordPlayableWorld
var rows: VBoxContainer
var feedback: Label
var continue_button: Button

func _ready() -> void:
    var shade := ColorRect.new()
    shade.color = Color(0.02, 0.02, 0.03, 0.9)
    shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(shade)
    var margin := MarginContainer.new()
    margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    for side in ["left", "right", "top", "bottom"]:
        margin.add_theme_constant_override("margin_" + side, 32)
    add_child(margin)
    var scroll := ScrollContainer.new()
    margin.add_child(scroll)
    rows = VBoxContainer.new()
    rows.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    rows.add_theme_constant_override("separation", 16)
    scroll.add_child(rows)
    refresh()

func refresh() -> void:
    for child in rows.get_children():
        rows.remove_child(child)
        child.queue_free()
    var resolved: Dictionary = world.pending_aftermath.get("campaign", {}).get("dungeon", {})
    var outcome := str(resolved.get("outcome", ""))
    var title := Label.new()
    title.text = {"victory":"Victoire", "cleared":"Victoire", "retreat":"Retraite", "defeat":"Défaite"}.get(outcome, "Résultat du combat")
    title.add_theme_font_size_override("font_size", 28)
    rows.add_child(title)
    var loot: Dictionary = resolved.get("rewards", {})
    var reward := Label.new()
    reward.text = "Butin de la salle : %d or · %d matériaux · %d essence\nCe butin sera sécurisé à l’extraction." % [int(loot.get("gold", 0)), int(loot.get("materials", 0)), int(loot.get("essence", 0))]
    reward.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    rows.add_child(reward)
    var options := world.runtime.recruitment_options()
    for index in options.size():
        var candidate: Dictionary = options[index]
        if bool(candidate.get("resolved", false)):
            continue
        var name_label := Label.new()
        name_label.text = "Rémanence · " + str(candidate.get("name", "Adversaire"))
        rows.add_child(name_label)
        var choices := HBoxContainer.new()
        rows.add_child(choices)
        for action in ["recruit", "spare", "leave"]:
            var button := Button.new()
            button.text = {"recruit":"Recruter", "spare":"Épargner", "leave":"Laisser"}[action]
            button.custom_minimum_size = Vector2(140, 48)
            button.set_meta("candidate_index", index)
            button.set_meta("decision", action)
            var captured_index := index
            var captured_action: String = action
            button.pressed.connect(func() -> void:
                var result := world.resolve_aftermath_decision(captured_index, captured_action)
                refresh()
                feedback.text = "Décision enregistrée." if bool(result.get("ok", false)) else "Les conditions de recrutement ne sont pas réunies. Choisissez une autre décision.")
            choices.add_child(button)
    feedback = Label.new()
    feedback.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    rows.add_child(feedback)
    var save := Button.new()
    save.text = "SAUVEGARDER"
    save.custom_minimum_size = Vector2(200, 48)
    save.pressed.connect(func() -> void:
        world.capture_state()
        feedback.text = "Partie sauvegardée." if SaveManager.save_game() else "Échec de sauvegarde.")
    rows.add_child(save)
    continue_button = Button.new()
    continue_button.text = "RETOURNER AU DONJON"
    continue_button.custom_minimum_size = Vector2(200, 48)
    continue_button.disabled = world.unresolved_aftermath() > 0
    continue_button.pressed.connect(world.dismiss_aftermath)
    rows.add_child(continue_button)
