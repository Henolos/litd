extends Control

const CATALOG_PATH := "res://data/bestiary_catalog.json"
const BACKGROUND := Color("#111116")
const PANEL := Color("#1c1b1f")
const GOLD := Color("#d3b675")
const BONE := Color("#e8dfc9")
const MUTED := Color("#a79e90")

var catalog: Dictionary = {}
var rows: Array[Dictionary] = []
var displayed_rows: Array[Dictionary] = []
var image_cache: Dictionary = {}
var filter_box: OptionButton
var search_box: LineEdit
var item_list: ItemList
var title_label: Label
var status_label: Label
var portrait: TextureRect
var reference_label: Label
var zoom_button: Button

func _ready() -> void:
	catalog = _load_catalog()
	_build_interface()
	_apply_filter()

func _load_catalog() -> Dictionary:
	if DataLoader.bestiary_catalog is Dictionary and not DataLoader.bestiary_catalog.is_empty():
		return DataLoader.bestiary_catalog
	if not FileAccess.file_exists(CATALOG_PATH):
		push_error("Catalogue bestiaire manquant: " + CATALOG_PATH)
		return {}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(CATALOG_PATH))
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("Catalogue bestiaire invalide: " + CATALOG_PATH)
		return {}
	return parsed

func _build_interface() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var root := VBoxContainer.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_theme_constant_override("separation", 12)
	root.add_theme_color_override("font_color", BONE)
	root.offset_left = 24
	root.offset_top = 18
	root.offset_right = -24
	root.offset_bottom = -18
	add_child(root)

	var header := HBoxContainer.new()
	root.add_child(header)
	var heading := Label.new()
	heading.text = "BESTIAIRE"
	heading.add_theme_font_size_override("font_size", 28)
	heading.add_theme_color_override("font_color", GOLD)
	heading.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(heading)
	var count := Label.new()
	count.text = "%d monstres · %d planches" % [catalog.get("runtime_entries", []).size(), catalog.get("archived_references", []).size()]
	count.add_theme_color_override("font_color", MUTED)
	header.add_child(count)

	var toolbar := HBoxContainer.new()
	root.add_child(toolbar)
	filter_box = OptionButton.new()
	filter_box.add_item("Tout le catalogue")
	filter_box.add_item("Monstres du jeu")
	filter_box.add_item("Planches d’archive")
	filter_box.add_item("Références grecques, japonaises et nordiques")
	filter_box.add_item("Mythologies du monde")
	filter_box.add_item("Monstres communs")
	filter_box.item_selected.connect(_on_filter_changed)
	toolbar.add_child(filter_box)
	search_box = LineEdit.new()
	search_box.placeholder_text = "Rechercher un monstre ou une mythologie…"
	search_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	search_box.text_changed.connect(_apply_filter)
	toolbar.add_child(search_box)

	var split := HSplitContainer.new()
	split.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(split)
	var list_panel := PanelContainer.new()
	list_panel.custom_minimum_size.x = 330
	list_panel.add_theme_stylebox_override("panel", _panel_style(PANEL))
	split.add_child(list_panel)
	item_list = ItemList.new()
	item_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	item_list.add_theme_color_override("font_color", BONE)
	item_list.add_theme_color_override("font_selected_color", Color("#111116"))
	item_list.item_selected.connect(_on_item_selected)
	list_panel.add_child(item_list)

	var detail_panel := PanelContainer.new()
	detail_panel.add_theme_stylebox_override("panel", _panel_style(PANEL))
	split.add_child(detail_panel)
	var detail := VBoxContainer.new()
	detail.add_theme_constant_override("separation", 10)
	detail_panel.add_child(detail)
	title_label = Label.new()
	title_label.add_theme_font_size_override("font_size", 22)
	title_label.add_theme_color_override("font_color", GOLD)
	detail.add_child(title_label)
	status_label = Label.new()
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status_label.add_theme_color_override("font_color", MUTED)
	detail.add_child(status_label)

	var center := CenterContainer.new()
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	detail.add_child(center)
	var ratio_frame := AspectRatioContainer.new()
	ratio_frame.ratio = 0.75
	ratio_frame.stretch_mode = AspectRatioContainer.STRETCH_FIT
	ratio_frame.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ratio_frame.size_flags_vertical = Control.SIZE_EXPAND_FILL
	ratio_frame.custom_minimum_size = Vector2(300, 400)
	ratio_frame.add_theme_stylebox_override("panel", _panel_style(Color("#101014")))
	center.add_child(ratio_frame)
	portrait = TextureRect.new()
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	ratio_frame.add_child(portrait)

	reference_label = Label.new()
	reference_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	reference_label.add_theme_color_override("font_color", BONE)
	detail.add_child(reference_label)
	zoom_button = Button.new()
	zoom_button.text = "Consulter la planche en grand"
	zoom_button.pressed.connect(_open_large_image)
	detail.add_child(zoom_button)

