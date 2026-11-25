extends Control
## Isolated visual inspection scene. No saves, combat simulation, or roster assignment.
const HERO_CATALOG := "res://data/hero_portrait_catalog.json"
const GUILD_CATALOG := "res://data/guild_npcs.json"

func _ready() -> void:
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    var scroll := ScrollContainer.new()
    scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(scroll)
    var layout := VBoxContainer.new()
    layout.add_theme_constant_override("separation", 12)
    scroll.add_child(layout)
    var title := Label.new()
    title.text = "LITD 1 | Laboratoire visuel (sans sauvegarde)"
    title.add_theme_font_size_override("font_size", 28)
    layout.add_child(title)
    _section(layout, "Héros enregistrés (aucun quatuor de départ)", HERO_CATALOG, "heroes", "portrait")
    _section(layout, "Personnages de la Guilde", GUILD_CATALOG, "characters", "art_path")
    var back := Button.new()
    back.text = "Retour au hub"
    back.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/hub/game_hub.tscn"))
    layout.add_child(back)

func _section(parent: VBoxContainer, heading: String, path: String, key: String, image_key: String) -> void:
    var label := Label.new()
    label.text = heading
    label.add_theme_font_size_override("font_size", 21)
    parent.add_child(label)
    var file := FileAccess.open(path, FileAccess.READ)
    if file == null:
        _message(parent, "Catalogue introuvable : " + path)
        return
    var data: Variant = JSON.parse_string(file.get_as_text())
    if typeof(data) != TYPE_DICTIONARY or typeof(data.get(key)) != TYPE_ARRAY:
        _message(parent, "Catalogue invalide : " + path)
        return
    for item in data[key]:
        if typeof(item) != TYPE_DICTIONARY:
            continue
        var row := HBoxContainer.new()
        parent.add_child(row)
        var portrait := TextureRect.new()
        portrait.custom_minimum_size = Vector2(90, 110)
        portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
        portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
        row.add_child(portrait)
        var raw_path: String = str(item.get(image_key, ""))
        var resource_path := raw_path if raw_path.begins_with("res://") else "res://" + raw_path
        if ResourceLoader.exists(resource_path):
            var resource := load(resource_path)
            if resource is Texture2D:
                portrait.texture = resource
        var details := Label.new()
        details.text = str(item.get("name", item.get("id", "?"))) + (" | OK" if portrait.texture != null else " | PORTRAIT ABSENT")
        row.add_child(details)

func _message(parent: VBoxContainer, message: String) -> void:
    var label := Label.new()
    label.text = message
    parent.add_child(label)
