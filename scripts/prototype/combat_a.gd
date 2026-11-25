extends Control

# Disposable Combat A experiment. Numbers and anonymous enemies are not canon.
const ROSTER_PATH := "res://data/veilleurs/canonical_roster.json"
const HERO_HP := 12
const ENEMY_HP := 8
const ATTACK_DAMAGE := 4
const ENEMY_DAMAGE := 3

var heroes: Array[Dictionary] = []
var enemies: Array[Dictionary] = []
var actor_index := 0
var target_index := -1
var round_number := 1
var phase := "player"
var log_lines: Array[String] = []

var _status: Label
var _party: Label
var _opponents: Label
var _preview: Label
var _history: Label
var _target_buttons: HBoxContainer
var _attack: Button
var _guard: Button

func _ready() -> void:
    _build_ui()
    start_encounter()

func start_encounter() -> void:
    var roster_value: Variant = JSON.parse_string(FileAccess.get_file_as_string(ROSTER_PATH))
    if not roster_value is Dictionary or not roster_value.get("heroes", []) is Array or roster_value["heroes"].size() != 4:
        push_error("Quatuor canonique indisponible")
        phase = "error"
        _render()
        return
    heroes.clear()
    for item in roster_value["heroes"]:
        heroes.append({"id": String(item["id"]), "name": String(item["name"]), "hp": HERO_HP, "guard": false})
    enemies = [
        {"name": "Menace A (provisoire)", "hp": ENEMY_HP},
        {"name": "Menace B (provisoire)", "hp": ENEMY_HP},
    ]
    actor_index = 0
    target_index = -1
    round_number = 1
    phase = "player"
    log_lines = ["Choisissez une cible, puis attaquez ou protégez le héros actif."]
    _render()

func select_target(index: int) -> bool:
    if phase != "player" or index < 0 or index >= enemies.size() or int(enemies[index]["hp"]) <= 0:
        return false
    target_index = index
    _render()
    return true

func attack() -> bool:
    if phase != "player" or target_index < 0 or target_index >= enemies.size() or int(enemies[target_index]["hp"]) <= 0:
        return false
    var actor_name := String(heroes[actor_index]["name"])
    var enemy_name := String(enemies[target_index]["name"])
    enemies[target_index]["hp"] = maxi(0, int(enemies[target_index]["hp"]) - ATTACK_DAMAGE)
    _record("%s frappe %s : -%d PV." % [actor_name, enemy_name, ATTACK_DAMAGE])
    if int(enemies[target_index]["hp"]) == 0:
        _record("%s est hors combat." % enemy_name)
    target_index = -1
    _advance()
    return true

func guard() -> bool:
    if phase != "player":
        return false
    heroes[actor_index]["guard"] = true
    _record("%s se protège : la prochaine attaque reçue sera réduite." % heroes[actor_index]["name"])
    target_index = -1
    _advance()
    return true

func _advance() -> void:
    if _all_down(enemies):
        phase = "victory"
        _record("Victoire. Observez quels choix ont permis de l'obtenir.")
        _render()
        return
    for index in range(actor_index + 1, heroes.size()):
        if int(heroes[index]["hp"]) > 0:
            actor_index = index
            _render()
            return
    _enemy_turn()
    if _all_down(heroes):
        phase = "defeat"
        _record("Défaite. Recommencez pour essayer un autre choix.")
    else:
        round_number += 1
        for index in range(heroes.size()):
            if int(heroes[index]["hp"]) > 0:
                actor_index = index
                break
    _render()

func _enemy_turn() -> void:
    for enemy in enemies:
        if int(enemy["hp"]) <= 0:
            continue
        var candidate := -1
        for index in range(heroes.size()):
            if int(heroes[index]["hp"]) > 0:
                candidate = index
                break
        if candidate < 0:
            return
        var damage := ENEMY_DAMAGE
        if bool(heroes[candidate]["guard"]):
            damage = 1
            heroes[candidate]["guard"] = false
        heroes[candidate]["hp"] = maxi(0, int(heroes[candidate]["hp"]) - damage)
        _record("%s attaque %s : -%d PV." % [enemy["name"], heroes[candidate]["name"], damage])

