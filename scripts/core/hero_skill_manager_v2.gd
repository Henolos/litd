extends "res://scripts/core/hero_skill_manager.gd"

# P0 playtest correction: the canonical quartet must never inherit the generic
# Frappe / Coup lourd / Garde / Premiers soins starter bar. Each Veilleur owns
# a distinct four-action starter kit, and every natural starting rank exposes
# at least one hostile action so a rear-line turn can never be dead by design.

const CANONICAL_STARTERS := {
    "mathilde": [
        {"id":"mathilde_trait_net","name":"Trait net","description":"Entaille précise depuis la ligne de duel.","effect":"attack","power":1.05,"target":"enemy","allowed_positions":[0,1]},
        {"id":"mathilde_fente_poursuite","name":"Fente de poursuite","description":"Allonge la menace jusqu'au troisième rang.","effect":"attack","power":0.92,"target":"enemy","allowed_positions":[0,1,2]},
        {"id":"mathilde_parade_courte","name":"Parade courte","description":"Ferme brièvement sa garde sans perdre le tempo.","effect":"guard","guard_bonus":13,"target":"self","allowed_positions":[0,1]},
        {"id":"mathilde_reprise","name":"Reprise","description":"Riposte courte utilisable quand la ligne s'étire.","effect":"attack","power":0.88,"target":"enemy","allowed_positions":[0,1,2]}
    ],
    "marec": [
        {"id":"marec_heurt_franc","name":"Heurt franc","description":"Impact frontal propre à Marec.","effect":"attack","power":1.12,"target":"enemy","allowed_positions":[0,1]},
        {"id":"marec_brise_garde","name":"Brise-garde","description":"Frappe lourde destinée à ouvrir la ligne adverse.","effect":"attack","power":1.28,"target":"enemy","status":"break","status_chance":28,"allowed_positions":[0,1]},
        {"id":"marec_tenir_devant","name":"Tenir devant","description":"Marec encaisse et maintient la ligne.","effect":"guard","guard_bonus":16,"target":"self","allowed_positions":[0,1,2]},
        {"id":"marec_coup_epaule","name":"Coup d'épaule","description":"Attaque de contrôle qui reste disponible au rang médian.","effect":"attack","power":0.90,"target":"enemy","allowed_positions":[0,1,2]}
    ],
    "anouk": [
        {"id":"anouk_point_tension","name":"Point de tension","description":"Anouk frappe le point faible depuis la ligne médiane ou arrière.","effect":"attack","power":1.00,"target":"enemy","allowed_positions":[1,2,3]},
        {"id":"anouk_deviation","name":"Déviation","description":"Détourne l'élan adverse par une attaque de contrôle.","effect":"attack","power":0.86,"target":"enemy","allowed_positions":[1,2,3]},
        {"id":"anouk_couper_flux","name":"Couper le flux","description":"Interrompt le rythme ennemi depuis n'importe quelle ligne.","effect":"attack","power":0.82,"target":"enemy","allowed_positions":[0,1,2,3]},
        {"id":"anouk_entre_deux_lignes","name":"Entre deux lignes","description":"Adopte une posture défensive adaptée aux rangs arrière.","effect":"guard","guard_bonus":11,"target":"self","allowed_positions":[1,2,3]}
    ],
    "aurelien": [
        {"id":"aurelien_examen_bref","name":"Examen bref","description":"Diagnostic offensif à distance de travail ; garantit une action hostile en R4.","effect":"attack","power":0.84,"target":"enemy","allowed_positions":[1,2,3]},
        {"id":"aurelien_incision_controlee","name":"Incision contrôlée","description":"Attaque clinique plus forte quand Aurélien se rapproche.","effect":"attack","power":1.08,"target":"enemy","allowed_positions":[0,1,2]},
        {"id":"aurelien_compression","name":"Compression ciblée","description":"Stabilise l'allié le plus blessé depuis toute la formation.","effect":"heal","heal":18,"target":"ally","allowed_positions":[0,1,2,3]},
        {"id":"aurelien_attelle","name":"Attelle","description":"Soutien clinique immédiat depuis toute la formation.","effect":"heal","heal":13,"target":"ally","allowed_positions":[0,1,2,3]}
    ]
}

