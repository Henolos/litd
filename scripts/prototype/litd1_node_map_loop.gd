extends Control

# Playable but deliberately provisional vertical slice: guild -> node map -> combat -> guild.
# No canon heroes, art, recruitment, campaign save, or Game Over persistence are simulated.
const ROUTE_PATH := "res://data/prototypes/litd1_node_map_loop.json"
const HERO_HP := 12
const ENEMY_HP := 8
const ATTACK_DAMAGE := 4
const ENEMY_DAMAGE := 1

var phase := "guild"
var route: Dictionary = {}
var nodes_by_id: Dictionary = {}
var current_node_id := ""
var visited_node_ids: Array[String] = []
var completed_node_ids: Array[String] = []
var status_message := "Prototype jouable — noms, chiffres et rencontre provisoires."

var party: Array[Dictionary] = []
var enemies: Array[Dictionary] = []
var actor_index := 0
var target_index := -1
var round_number := 1
var combat_log: Array[String] = []

var _pages: Dictionary = {}
var _map_buttons: VBoxContainer
var _map_status: Label
var _node_title: Label
var _node_description: Label
var _node_resolve_button: Button
var _combat_status: Label
var _party_label: Label
var _enemy_label: Label
var _target_buttons: HBoxContainer
var _attack_button: Button
var _guard_button: Button
var _combat_log_label: Label
var _status_label: Label

func _ready() -> void:
	if not _load_route():
		phase = "error"
	_build_ui()
	_render()

func _load_route() -> bool:
	if not FileAccess.file_exists(ROUTE_PATH):
		push_error("Données de parcours absentes : " + ROUTE_PATH)
		return false
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(ROUTE_PATH))
	if not parsed is Dictionary or not parsed.get("nodes", []) is Array:
		push_error("Données de parcours invalides : " + ROUTE_PATH)
		return false
	route = parsed
	nodes_by_id.clear()
	for item in route["nodes"]:
		if not item is Dictionary or not item.has("id"):
			return false
		var node_id := String(item["id"])
		if nodes_by_id.has(node_id):
			push_error("Identifiant de nœud dupliqué : " + node_id)
			return false
		nodes_by_id[node_id] = item
	var start_id := String(route.get("start_node_id", ""))
	if not nodes_by_id.has(start_id):
		push_error("Nœud de départ inconnu : " + start_id)
		return false
	for node_value in route["nodes"]:
		for next_id_value in node_value.get("next", []):
			if not nodes_by_id.has(String(next_id_value)):
				push_error("Lien de nœud inconnu : " + String(next_id_value))
				return false
	return true

func start_expedition() -> bool:
	if phase != "guild" or nodes_by_id.is_empty():
		return false
	current_node_id = String(route["start_node_id"])
	visited_node_ids = [current_node_id]
	completed_node_ids.clear()
	status_message = "Expédition de démonstration commencée."
	phase = "map"
	_render()
	return true

func available_node_ids() -> Array[String]:
	var result: Array[String] = []
	if not nodes_by_id.has(current_node_id):
		return result
	for value in nodes_by_id[current_node_id].get("next", []):
		var node_id := String(value)
		if not result.has(node_id):
			result.append(node_id)
	for node_id in visited_node_ids:
		if not result.has(node_id):
			result.append(node_id)
	return result

func select_node(node_id: String) -> bool:
	if phase != "map" or not nodes_by_id.has(node_id) or not available_node_ids().has(node_id):
		return false
	current_node_id = node_id
	if not visited_node_ids.has(node_id):
		visited_node_ids.append(node_id)
	var node: Dictionary = nodes_by_id[node_id]
	if completed_node_ids.has(node_id):
		status_message = "Nœud déjà résolu : vous pouvez le revoir sans rejouer son événement."
		phase = "node_complete"
	elif String(node.get("kind", "")) == "combat":
		_start_combat()
	elif String(node.get("kind", "")) == "rest":
		phase = "node_event"
	elif String(node.get("kind", "")) == "return":
		status_message = "Retour au hub de test. Aucune sauvegarde de campagne n'est écrite."
		phase = "guild"
	else:
		status_message = "Nœud découvert : " + String(node.get("label", node_id))
		phase = "map"
	_render()
	return true

