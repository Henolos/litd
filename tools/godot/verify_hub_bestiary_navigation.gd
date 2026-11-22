extends SceneTree

const HUB_SCENE := "res://scenes/hub/game_hub.tscn"
const BESTIARY_SCENE := "res://scenes/bestiary/bestiary_screen.tscn"

func _initialize() -> void:
	call_deferred("_verify_navigation")

func _verify_navigation() -> void:
	var hub := load(HUB_SCENE).instantiate() as Control
	if hub == null:
		_fail("Impossible de charger la scène du hub")
		return
	root.add_child(hub)
	current_scene = hub
	await process_frame
	var bestiary_button := _find_button("Ouvrir le bestiaire")
	if bestiary_button == null:
		_fail("Bouton du bestiaire absent dans le hub")
		return
	bestiary_button.pressed.emit()
	await process_frame
	if current_scene == null or current_scene.scene_file_path != BESTIARY_SCENE:
		_fail("Le bouton du hub n’a pas ouvert le bestiaire")
		return
	var hub_button := _find_button("Retour au hub")
	if hub_button == null:
		_fail("Bouton de retour au hub absent dans le bestiaire")
		return
	hub_button.pressed.emit()
	await process_frame
	if current_scene == null or current_scene.scene_file_path != HUB_SCENE:
		_fail("Le retour depuis le bestiaire n’a pas rouvert le hub")
		return
	print("Navigation hub ↔ bestiaire validée.")
	quit(0)

func _find_button(prefix: String) -> Button:
	if current_scene == null:
		return null
	for node in current_scene.find_children("*", "Button", true, false):
		var button := node as Button
		if button.text.begins_with(prefix):
			return button
	return null

func _fail(message: String) -> void:
	push_error(message)
	quit(1)
