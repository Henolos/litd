extends "res://scripts/ui/main_v51.gd"

# v52 — P0 identité + tours utiles.
# Les anciennes cartes de classe contiennent des noms imprimés (Mirelle, Elara,
# Rahkan, Isolde). Elles ne doivent jamais représenter le quatuor canonique.
# Les quatre Veilleurs disposent désormais de portraits canoniques dédiés.

const LEGACY_CARD_PREFIX := "res://assets/heroes/"
const OFFICIAL_PORTRAIT_PREFIX := "res://art/library/heroes/"
const RUNTIME_PORTRAIT_PREFIX := "res://assets/art/v41/portraits/"
const CANONICAL_HERO_IDS := ["mathilde", "marec", "anouk", "aurelien"]
const CANONICAL_ROLES := {
    "mathilde": "Duelliste",
    "marec": "Briseur",
    "anouk": "Mystique",
    "aurelien": "Chirurgien"
}

func _show_hero_profile() -> void:
    super._show_hero_profile()
    _replace_hero_profile_portrait_v52()

func _replace_hero_profile_portrait_v52() -> void:
    if not is_instance_valid(content):
        return
    var hero: Dictionary = _selected_hero()
    if hero.is_empty():
        return
    var hero_id := str(hero.get("canonical_id", hero.get("id", ""))).to_lower()
    if not CANONICAL_HERO_IDS.has(hero_id):
        return
    var portrait_texture := load(_canonical_art.hero_portrait_path(hero)) as Texture2D
    if portrait_texture == null:
        return

    # Keep the inherited profile slot tagged with the same
    # canonical identity used by combat and the shared hero_art() resolver.
    for node_value in content.find_children("*", "TextureRect", true, false):
        var portrait_slot := node_value as TextureRect
        if portrait_slot == null:
            continue
        if portrait_slot.position == Vector2(52, 170) and portrait_slot.size == Vector2(360, 390):
            portrait_slot.texture = portrait_texture
            portrait_slot.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
            portrait_slot.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
            portrait_slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
            portrait_slot.set_meta("canonical_hero_id", hero_id)
            return

func show_combat() -> void:
    super.show_combat()
    _replace_legacy_hero_cards_v52()
    var reach := make_label("Survolez ou sélectionnez une technique pour consulter sa portée.", 12, MUTED)
    reach.name = "CombatReachHintV52"
    reach.position = Vector2(24, 472)
    reach.size = Vector2(600, 32)
    content.add_child(reach)
    _show_skill_target_reach_v52()
    call_deferred("_fit_combat_popups_v52")

# Wrapped labels can briefly report a very tall minimum before their container
# has a width. PanelContainer grows to that value and does not shrink itself.
func _fit_combat_popups_v52() -> void:
    await get_tree().process_frame
    await get_tree().process_frame
    if GameState.current_screen != "combat" or not is_instance_valid(content):
        return
    for panel_name in ["CombatPositionMenuV42", "CombatItemMenuV42"]:
        var panel := content.get_node_or_null(panel_name) as Control
        if panel == null:
            continue
        panel.size.y = panel.get_combined_minimum_size().y
        panel.position.y = minf(panel.position.y, 504.0 - panel.size.y)