func resolve_node_event() -> bool:
	if phase != "node_event" or current_node_id.is_empty():
		return false
	if not completed_node_ids.has(current_node_id):
		completed_node_ids.append(current_node_id)
	status_message = "Nœud de repos de test résolu ; aucun soin réel n'a été appliqué."
	phase = "map"
	_render()
	return true

func return_to_map() -> bool:
	if phase != "node_complete":
		return false
	phase = "map"
	_render()
	return true

func select_target(index: int) -> bool:
	if phase != "combat" or index < 0 or index >= enemies.size() or int(enemies[index]["hp"]) <= 0:
		return false
	target_index = index
	_render()
	return true

func attack() -> bool:
	if phase != "combat" or target_index < 0 or target_index >= enemies.size() or int(enemies[target_index]["hp"]) <= 0:
		return false
	var actor_name := String(party[actor_index]["name"])
	var enemy_name := String(enemies[target_index]["name"])
	enemies[target_index]["hp"] = maxi(0, int(enemies[target_index]["hp"]) - ATTACK_DAMAGE)
	_record("%s frappe %s : -%d PV." % [actor_name, enemy_name, ATTACK_DAMAGE])
	if int(enemies[target_index]["hp"]) == 0:
		_record("%s est hors combat." % enemy_name)
	target_index = -1
	_advance_combat()
	return true

func guard() -> bool:
	if phase != "combat":
		return false
	party[actor_index]["guard"] = true
	_record(String(party[actor_index]["name"]) + " se protège pour ce tour.")
	target_index = -1
	_advance_combat()
	return true

func _start_combat() -> void:
	party = [
		{"id": "prototype_protagonist", "name": "Protagoniste d'essai", "hp": HERO_HP, "guard": false},
		{"id": "fixture_ally_1", "name": "Allié de test A", "hp": HERO_HP, "guard": false},
		{"id": "fixture_ally_2", "name": "Allié de test B", "hp": HERO_HP, "guard": false},
		{"id": "fixture_ally_3", "name": "Allié de test C", "hp": HERO_HP, "guard": false}
	]
	enemies = [
		{"id": "fixture_enemy_a", "name": "Menace d'essai A", "hp": ENEMY_HP},
		{"id": "fixture_enemy_b", "name": "Menace d'essai B", "hp": ENEMY_HP}
	]
	actor_index = 0
	target_index = -1
	round_number = 1
	combat_log = ["Choisissez une cible, puis attaquez ou gardez."]
	phase = "combat"
	status_message = "Combat 2D au tour par tour — fixtures anonymes, règles provisoires."

func _advance_combat() -> void:
	if _all_down(enemies):
		if not completed_node_ids.has(current_node_id):
			completed_node_ids.append(current_node_id)
		status_message = "Victoire d'essai. Le nœud est résolu et peut être revisité."
		phase = "map"
		_render()
		return
	for index in range(actor_index + 1, party.size()):
		if int(party[index]["hp"]) > 0:
			actor_index = index
			_render()
			return
	_enemy_turn()
	if _all_down(party):
		status_message = "Défaite de la fixture. Le Game Over et la persistance de campagne ne sont pas raccordés à ce prototype."
		phase = "defeat"
	else:
		round_number += 1
		for index in range(party.size()):
			if int(party[index]["hp"]) > 0:
				actor_index = index
				break
	_render()

func _enemy_turn() -> void:
	for enemy in enemies:
		if int(enemy["hp"]) <= 0:
			continue
		var candidate := -1
		for index in range(party.size()):
			if int(party[index]["hp"]) > 0:
				candidate = index
				break
		if candidate < 0:
			return
		var damage := ENEMY_DAMAGE
		if bool(party[candidate]["guard"]):
			damage = 0
			party[candidate]["guard"] = false
		party[candidate]["hp"] = maxi(0, int(party[candidate]["hp"]) - damage)
		_record("%s attaque %s : -%d PV." % [enemy["name"], party[candidate]["name"], damage])

func _all_down(group: Array[Dictionary]) -> bool:
	for member in group:
		if int(member["hp"]) > 0:
			return false
	return true

