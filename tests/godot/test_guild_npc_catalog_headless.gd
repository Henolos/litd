extends SceneTree

const CATALOG := preload("res://scripts/core/guild_npc_catalog.gd")
const EXPECTED := {
    "kelia_anzora": Vector2i(768, 1024),
    "lian_yue": Vector2i(768, 1024),
    "soleyman": Vector2i(768, 1024),
    "maitresse_armes": Vector2i(768, 1024),
    "wei_shan": Vector2i(768, 1024),
}
const EXPECTED_CONCEPT := {
    "han_lu": Vector2i(1536, 1024),
    "dr_mei_ling": Vector2i(1536, 1024),
}
var failures := 0

func _initialize() -> void:
    call_deferred("_run")

func _check(ok: bool, message: String) -> void:
    if not ok:
        failures += 1
        push_error(message)

func _run() -> void:
    for character_id: String in EXPECTED:
        var entry: Dictionary = CATALOG.get_character(character_id)
        _check(not entry.is_empty(), "Catalog entry is available: " + character_id)
        _check(bool(entry.get("art_verified_in_repository", false)), "Art is marked repository-verified: " + character_id)
        var texture: Texture2D = CATALOG.load_portrait(character_id)
        _check(texture != null, "Catalog portrait loads: " + character_id)
        if texture != null:
            var dimensions := Vector2i(texture.get_width(), texture.get_height())
            _check(dimensions == EXPECTED[character_id], "Catalog portrait dimensions: " + character_id)
            print("GUILD_NPC_CATALOG_OK %s %dx%d" % [character_id, dimensions.x, dimensions.y])
    for character_id: String in EXPECTED_CONCEPT:
        var entry: Dictionary = CATALOG.get_character(character_id)
        _check(not entry.is_empty(), "Catalog entry is available: " + character_id)
        _check(bool(entry.get("art_verified_in_repository", false)), "Concept art is repository-verified: " + character_id)
        _check(entry.get("art_path", null) == null, "Full concept sheet is not used as portrait: " + character_id)
        var concept: Texture2D = CATALOG.load_concept_art(character_id)
        _check(concept != null, "Catalog concept art loads: " + character_id)
        if concept != null:
            var dimensions := Vector2i(concept.get_width(), concept.get_height())
            _check(dimensions == EXPECTED_CONCEPT[character_id], "Concept art dimensions: " + character_id)
            print("GUILD_NPC_CONCEPT_OK %s %dx%d" % [character_id, dimensions.x, dimensions.y])
        _check(CATALOG.load_portrait(character_id) == null, "Dedicated portrait remains absent: " + character_id)
    if failures == 0:
        print("GUILD_NPC_CATALOG_HEADLESS_PASS")
    quit(1 if failures else 0)
