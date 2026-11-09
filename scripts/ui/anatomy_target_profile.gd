extends RefCounted
class_name AnatomyTargetProfile

# Presentation-only profiles. The combat resolver remains authoritative.
const HUMANOID := "humanoid_biped"
const ZONES := ["head", "torso", "left_arm", "right_arm", "left_leg", "right_leg"]
const LABELS := {
    "head": "Tête", "torso": "Torse",
    "left_arm": "Bras gauche", "right_arm": "Bras droit",
    "left_leg": "Jambe gauche", "right_leg": "Jambe droite"
}
# Normalized coordinates for a front-facing humanoid, not screen pixels.
const ANCHORS := {
    "head": Vector2(0.50, 0.12),
    "torso": Vector2(0.50, 0.38),
    "left_arm": Vector2(0.24, 0.42),
    "right_arm": Vector2(0.76, 0.42),
    "left_leg": Vector2(0.40, 0.77),
    "right_leg": Vector2(0.60, 0.77)
}
# Only provisional name-based candidates, not visually validated.
const CANDIDATE_ENEMY_IDS := [2, 3, 13, 36]

static func profile_for_enemy(enemy: Dictionary) -> Dictionary:
    var id := int(enemy.get("id", -1))
    if id not in CANDIDATE_ENEMY_IDS:
        return {"ok": false, "reason": "morphology_not_verified", "fallback": "zone_list"}
    return {"ok": true, "profile": HUMANOID, "verified": false, "zones": ZONES.duplicate()}

static func display_zones(enemy: Dictionary, allowed: Array = []) -> Array[Dictionary]:
    var profile := profile_for_enemy(enemy)
    var result: Array[Dictionary] = []
    if not bool(profile.get("ok", false)):
        return result
    var anatomy: Dictionary = enemy.get("anatomy", {})
    var body_value: Variant = enemy.get("body", {})
    var missing: Array = []
    if body_value is Dictionary:
        missing = (body_value as Dictionary).get("missing_parts", [])
    elif body_value is VeilleursBodyComponent:
        missing = (body_value as VeilleursBodyComponent).missing_parts
    for zone in ZONES:
        var state: Dictionary = anatomy.get(zone, {})
        var absent := zone in missing or str(state.get("function", "")) in ["missing", "amputated"]
        var permitted := allowed.is_empty() or zone in allowed
        result.append({
            "id": zone, "label": LABELS[zone], "anchor": ANCHORS[zone],
            "available": not absent and permitted,
            "reason": "Membre absent" if absent else ("Zone non autorisée" if not permitted else ""),
            "injured": str(state.get("state", "healthy")) != "healthy"
        })
    return result