func _record(message: String) -> void:
	combat_log.append(message)
	if combat_log.size() > 7:
		combat_log.pop_front()

func _build_ui() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var background := ColorRect.new()
	background.color = Color("111116")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(900, 0)
	panel.add_theme_stylebox_override("panel", _panel_style())
	center.add_child(panel)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 14)
	panel.add_child(content)
	var title := _label("LITD 1 · PARCOURS À NŒUDS", 27)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(title)
	var subtitle := _label("Prototype jouable · route, lieux et valeurs provisoires · aucune ressource artistique canonique utilisée", 14)
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(subtitle)
	_status_label = _label("", 15)
	_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(_status_label)
	_pages["guild"] = _new_page(content)
	_pages["map"] = _new_page(content)
	_pages["node"] = _new_page(content)
	_pages["combat"] = _new_page(content)
	_pages["defeat"] = _new_page(content)
	_build_guild_page(_pages["guild"])
	_build_map_page(_pages["map"])
	_build_node_page(_pages["node"])
	_build_combat_page(_pages["combat"])
	_build_defeat_page(_pages["defeat"])

func _new_page(parent: VBoxContainer) -> VBoxContainer:
	var page := VBoxContainer.new()
	page.add_theme_constant_override("separation", 12)
	parent.add_child(page)
	return page

func _build_guild_page(page: VBoxContainer) -> void:
	page.add_child(_label("GUILDE · point de départ de test", 21))
	page.add_child(_label("Le protagoniste est un repère de prototype, pas un personnage canonique.", 16))
	var start := Button.new()
	start.text = "Partir en expédition (prototype)"
	start.custom_minimum_size.y = 52
	start.pressed.connect(start_expedition)
	page.add_child(start)
	var return_to_hub := Button.new()
	return_to_hub.text = "Terminer le parcours"
	return_to_hub.pressed.connect(_return_to_guild)
	page.add_child(return_to_hub)

func _build_map_page(page: VBoxContainer) -> void:
	page.add_child(_label("CARTE À NŒUDS · itinéraire d'essai", 21))
	_map_status = _label("", 15)
	_map_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	page.add_child(_map_status)
	_map_buttons = VBoxContainer.new()
	_map_buttons.add_theme_constant_override("separation", 8)
	page.add_child(_map_buttons)

func _build_node_page(page: VBoxContainer) -> void:
	_node_title = _label("", 20)
	page.add_child(_node_title)
	_node_description = _label("", 16)
	_node_description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	page.add_child(_node_description)
	_node_resolve_button = Button.new()
	_node_resolve_button.text = "Continuer depuis cet abri de test"
	_node_resolve_button.pressed.connect(resolve_node_event)
	page.add_child(_node_resolve_button)
	var back := Button.new()
	back.text = "Retour à la carte"
	back.pressed.connect(return_to_map)
	page.add_child(back)

func _build_combat_page(page: VBoxContainer) -> void:
	_combat_status = _label("", 18)
	page.add_child(_combat_status)
	_party_label = _label("", 16)
	page.add_child(_party_label)
	_enemy_label = _label("", 16)
	page.add_child(_enemy_label)
	_target_buttons = HBoxContainer.new()
	_target_buttons.add_theme_constant_override("separation", 10)
	page.add_child(_target_buttons)
	for index in range(2):
		var target := Button.new()
		target.custom_minimum_size = Vector2(260, 48)
		target.pressed.connect(select_target.bind(index))
		_target_buttons.add_child(target)
	var actions := HBoxContainer.new()
	page.add_child(actions)
	_attack_button = Button.new()
	_attack_button.text = "Attaquer la cible"
	_attack_button.custom_minimum_size = Vector2(240, 50)
	_attack_button.pressed.connect(attack)
	actions.add_child(_attack_button)
	_guard_button = Button.new()
	_guard_button.text = "Garder"
	_guard_button.custom_minimum_size = Vector2(180, 50)
	_guard_button.pressed.connect(guard)
	actions.add_child(_guard_button)
	_combat_log_label = _label("", 14)
	_combat_log_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	page.add_child(_combat_log_label)