func _all_down(group: Array[Dictionary]) -> bool:
    for member in group:
        if int(member["hp"]) > 0:
            return false
    return true

func _record(message: String) -> void:
    log_lines.append(message)
    if log_lines.size() > 7:
        log_lines.pop_front()

func _build_ui() -> void:
    var backdrop := ColorRect.new()
    backdrop.color = Color("111722")
    backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(backdrop)
    var margin := MarginContainer.new()
    margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    margin.add_theme_constant_override("margin_left", 28)
    margin.add_theme_constant_override("margin_right", 28)
    margin.add_theme_constant_override("margin_top", 24)
    margin.add_theme_constant_override("margin_bottom", 24)
    add_child(margin)
    var column := VBoxContainer.new()
    column.add_theme_constant_override("separation", 12)
    margin.add_child(column)
    var title := _label("LITD 1 — Combat A | prototype fonctionnel", 27)
    column.add_child(title)
    column.add_child(_label("Maquette sans art validé. Règles et chiffres provisoires.", 14))
    _status = _label("", 19)
    column.add_child(_status)
    _party = _label("", 18)
    column.add_child(_party)
    _opponents = _label("", 18)
    column.add_child(_opponents)
    _target_buttons = HBoxContainer.new()
    _target_buttons.add_theme_constant_override("separation", 12)
    column.add_child(_target_buttons)
    for index in range(2):
        var button := Button.new()
        button.custom_minimum_size = Vector2(230, 54)
        button.pressed.connect(select_target.bind(index))
        _target_buttons.add_child(button)
    _preview = _label("", 17)
    column.add_child(_preview)
    var actions := HBoxContainer.new()
    actions.add_theme_constant_override("separation", 12)
    column.add_child(actions)
    _attack = Button.new()
    _attack.text = "Attaquer la cible"
    _attack.custom_minimum_size = Vector2(230, 54)
    _attack.pressed.connect(attack)
    actions.add_child(_attack)
    _guard = Button.new()
    _guard.text = "Se protéger"
    _guard.custom_minimum_size = Vector2(200, 54)
    _guard.pressed.connect(guard)
    actions.add_child(_guard)
    var restart := Button.new()
    restart.text = "Recommencer"
    restart.custom_minimum_size = Vector2(180, 54)
    restart.pressed.connect(start_encounter)
    actions.add_child(restart)
    column.add_child(_label("Journal des conséquences", 17))
    _history = _label("", 16)
    _history.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    column.add_child(_history)

func _label(value: String, size: int) -> Label:
    var label := Label.new()
    label.text = value
    label.add_theme_color_override("font_color", Color("e5e7df"))
    label.add_theme_font_size_override("font_size", size)
    return label

func _render() -> void:
    if _status == null:
        return
    _status.text = "Tour %d — %s" % [round_number, String(heroes[actor_index]["name"]) if phase == "player" else phase.to_upper()]
    var hero_lines: Array[String] = []
    for index in range(heroes.size()):
        var hero: Dictionary = heroes[index]
        hero_lines.append("R%d %s : %d/%d PV%s" % [index + 1, hero["name"], hero["hp"], HERO_HP, " [garde]" if hero["guard"] else ""])
    _party.text = "Héros (ordre des tours)\n" + "  |  ".join(hero_lines)
    var enemy_lines: Array[String] = []
    for index in range(enemies.size()):
        enemy_lines.append("R%d %s : %d/%d PV" % [index + 1, enemies[index]["name"], enemies[index]["hp"], ENEMY_HP])
        var button: Button = _target_buttons.get_child(index)
        button.text = ("✓ " if target_index == index else "Viser ") + String(enemies[index]["name"])
        button.disabled = phase != "player" or int(enemies[index]["hp"]) <= 0
    _opponents.text = "Adversaires\n" + "  |  ".join(enemy_lines)
    _preview.text = "Aperçu : %s" % ("%s perdra %d PV." % [enemies[target_index]["name"], ATTACK_DAMAGE] if target_index >= 0 else "choisissez une cible vivante ; garde réduit une attaque de 3 à 1 PV.")
    _attack.disabled = phase != "player" or target_index < 0
    _guard.disabled = phase != "player"
    _history.text = "\n".join(log_lines)
