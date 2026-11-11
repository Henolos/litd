extends SceneTree

# Run against the exported Web PCK, not the source project. This catches
# dynamically loaded portraits omitted by an export filter or import failure.
func _initialize() -> void:
    for hero_id in ["mathilde", "marec", "anouk", "aurelien", "effrie", "lya"]:
        var path := "res://art/library/heroes/%s/reference.jpg" % hero_id
        var texture := load(path) as Texture2D
        if texture == null or texture.get_width() <= 0 or texture.get_height() <= 0:
            push_error("EXPORTED_HERO_ART_MISSING: %s" % path)
            quit(1)
            return
    print("EXPORTED_HERO_ART_OK: six official textures loaded from Web pack")
    quit(0)
