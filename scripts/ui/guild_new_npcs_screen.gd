extends Control
# Prototype isolé : aucun effet de soin, de quête ou d'affinité n'est simulé.
const NPC_PATH := "res://data/guild_new_npcs.json"
const RESEARCH_PATH := "res://data/guild_bestiary_research.json"
const PORTRAIT_PATHS := {
	"guild_tavern_keeper": "res://assets/characters/guild_npcs/tavernier_planche_validee.png",
	"guild_physician": "res://assets/characters/guild_npcs/medecin_planche_validee.png"
}
const HUB_PATH := "res://scenes/hub/game_hub.tscn"
const BESTIARY_PATH := "res://scenes/bestiary/bestiary_screen.tscn"

var characters: Array = []
var selection: OptionButton
var dialogue_label: Label
var details_label: Label
var portrait: TextureRect
var asset_label: Label
var research_label: Label

func _ready() -> void:
	var data := _load_dictionary(NPC_PATH)
	characters = data.get("characters", [])
	_build_ui()
	if not characters.is_empty():
		selection.select(0)
		_show_character(0)
	else:
		details_label.text = "Aucun personnage disponible."

func _load_dictionary(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		push_error("Données manquantes : " + path)
		return {}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("Données invalides : " + path)
		return {}
	return parsed

func _build_ui() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var background := ColorRect.new()
	background.color = Color("#111116")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(660, 440)
	center.add_child(panel)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 16)
	panel.add_child(content)
	var heading := Label.new()
	heading.text = "GUILDE · PERSONNAGES (PROTOTYPE)"
	heading.add_theme_font_size_override("font_size", 25)
	content.add_child(heading)
	selection = OptionButton.new()
	for npc in characters:
		selection.add_item(str(npc.get("display_name", "Personnage")))
	selection.item_selected.connect(_show_character)
	content.add_child(selection)
	portrait = TextureRect.new()
	portrait.custom_minimum_size = Vector2(240, 160)
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	content.add_child(portrait)
	asset_label = Label.new()
	asset_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(asset_label)
	details_label = Label.new()
	details_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(details_label)
	research_label = Label.new()
	research_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(research_label)
	dialogue_label = Label.new()
	dialogue_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(dialogue_label)
	var next_line := Button.new()
	next_line.text = "Écouter une autre réplique"
	next_line.pressed.connect(_next_dialogue)
	content.add_child(next_line)
	var bestiary_button := Button.new()
	bestiary_button.text = "Consulter le catalogue des créatures"
	bestiary_button.pressed.connect(func(): get_tree().change_scene_to_file(BESTIARY_PATH))
	content.add_child(bestiary_button)
	var back_button := Button.new()
	back_button.text = "Retour au hub"
	back_button.pressed.connect(func(): get_tree().change_scene_to_file(HUB_PATH))
	content.add_child(back_button)

var line_index := 0
func _show_character(index: int) -> void:
	if index < 0 or index >= characters.size():
		return
	line_index = 0
	var npc: Dictionary = characters[index]
	details_label.text = "%s\n%s\nServices prévus : %s" % [str(npc.get("role", "")), ", ".join(PackedStringArray(npc.get("traits", []))), ", ".join(PackedStringArray(npc.get("services", [])))]
	_update_portrait(npc)
	_update_research(npc)
	_update_dialogue()

func _update_portrait(npc: Dictionary) -> void:
	var path := str(PORTRAIT_PATHS.get(str(npc.get("id", "")), ""))
	portrait.texture = null
	if path.is_empty() or not FileAccess.file_exists(path):
		asset_label.text = "Planche validée non importée : image absente du dépôt."
		return
	var image := Image.new()
	if image.load(ProjectSettings.globalize_path(path)) != OK:
		asset_label.text = "Image présente mais illisible : vérifier le fichier PNG."
		return
	portrait.texture = ImageTexture.create_from_image(image)
	asset_label.text = "Planche de référence (affichage intégral, sans recadrage)."

func _update_research(npc: Dictionary) -> void:
	if str(npc.get("id", "")) != "guild_physician":
		research_label.text = "Affinité et quêtes spéciales : prévues, non encore actives."
		return
	var research := _load_dictionary(RESEARCH_PATH)
	if research.is_empty():
		research_label.text = "Recherche anatomique : données indisponibles."
		return
	research_label.text = "Recherche prévue pour le bestiaire du protagoniste ; maîtrise des compagnons individuelle. Rien n'est encore raccordé au runtime."

func _next_dialogue() -> void:
	if selection.selected < 0 or selection.selected >= characters.size():
		return
	var lines: Array = characters[selection.selected].get("dialogues", [])
	if lines.is_empty():
		return
	line_index = (line_index + 1) % lines.size()
	_update_dialogue()

func _update_dialogue() -> void:
	if selection.selected < 0 or selection.selected >= characters.size():
		return
	var npc: Dictionary = characters[selection.selected]
	var lines: Array = npc.get("dialogues", [])
	if lines.is_empty():
		dialogue_label.text = "Aucun dialogue."
		return
	var line: Dictionary = lines[line_index]
	dialogue_label.text = "%s : « %s »" % [str(line.get("speaker", "")), str(line.get("text", ""))]