func _show_skill_target_reach_v52() -> void:
    if GameState.current_screen != "combat" or not is_instance_valid(content) or battle_locked:
        return
    var hero: Dictionary = _active_combat_hero()
    if hero.is_empty():
        return
    var loadout: Array[String] = HeroSkillManager.combat_loadout(hero)
    var buttons := content.find_children("*", "Button", true, false)
    for slot in range(mini(HeroSkillManager.COMBAT_LOADOUT_SIZE, loadout.size())):
        var skill: Dictionary = HeroSkillManager.combat_skill(hero, loadout[slot])
        if skill.is_empty():
            continue
        var prefix := "%d · " % (slot + 1)
        for node_value: Variant in buttons:
            var button := node_value as Button
            if button == null or not button.text.begins_with(prefix):
                continue
            var summary := ""
            var names: Array[String] = []
            if str(skill.get("effect", "")).to_lower() not in ["attack", "affliction", "diagnostic"]:
                summary = "Soutien · choisissez la technique pour préparer son effet"
            elif not COMBAT_POSITION_RULES.is_usable(hero, skill):
                summary = "CIBLES : rang du héros incompatible"
            else:
                var indices: Array[int] = COMBAT_TARGETING_RULES.targetable_indices(hero, skill, GameState.battle_enemies)
                var ranks: Array[String] = []
                for enemy_index: int in indices:
                    if enemy_index < 0 or enemy_index >= GameState.battle_enemies.size():
                        continue
                    var enemy: Dictionary = GameState.battle_enemies[enemy_index]
                    ranks.append("E%d" % (int(enemy.get("combat_position", 0)) + 1))
                    names.append("%s (E%d)" % [str(enemy.get("name", "Ennemi")), int(enemy.get("combat_position", 0)) + 1])
                summary = "CIBLES : %s" % (", ".join(ranks) if not ranks.is_empty() else "aucune à portée")
            button.text = "%d · %s" % [slot + 1, str(skill.get("name", "Technique"))]
            var allowed := COMBAT_POSITION_RULES.position_label(COMBAT_POSITION_RULES.allowed_positions(hero, skill))
            var reach := "Rangs : %s · %s" % [allowed, summary]
            button.mouse_entered.connect(func(): _set_combat_reach_v52(reach))
            button.focus_entered.connect(func(): _set_combat_reach_v52(reach))
            if pending_target_skill_slot == slot:
                _set_combat_reach_v52(reach)
            button.tooltip_text += "\n%s" % (", ".join(names) if not names.is_empty() else summary)
            break

func _set_combat_reach_v52(text: String) -> void:
    var reach := content.get_node_or_null("CombatReachHintV52") as Label
    if reach != null:
        reach.text = text

func _replace_legacy_hero_cards_v52() -> void:
    if not is_instance_valid(content):
        return

    # Reuse the four portrait slots created by the inherited combat layout.
    # The mobile post-processing already knows how to size/reflow those slots.
    # Creating a second visual card layer here used to cover the skill and
    # context-action rows on narrow Safari viewports.
    var legacy_portraits: Array[TextureRect] = []
    for node_value in content.find_children("*", "TextureRect", true, false):
        var texture_rect := node_value as TextureRect
        if texture_rect == null or texture_rect.texture == null:
            continue
        var resource_path := str(texture_rect.texture.resource_path)
        if resource_path.begins_with(LEGACY_CARD_PREFIX) or resource_path.begins_with(OFFICIAL_PORTRAIT_PREFIX) or resource_path.begins_with(RUNTIME_PORTRAIT_PREFIX):
            legacy_portraits.append(texture_rect)

    var ordered_heroes: Array[Dictionary] = _heroes_by_position()
    for index in range(legacy_portraits.size()):
        var portrait_slot := legacy_portraits[index]
        if index >= ordered_heroes.size():
            portrait_slot.visible = false
            continue

        var hero: Dictionary = ordered_heroes[index]
        var hero_id := str(hero.get("canonical_id", hero.get("id", ""))).to_lower()
        if not CANONICAL_HERO_IDS.has(hero_id):
            portrait_slot.visible = false
            continue

        var portrait_path := _canonical_art.hero_portrait_path(hero)
        var portrait_texture := load(portrait_path) as Texture2D
        if portrait_texture == null:
            # Never fall back to a legacy card with an obsolete printed identity.
            portrait_slot.visible = false
            continue

        portrait_slot.texture = portrait_texture
        portrait_slot.visible = true
        portrait_slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
        portrait_slot.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
        portrait_slot.set_meta("canonical_hero_id", hero_id)

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
