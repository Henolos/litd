extends RefCounted

# Règle de lecture : position 0 = rang 1 (avant), position 3 = rang 4 (arrière).
# Ce fichier ne déplace jamais un héros : il décrit seulement depuis quels rangs
# une technique peut être utilisée. Le changement de position reste une action.

const FRONT: Array[int] = [0, 1]
const FRONT_MID: Array[int] = [0, 1, 2]
const MID_BACK: Array[int] = [1, 2, 3]
const ALL: Array[int] = [0, 1, 2, 3]

const FRONT_CLASSES: Array[String] = ["breaker", "watcher", "inquisitor", "duelist"]
const BACK_CLASSES: Array[String] = ["vestal", "mystic", "ranger", "surgeon", "scout", "occultist"]

static func allowed_positions(hero: Dictionary, skill: Dictionary) -> Array[int]:
    # Canonical starter kits and authored skills may declare their own positional
    # contract. It has priority over generic class heuristics so an intentional
    # rear-line attack cannot be silently disabled by an old fallback rule.
    var explicit_value: Variant = skill.get("allowed_positions", null)
    if explicit_value is Array:
        var explicit: Array[int] = []
        for position_value in explicit_value:
            var position := int(position_value)
            if position >= 0 and position <= 3 and not explicit.has(position):
                explicit.append(position)
        if not explicit.is_empty():
            explicit.sort()
            return explicit

    var skill_id := str(skill.get("id", ""))
    match skill_id:
        "basic_strike": return FRONT_MID.duplicate()
        "heavy_blow": return FRONT.duplicate()
        "guard_stance": return ALL.duplicate()
        "field_aid": return MID_BACK.duplicate()

    var effect := str(skill.get("effect", "attack"))
    var source_stat := str(skill.get("source_stat", ""))
    var status := str(skill.get("status", ""))
    var affliction := str(skill.get("affliction", ""))
    var class_id := str(hero.get("class_id", ""))

    if effect == "guard":
        return FRONT_MID.duplicate()
    if effect in ["heal", "support"]:
        return MID_BACK.duplicate()

    if effect == "attack":
        if status in ["stun", "break"] or source_stat in ["break_chance", "stun_chance", "execute_percent"]:
            return FRONT.duplicate()
        if status == "bleed" or affliction == "bleed" or source_stat == "bleed_chance":
            return FRONT_MID.duplicate()
        if source_stat in ["precision", "critical_chance"]:
            return MID_BACK.duplicate()
        if FRONT_CLASSES.has(class_id):
            return FRONT.duplicate()
        if BACK_CLASSES.has(class_id):
            return MID_BACK.duplicate()
        return FRONT_MID.duplicate()

    return ALL.duplicate()

static func is_usable(hero: Dictionary, skill: Dictionary) -> bool:
    if hero.is_empty() or skill.is_empty():
        return false
    return allowed_positions(hero, skill).has(clampi(int(hero.get("combat_position", 0)), 0, 3))

static func position_label(positions: Array[int]) -> String:
    if positions.is_empty():
        return "aucun"
    var labels: Array[String] = []
    for position in positions:
        labels.append("R%d" % (int(position) + 1))
    return " / ".join(labels)

static func short_position_label(positions: Array[int]) -> String:
    if positions == ALL:
        return "R1–R4"
    if positions == FRONT:
        return "R1–R2"
    if positions == FRONT_MID:
        return "R1–R3"
    if positions == MID_BACK:
        return "R2–R4"
    return position_label(positions)