func _canonical_starter_id(hero: Dictionary) -> String:
    var canonical_id := str(hero.get("canonical_id", hero.get("id", ""))).to_lower()
    return canonical_id if CANONICAL_STARTERS.has(canonical_id) else ""

func starter_combat_skills(hero: Dictionary) -> Array[Dictionary]:
    var canonical_id := _canonical_starter_id(hero)
    var result: Array[Dictionary] = []
    if canonical_id != "":
        for skill_value in CANONICAL_STARTERS[canonical_id]:
            result.append((skill_value as Dictionary).duplicate(true))
        return result
    for base_value in BASE_COMBAT_SKILLS:
        result.append((base_value as Dictionary).duplicate(true))
    return result

func starter_loadout(hero: Dictionary) -> Array[String]:
    var result: Array[String] = []
    for skill in starter_combat_skills(hero):
        result.append(str(skill.get("id", "")))
    return result

func prepare_hero(hero: Dictionary) -> void:
    if _canonical_starter_id(hero) == "":
        super.prepare_hero(hero)
        return
    hero["xp"] = maxi(0, int(hero.get("xp", 0)))
    hero["skill_points"] = maxi(0, int(hero.get("skill_points", 1)))
    hero["unlocked_skills"] = hero.get("unlocked_skills", [])
    hero["specialization"] = str(hero.get("specialization", ""))
    hero["combat_position"] = clampi(int(hero.get("combat_position", 0)), 0, 3)

    var known_ids: Array[String] = []
    for skill in known_combat_skills(hero):
        known_ids.append(str(skill.get("id", "")))

    # Sanitizing against the canonical known set automatically migrates old
    # saves that still contain generic starter IDs while preserving any valid
    # unlocked technique the player explicitly equipped.
    var sanitized: Array[String] = []
    for skill_id_value in hero.get("combat_loadout", []):
        var skill_id := str(skill_id_value)
        if known_ids.has(skill_id) and not sanitized.has(skill_id):
            sanitized.append(skill_id)
        if sanitized.size() >= COMBAT_LOADOUT_SIZE:
            break
    for starter_id in starter_loadout(hero):
        if sanitized.size() >= COMBAT_LOADOUT_SIZE:
            break
        if not sanitized.has(starter_id):
            sanitized.append(starter_id)
    hero["combat_loadout"] = sanitized

func known_combat_skills(hero: Dictionary) -> Array[Dictionary]:
    if _canonical_starter_id(hero) == "":
        return super.known_combat_skills(hero)
    var result: Array[Dictionary] = starter_combat_skills(hero)
    for skill_id_value in hero.get("unlocked_skills", []):
        var skill := combat_skill(hero, str(skill_id_value))
        if not skill.is_empty() and bool(skill.get("manual_combat_usable", true)):
            result.append(skill)
    return result

func combat_skill(hero: Dictionary, skill_id: String) -> Dictionary:
    if _canonical_starter_id(hero) == "":
        return super.combat_skill(hero, skill_id)
    for starter in starter_combat_skills(hero):
        if str(starter.get("id", "")) == skill_id:
            return starter.duplicate(true)
    var node := _node(hero, skill_id)
    if node.is_empty() or not hero.get("unlocked_skills", []).has(skill_id):
        return {}
    return _combat_profile_from_node(hero, node)

func equip_combat_skill(hero: Dictionary, slot: int, skill_id: String) -> bool:
    if _canonical_starter_id(hero) == "":
        return super.equip_combat_skill(hero, slot, skill_id)
    if GameState.current_screen == "combat" or slot < 0 or slot >= COMBAT_LOADOUT_SIZE:
        return false
    var skill := combat_skill(hero, skill_id)
    if skill.is_empty() or not bool(skill.get("manual_combat_usable", true)):
        return false
    prepare_hero(hero)
    var loadout: Array = hero.get("combat_loadout", []).duplicate()
    for index in range(loadout.size()):
        if index != slot and str(loadout[index]) == skill_id:
            return false
    var defaults := starter_loadout(hero)
    while loadout.size() < COMBAT_LOADOUT_SIZE:
        loadout.append(defaults[loadout.size()])
    loadout[slot] = skill_id
    hero["combat_loadout"] = loadout
    return true
