extends "res://scripts/ui/main_v51.gd"

# v52 — P0 identité + tours utiles.
# Les anciennes cartes de classe contiennent des noms imprimés (Mirelle, Elara,
# Rahkan, Isolde). Elles ne doivent jamais représenter le quatuor canonique.
# Tant que les portraits individuels définitifs ne sont pas branchés, le combat
# affiche une carte neutre portant uniquement l'identité réelle du Veilleur.

const LEGACY_CARD_PREFIX := "res://assets/heroes/"
const CANONICAL_HERO_IDS := ["mathilde", "marec", "anouk", "aurelien"]
const CANONICAL_ROLES := {
    "mathilde": "Duelliste",
    "marec": "Briseur",
    "anouk": "Mystique",
    "aurelien": "Chirurgien"
}

func show_combat() -> void:
    super.show_combat()
    _replace_legacy_hero_cards_v52()

func _replace_legacy_hero_cards_v52() -> void:
    if not is_instance_valid(content):
        return

    # Hide every legacy class-card texture. Enemy portraits and the background
    # use other asset roots and are therefore left untouched.
    for node_value in content.find_children("*", "TextureRect", true, false):
        var texture_rect := node_value as TextureRect
        if texture_rect == null or texture_rect.texture == null:
            continue
        var resource_path := str(texture_rect.texture.resource_path)
        if resource_path.begins_with(LEGACY_CARD_PREFIX):
            texture_rect.visible = false

    var ordered_heroes: Array[Dictionary] = _heroes_by_position()
    for index in range(ordered_heroes.size()):
        var hero: Dictionary = ordered_heroes[index]
        var hero_id := str(hero.get("canonical_id", hero.get("id", ""))).to_lower()
        if not CANONICAL_HERO_IDS.has(hero_id):
            continue
        var active := str(hero.get("id", "")) == combat_active_hero_id
        var panel := PanelContainer.new()
        panel.name = "CanonicalCombatCard_%s" % hero_id
        panel.position = Vector2(35 + index * 132, 160)
        panel.size = Vector2(138, 250)
        panel.z_index = 30
        panel.add_theme_stylebox_override("panel", panel_style(Color(0.012, 0.014, 0.020, 0.96)))
        content.add_child(panel)

        var box := VBoxContainer.new()
        box.alignment = BoxContainer.ALIGNMENT_CENTER
        box.add_theme_constant_override("separation", 8)
        panel.add_child(box)
        var initial := str(hero.get("name", "V")).left(1).to_upper()
        var initial_label := make_label(initial, 54, CANON_GOLD if active else CANON_TEXT)
        initial_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        box.add_child(initial_label)
        var name_label := make_label(str(hero.get("name", "Veilleur")), 18, CANON_GOLD if active else CANON_TEXT)
        name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        box.add_child(name_label)
        var role_label := make_label(str(CANONICAL_ROLES.get(hero_id, "Veilleur")), 12, CANON_MUTED)
        role_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        box.add_child(role_label)
        var rank_label := make_label("R%d" % (int(hero.get("combat_position", 0)) + 1), 13, CANON_MUTED)
        rank_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        box.add_child(rank_label)

func show_hero_skills() -> void:
    var hero: Dictionary = _selected_skill_hero()
    if hero.is_empty():
        GameState.request_screen("company")
        return
    HeroSkillManager.prepare_hero(hero)
    var title := make_label("%s — COMPÉTENCES · %d POINT(S)" % [hero.name, int(hero.skill_points)], 24, GOLD)
    title.position = Vector2(24, 12)
    content.add_child(title)

    var loadout_label := make_label("4 COMPÉTENCES ÉQUIPÉES — choisissez un emplacement puis une technique", 15, GOLD)
    loadout_label.position = Vector2(24, 48)
    loadout_label.size = Vector2(1000, 28)
    content.add_child(loadout_label)

    var loadout_row := HBoxContainer.new()
    loadout_row.position = Vector2(24, 78)
    loadout_row.size = Vector2(1220, 64)
    loadout_row.add_theme_constant_override("separation", 8)
    content.add_child(loadout_row)
    var loadout: Array[String] = HeroSkillManager.combat_loadout(hero)
    for slot in range(HeroSkillManager.COMBAT_LOADOUT_SIZE):
        var skill: Dictionary = HeroSkillManager.combat_skill(hero, loadout[slot])
        var slot_button := make_button(
            "%d · %s%s" % [slot + 1, str(skill.get("name", "Technique")), "\nÀ REMPLACER" if slot == selected_loadout_slot else ""],
            func(slot_index = slot):
                selected_loadout_slot = int(slot_index)
                show_hero_skills(),
            Vector2(292, 58)
        )
        loadout_row.add_child(slot_button)

    var scroll := ScrollContainer.new()
    scroll.position = Vector2(24, 154)
    scroll.size = Vector2(1230, 470)
    content.add_child(scroll)
    var list := VBoxContainer.new()
    list.custom_minimum_size = Vector2(1190, 0)
    list.add_theme_constant_override("separation", 10)
    scroll.add_child(list)

    list.add_child(make_label("TECHNIQUES DE DÉPART — propres à %s" % str(hero.get("name", "ce Veilleur")), 15, MUTED))
    var starter_grid := GridContainer.new()
    starter_grid.columns = 4
    list.add_child(starter_grid)
    for skill_value in HeroSkillManager.starter_combat_skills(hero):
        var starter_skill: Dictionary = skill_value
        starter_grid.add_child(make_button(
            "%s\n%s" % [str(starter_skill.get("name", "Technique")), str(starter_skill.get("description", ""))],
            func(skill_id = str(starter_skill.get("id", ""))): _equip_selected_combat_skill(hero, skill_id),
            Vector2(282, 66)
        ))

    var specialization: String = str(hero.get("specialization", ""))
    for branch in HeroSkillManager.branches_for(hero):
        var branch_title: String = "%s%s" % [str(HeroSkillManager.branch_label(hero, branch)).to_upper(), " — CHOISI" if specialization == branch else (" — VERROUILLÉ" if specialization != "" and not HeroSkillManager.multi_tree_enabled() else "")]
        list.add_child(make_label(branch_title, 15, GOLD))
        var grid := GridContainer.new()
        grid.columns = 3
        list.add_child(grid)
        for node_value in HeroSkillManager.skill_nodes(hero, branch):
            var node: Dictionary = node_value
            var node_id: String = str(node.get("id", ""))
            var unlocked: bool = (hero.get("unlocked_skills", []) as Array).has(node_id)
            var text: String = "%s\n%s" % [str(node.get("name", "Compétence")), "ACQUISE · ÉQUIPER" if unlocked else str(node.get("description", ""))]
            var button := make_button(
                text,
                func(skill_id = node_id, is_unlocked = unlocked):
                    if bool(is_unlocked):
                        _equip_selected_combat_skill(hero, str(skill_id))
                    else:
                        HeroSkillManager.unlock(hero, str(skill_id))
                        show_hero_skills(),
                Vector2(380, 58)
            )
            if not unlocked:
                button.disabled = not HeroSkillManager.can_unlock(hero, node_id)
            grid.add_child(button)

    var back := make_button("RETOUR", func(): GameState.request_screen("company"), Vector2(180,45))
    back.position = Vector2(24, 640)
    content.add_child(back)
