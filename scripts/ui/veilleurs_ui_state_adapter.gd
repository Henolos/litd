extends RefCounted
class_name VeilleursUIStateAdapter

## Read-only bridge between the shared LITD UI and the active Veilleurs runtime.
## It deliberately does not mirror state into GameState/ExpeditionManager:
## VeilleursRuntime remains the single source of truth.

const WATCHER_IDS: Array[String] = [
	"ENT_WATCHER_marec",
	"ENT_WATCHER_mathilde",
	"ENT_WATCHER_aurelien",
	"ENT_WATCHER_anouk"
]
const SHARED_CLASSES := {
	"ENT_WATCHER_marec": "breaker",
	"ENT_WATCHER_mathilde": "duelist",
	"ENT_WATCHER_aurelien": "surgeon",
	"ENT_WATCHER_anouk": "mystic"
}

static func is_active() -> bool:
	return VeilleursRuntime != null and VeilleursRuntime.is_active()

static func snapshot() -> Dictionary:
	if not is_active():
		return {}
	return (VeilleursRuntime.serialize().get("runtime", {}) as Dictionary).duplicate(true)

static func campaign() -> Dictionary:
	var state := snapshot()
	return (state.get("campaign", {}) as Dictionary).duplicate(true)

static func combat() -> Dictionary:
	var state := snapshot()
	return (state.get("combat", {}) as Dictionary).duplicate(true)

static func combatants() -> Dictionary:
	var combat_state := combat()
	if combat_state.has("runtime"):
		return ((combat_state.get("runtime", {}) as Dictionary).get("combatants", {}) as Dictionary).duplicate(true)
	return (combat_state.get("combatants", {}) as Dictionary).duplicate(true)

static func party() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if not is_active():
		return result
	var rows := combatants()
	var campaign_state := campaign()
	var progress_rows: Dictionary = campaign_state.get("watcher_progress", {})
	var expedition_rows: Dictionary = snapshot().get("v09_expedition_watcher_state", {})
	for entity_id: String in WATCHER_IDS:
		var row: Dictionary = (rows.get(entity_id, {}) as Dictionary).duplicate(true)
		if row.is_empty():
			row = (expedition_rows.get(entity_id, {}) as Dictionary).duplicate(true)
		var progress: Dictionary = progress_rows.get(entity_id, {})
		result.append(_menu_hero(entity_id, row, progress))
	return result

static func _menu_hero(entity_id: String, runtime_row: Dictionary, progress: Dictionary) -> Dictionary:
	var definition: Dictionary = _watcher_definition(entity_id)
	var hero := runtime_row.duplicate(true)
	var canonical_id := entity_id.trim_prefix("ENT_WATCHER_")
	var display_name := str(definition.get("runtime_id", definition.get("name_fr", canonical_id.capitalize())))
	hero["id"] = entity_id
	hero["canonical_id"] = canonical_id
	hero["entity_id"] = entity_id
	hero["runtime_id"] = display_name
	hero["name"] = str(definition.get("name_fr", display_name))
	hero["display_name"] = hero["name"]
	hero["class_id"] = str(SHARED_CLASSES.get(entity_id, ""))
	hero["team"] = "watcher"
	hero["level"] = maxi(1, int(runtime_row.get("level", progress.get("level", 1))))
	if not hero.has("max_hp"):
		var stats: Dictionary = definition.get("stats", {})
		hero["max_hp"] = 80 + int(stats.get("VIG", 0))
	if not hero.has("hp"):
		hero["hp"] = int(hero.get("max_hp", 0))
	return hero

static func _watcher_definition(entity_id: String) -> Dictionary:
	var runtime: Variant = VeilleursRuntime.runtime
	if runtime == null or runtime.campaign == null or runtime.campaign.content_db == null:
		return {}
	return runtime.campaign.content_db.watcher(entity_id)

static func current_dungeon_id() -> String:
	var campaign_state := campaign()
	return str(campaign_state.get("current_dungeon_id", ""))

static func expedition_active() -> bool:
	return is_active() and current_dungeon_id() != ""

static func menu_context() -> Dictionary:
	return {
		"active": is_active(),
		"party": party(),
		"campaign": campaign(),
		"combat": combat(),
		"current_dungeon_id": current_dungeon_id(),
		"expedition_active": expedition_active()
	}

static func enemy_knowledge_view(combatant: Dictionary) -> Dictionary:
	var source := combatant.duplicate(true)
	var entry_id := str(source.get("remanence_id", source.get("definition_id", source.get("entity_id", source.get("id", "")))))
	if entry_id == "":
		return KnowledgeDiscoveryUIContract.enemy_view(source)
	var definition_id := str(source.get("definition_id", source.get("entity_id", entry_id)))
	source["id"] = definition_id
	if not source.has("name"):
		source["name"] = str(source.get("display_name", definition_id))
	if not is_active():
		return KnowledgeDiscoveryUIContract.enemy_view(source)
	var summary: Dictionary = VeilleursRuntime.knowledge_summary(entry_id)
	var level := int(summary.get("knowledge_level", 0))
	var observed_ids: Array = summary.get("observed_skills", [])
	var campaign_entry := {
		"knowledge": level,
		"observed_skills": _observed_skill_rows(source, observed_ids),
	}
	return KnowledgeDiscoveryUIContract.enemy_view(
		source,
		campaign_entry,
		{"knowledge_level": level},
		{},
		false,
		(summary.get("evidence", []) as Array).duplicate(true)
	)

static func _observed_skill_rows(combatant: Dictionary, observed_ids: Array) -> Array:
	var result: Array = []
	var skills_value: Variant = combatant.get("skills", combatant.get("abilities", []))
	var skills: Array = skills_value if skills_value is Array else []
	for id_value: Variant in observed_ids:
		var observed_id := str(id_value)
		var matched := false
		for skill_value: Variant in skills:
			if not (skill_value is Dictionary):
				continue
			var skill: Dictionary = skill_value
			var skill_id := str(skill.get("skill_id", skill.get("id", "")))
			if skill_id != observed_id:
				continue
			result.append(skill.duplicate(true))
			matched = true
			break
		if not matched and observed_id != "":
			result.append(observed_id)
	return result
