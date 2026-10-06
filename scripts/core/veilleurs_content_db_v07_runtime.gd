extends "res://scripts/core/veilleurs_content_db_v07.gd"
class_name VeilleursContentDBV07Runtime

# Optional dungeon content enters the existing indexes only when requested.
# Historical catalog audits retain the original five-boss contract.
func _ensure_first_accord() -> void:
    if bosses_by_id.has("c01_ancient_accord_warden"):
        return
    var payload := _load_v07_dictionary("res://data/dungeons/first_accord_combat.json")
    _index_v07_entities([payload.get("boss", {})], bosses_by_id)
    for row in payload.get("skills", []):
        _index_production_skill(row)

func boss(entity_id: String) -> Dictionary:
    if entity_id == "c01_ancient_accord_warden":
        _ensure_first_accord()
    return super.boss(entity_id)

func skill(skill_id: String) -> Dictionary:
    if skill_id.begins_with("SK_FIRST_ACCORD_WARDEN_"):
        _ensure_first_accord()
    var base_skill: Dictionary = super.skill(skill_id)
    if not base_skill.is_empty():
        return base_skill
    return production_skill(skill_id)

func skills_for(entity_id: String) -> Array:
    if entity_id == "c01_ancient_accord_warden":
        _ensure_first_accord()
    var base_skills: Array = super.skills_for(entity_id)
    if not base_skills.is_empty():
        return base_skills
    return production_skills_for(entity_id)

func entity(entity_id: String) -> Dictionary:
    var base_entity: Dictionary = super.entity(entity_id)
    if not base_entity.is_empty():
        return base_entity
    return boss(entity_id)
