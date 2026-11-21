extends SceneTree

const ENEMIES_PATH := "res://data/enemies.json"
const CATALOG_PATH := "res://data/bestiary_catalog.json"

func _initialize() -> void:
	call_deferred("_validate")

func _validate() -> void:
	var errors: Array[String] = []
	var enemies_value: Variant = _read_json(ENEMIES_PATH, errors)
	var catalog_value: Variant = _read_json(CATALOG_PATH, errors)
	if typeof(enemies_value) != TYPE_ARRAY or typeof(catalog_value) != TYPE_DICTIONARY:
		_fail(errors)
		return

	var enemies: Array = enemies_value
	var catalog: Dictionary = catalog_value
	var by_id: Dictionary = {}
	for enemy in enemies:
		if typeof(enemy) != TYPE_DICTIONARY:
			errors.append("Entrée ennemi non dictionnaire")
			continue
		var id := int(enemy.get("id", -1))
		if id < 1 or by_id.has(id):
			errors.append("ID ennemi absent ou dupliqué: %s" % id)
		else:
			by_id[id] = enemy
		if str(enemy.get("art_path", "")).is_empty():
			errors.append("Image manquante pour l’ennemi #%s" % id)

	if enemies.size() != 92:
		errors.append("92 entrées attendues, %s trouvées" % enemies.size())
	var runtime: Array = catalog.get("runtime_entries", [])
	var references: Array = catalog.get("archived_references", [])
	if runtime.size() != enemies.size():
		errors.append("Catalogue runtime (%s) différent de data/enemies.json (%s)" % [runtime.size(), enemies.size()])
	if references.size() != 61:
		errors.append("61 planches archivées attendues, %s trouvées" % references.size())

	for reference in references:
		if typeof(reference) != TYPE_DICTIONARY:
			errors.append("Référence d’archive non dictionnaire")
			continue
		var linked_id := int(reference.get("runtime_enemy_id", -1))
		if not by_id.has(linked_id):
			errors.append("Planche %s liée à un ID runtime absent: %s" % [reference.get("reference_id", "?"), linked_id])

	var checked_images := 0
	for entry in runtime:
		if typeof(entry) != TYPE_DICTIONARY:
			errors.append("Entrée de catalogue runtime non dictionnaire")
			continue
		var id := int(entry.get("enemy_id", -1))
		if not by_id.has(id):
			errors.append("Catalogue runtime lié à un ID absent: %s" % id)
			continue
		var path := str(entry.get("source_image", ""))
		var expected_sha := str(entry.get("image_sha256", ""))
		if not _verify_image(path, expected_sha, errors):
			continue
		checked_images += 1

	if errors.is_empty():
		print("Bestiaire Godot validé: %d monstres, %d planches, %d images chargées et SHA-256 vérifiées." % [enemies.size(), references.size(), checked_images])
		quit(0)
	else:
		_fail(errors)

func _read_json(path: String, errors: Array[String]) -> Variant:
	if not FileAccess.file_exists(path):
		errors.append("Fichier manquant: " + path)
		return null
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if parsed == null:
		errors.append("JSON invalide: " + path)
	return parsed

func _verify_image(path: String, expected_sha: String, errors: Array[String]) -> bool:
	if path.is_empty() or not FileAccess.file_exists(path):
		errors.append("Image absente: " + path)
		return false
	var bytes := FileAccess.get_file_as_bytes(path)
	var context := HashingContext.new()
	if context.start(HashingContext.HASH_SHA256) != OK or context.update(bytes) != OK:
		errors.append("Impossible de calculer SHA-256: " + path)
		return false
	var measured := context.finish().hex_encode()
	if measured != expected_sha:
		errors.append("SHA-256 différente: " + path)
		return false
	var image := Image.new()
	if image.load(path) != OK:
		errors.append("Image illisible par Godot: " + path)
		return false
	return true

func _fail(errors: Array[String]) -> void:
	for error in errors:
		push_error(error)
	quit(1)
