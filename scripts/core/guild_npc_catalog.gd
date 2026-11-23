extends RefCounted
## Read-only guild NPC catalog. Does not replace existing game systems.
const CATALOG_PATH := "res://data/guild_npcs.json"

static func load_catalog() -> Dictionary:
	if not FileAccess.file_exists(CATALOG_PATH):
		push_warning("Guild NPC catalog missing: " + CATALOG_PATH)
		return {}
	var file := FileAccess.open(CATALOG_PATH, FileAccess.READ)
	if file == null:
		push_warning("Cannot open guild NPC catalog")
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		push_warning("Invalid guild NPC catalog JSON")
		return {}
	return parsed

static func get_character(character_id: String) -> Dictionary:
	var catalog := load_catalog()
	var characters: Variant = catalog.get("characters", [])
	if typeof(characters) != TYPE_ARRAY:
		return {}
	for entry in characters:
		if typeof(entry) == TYPE_DICTIONARY and entry.get("id", "") == character_id:
			return entry
	return {}

static func load_portrait(character_id: String) -> Texture2D:
	var entry := get_character(character_id)
	var path: Variant = entry.get("art_path", null)
	if typeof(path) != TYPE_STRING or path.is_empty():
		return null
	if not ResourceLoader.exists(path):
		push_warning("Guild NPC portrait unavailable: " + path)
		return null
	var resource: Resource = load(path)
	if resource is Texture2D:
		return resource
	return null

static func load_concept_art(character_id: String) -> Texture2D:
	var entry := get_character(character_id)
	var path: Variant = entry.get("concept_art_path", null)
	if typeof(path) != TYPE_STRING or path.is_empty():
		return null
	if not ResourceLoader.exists(path):
		push_warning("Guild NPC concept art unavailable: " + path)
		return null
	var resource: Resource = load(path)
	if resource is Texture2D:
		return resource
	return null