func _build_defeat_page(page: VBoxContainer) -> void:
	page.add_child(_label("FIN DU COMBAT D'ESSAI", 21))
	var note := _label("La défaite et la reprise avec le même protagoniste ne sont pas implémentées ici. Aucune règle de Game Over n'est simulée.", 16)
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	page.add_child(note)
	var return_button := Button.new()
	return_button.text = "Retourner au hub de test"
	return_button.pressed.connect(_return_to_guild)
	page.add_child(return_button)

func _return_to_guild() -> void:
	phase = "guild"
	_render()

func _render() -> void:
	if _pages.is_empty():
		return
	for key in _pages:
		_pages[key].visible = false
	if phase == "error":
		_status_label.text = "Erreur : la route du prototype n'a pas pu être chargée."
		return
	_status_label.text = status_message
	if phase == "guild":
		_pages["guild"].visible = true
	elif phase == "map":
		_pages["map"].visible = true
		_render_map()
	elif phase == "node_event" or phase == "node_complete":
		_pages["node"].visible = true
		_render_node()
	elif phase == "combat":
		_pages["combat"].visible = true
		_render_combat()
	elif phase == "defeat":
		_pages["defeat"].visible = true

func _render_map() -> void:
	_map_status.text = "Nœud courant : %s\nNœuds visités : %s" % [String(nodes_by_id[current_node_id].get("label", current_node_id)), ", ".join(PackedStringArray(visited_node_ids))]
	for child in _map_buttons.get_children():
		_map_buttons.remove_child(child)
		child.queue_free()
	for node_value in route["nodes"]:
		var node: Dictionary = node_value
		var node_id := String(node["id"])
		var accessible := available_node_ids().has(node_id)
		var visited := visited_node_ids.has(node_id)
		var label := String(node.get("label", node_id))
		if completed_node_ids.has(node_id):
			label += " · résolu"
		elif visited:
			label += " · visité"
		elif accessible:
			label += " · accessible"
		else:
			label += " · verrouillé"
		var button := Button.new()
		button.text = label
		button.disabled = not accessible
		button.custom_minimum_size.y = 42
		button.pressed.connect(select_node.bind(node_id))
		_map_buttons.add_child(button)

func _render_node() -> void:
	var node: Dictionary = nodes_by_id[current_node_id]
	_node_title.text = String(node.get("label", current_node_id))
	_node_description.text = status_message + "\n" + String(node.get("description", ""))
	_node_resolve_button.visible = phase == "node_event"

func _render_combat() -> void:
	_combat_status.text = "Tour %d · acteur : %s" % [round_number, String(party[actor_index]["name"])]
	var party_lines: Array[String] = []
	for index in range(party.size()):
		var member: Dictionary = party[index]
		party_lines.append("%s %s : %d/%d PV%s" % ["▶" if index == actor_index else "·", member["name"], member["hp"], HERO_HP, " [garde]" if member["guard"] else ""])
	_party_label.text = "Équipe fictive\n" + "   |   ".join(party_lines)
	var enemy_lines: Array[String] = []
	for index in range(enemies.size()):
		var enemy: Dictionary = enemies[index]
		enemy_lines.append("%s : %d/%d PV" % [enemy["name"], enemy["hp"], ENEMY_HP])
		var target_button: Button = _target_buttons.get_child(index)
		target_button.text = ("✓ " if index == target_index else "Viser ") + String(enemy["name"])
		target_button.disabled = int(enemy["hp"]) <= 0
	_enemy_label.text = "Adversaires provisoires\n" + "   |   ".join(enemy_lines)
	_attack_button.disabled = target_index < 0
	_guard_button.disabled = false
	_combat_log_label.text = "Journal\n" + "\n".join(combat_log)

func _label(text_value: String, size: int) -> Label:
	var label := Label.new()
	label.text = text_value
	label.add_theme_color_override("font_color", Color("e8dfc9"))
	label.add_theme_font_size_override("font_size", size)
	return label

func _panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("1c1b1f")
	style.border_color = Color("d3b675")
	style.set_border_width_all(2)
	style.set_content_margin_all(28)
	return style