func _panel_style(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = Color("#78613b")
	style.set_border_width_all(1)
	style.set_content_margin_all(12)
	return style

func _apply_filter(_unused: Variant = null) -> void:
	rows.clear()
	for entry in catalog.get("runtime_entries", []):
		var row: Dictionary = entry.duplicate(true)
		row["kind"] = "runtime"
		rows.append(row)
	for entry in catalog.get("archived_references", []):
		var row: Dictionary = entry.duplicate(true)
		row["kind"] = "archive"
		rows.append(row)

	var selected_filter := filter_box.selected if is_instance_valid(filter_box) else 0
	var query := search_box.text.strip_edges().to_lower() if is_instance_valid(search_box) else ""
	displayed_rows.clear()
	item_list.clear()
	for row in rows:
		if not _matches_filter(row, selected_filter):
			continue
		var searchable := (str(row.get("name", "")) + " " + str(row.get("culture", "")) + " " + str(row.get("group", ""))).to_lower()
		if not query.is_empty() and not searchable.contains(query):
			continue
		var prefix := "JEU" if row["kind"] == "runtime" else "ARCHIVE"
		var text := "%s · %s" % [prefix, row.get("name", "Sans nom")]
		if row["kind"] == "runtime":
			text = "%s · %02d · %s" % [prefix, row.get("enemy_id", 0), row.get("name", "Sans nom")]
		elif not str(row.get("culture", "")).is_empty():
			text += " (%s)" % row["culture"]
		item_list.add_item(text)
		displayed_rows.append(row)
	if not displayed_rows.is_empty():
		item_list.select(0)
		_show_row(0)
	else:
		title_label.text = "Aucun résultat"
		status_label.text = "Modifie le filtre ou la recherche."
		portrait.texture = null
		reference_label.text = ""
		zoom_button.disabled = true

func _matches_filter(row: Dictionary, selected_filter: int) -> bool:
	match selected_filter:
		1: return row.get("kind") == "runtime"
		2: return row.get("kind") == "archive"
		3: return row.get("group") == "folklore_greek_japanese_nordic"
		4: return row.get("group") == "world_mythologies"
		5: return row.get("group") == "common_creatures"
		_: return true

func _on_filter_changed(_index: int) -> void:
	_apply_filter()

func _on_item_selected(index: int) -> void:
	_show_row(index)

func _show_row(index: int) -> void:
	if index < 0 or index >= displayed_rows.size():
		return
	var row: Dictionary = displayed_rows[index]
	var path := str(row.get("source_image", row.get("source_path", "")))
	portrait.texture = _load_image(path)
	zoom_button.disabled = portrait.texture == null
	title_label.text = str(row.get("name", "Sans nom"))
	if row.get("kind") == "runtime":
		var ref_status := "Référence canonique associée par nom; contrôle visuel à faire." if row.get("reference_id") else "Référence artistique canonique non associée."
		status_label.text = "Monstre runtime #%02d · image actuelle à contrôler · emplacement d’affichage 3:4" % int(row.get("enemy_id", 0))
		reference_label.text = "%s\n%s" % [ref_status, str(row.get("reference_id", "Aucune référence associée"))]
	else:
		status_label.text = "%s · %s · planche validée · affichée dans un cadre 3:4 (source entière conservée)" % [str(row.get("group", "Archive")), str(row.get("culture", ""))]
		reference_label.text = "Source : %s" % path

func _load_image(path: String) -> Texture2D:
	if image_cache.has(path):
		return image_cache[path]
	if path.is_empty() or not ResourceLoader.exists(path):
		push_warning("Image de bestiaire inaccessible: " + path)
		return null
	var resource := load(path)
	if resource is Texture2D:
		image_cache[path] = resource
		return resource
	return null

func _open_large_image() -> void:
	var selected := item_list.get_selected_items()
	if selected.is_empty() or selected[0] >= displayed_rows.size():
		return
	var row: Dictionary = displayed_rows[selected[0]]
	var path := str(row.get("source_image", row.get("source_path", "")))
	var texture := _load_image(path)
	if texture == null:
		return
	var popup := Window.new()
	popup.title = str(row.get("name", "Bestiaire"))
	popup.size = Vector2i(1100, 760)
	popup.position = Vector2i((DisplayServer.screen_get_size().x - 1100) / 2, (DisplayServer.screen_get_size().y - 760) / 2)
	popup.close_requested.connect(popup.queue_free)
	var view := TextureRect.new()
	view.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	view.texture = texture
	view.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	view.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	popup.add_child(view)
	add_child(popup)
	popup.popup()
