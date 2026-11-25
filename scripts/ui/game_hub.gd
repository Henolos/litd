extends Control

const BESTIARY_SCENE := "res://scenes/bestiary/bestiary_screen.tscn"
const NODE_MAP_LOOP_SCENE := "res://scenes/prototype/litd1_node_map_loop.tscn"
const BACKGROUND := Color("#111116")
const PANEL := Color("#1c1b1f")
const GOLD := Color("#d3b675")
const BONE := Color("#e8dfc9")
const MUTED := Color("#a79e90")

func _ready() -> void:
	_build_interface()

func _build_interface() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var background := ColorRect.new()
	background.color = BACKGROUND
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(560, 0)
	panel.add_theme_stylebox_override("panel", _panel_style())
	center.add_child(panel)

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 18)
	content.add_theme_color_override("font_color", BONE)
	panel.add_child(content)

	var title := Label.new()
	title.text = "LIGHT IN THE DARK"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 34)
	title.add_theme_color_override("font_color", GOLD)
	content.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "LITD 1 · HUB DE DÉMARRAGE"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 16)
	subtitle.add_theme_color_override("font_color", MUTED)
	content.add_child(subtitle)

	var divider := HSeparator.new()
	content.add_child(divider)

	var start_button := Button.new()
	start_button.text = "Nouvelle partie · boucle de jeu à construire"
	start_button.disabled = true
	start_button.custom_minimum_size.y = 54
	content.add_child(start_button)

	var prototype_button := Button.new()
	prototype_button.text = "Tester le parcours à nœuds (prototype)"
	prototype_button.custom_minimum_size.y = 50
	prototype_button.pressed.connect(_open_node_map_loop)
	content.add_child(prototype_button)

	var bestiary_button := Button.new()
	bestiary_button.text = _bestiary_button_text()
	bestiary_button.custom_minimum_size.y = 54
	bestiary_button.pressed.connect(_open_bestiary)
	content.add_child(bestiary_button)

	var qa_button := Button.new()
	qa_button.text = "Laboratoire visuel · héros et Guilde"
	qa_button.custom_minimum_size.y = 54
	qa_button.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/tests/playtest_gallery.tscn"))
	content.add_child(qa_button)

	var explanation := Label.new()
	explanation.text = "La campagne reste à construire. Un parcours de test à nœuds est disponible en prototype."
	explanation.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	explanation.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	explanation.add_theme_color_override("font_color", MUTED)
	content.add_child(explanation)

	var quit_button := Button.new()
	quit_button.text = "Quitter"
	quit_button.custom_minimum_size.y = 44
	quit_button.pressed.connect(get_tree().quit)
	content.add_child(quit_button)

func _bestiary_button_text() -> String:
	var catalog: Dictionary = DataLoader.bestiary_catalog
	var monsters: int = catalog.get("runtime_entries", []).size()
	var plates: int = catalog.get("archived_references", []).size()
	return "Ouvrir le bestiaire · %d monstres · %d planches" % [monsters, plates]

func _open_bestiary() -> void:
	get_tree().change_scene_to_file(BESTIARY_SCENE)

func _open_node_map_loop() -> void:
	get_tree().change_scene_to_file(NODE_MAP_LOOP_SCENE)

func _panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = PANEL
	style.border_color = GOLD
	style.set_border_width_all(2)
	style.set_content_margin_all(28)
	return style
