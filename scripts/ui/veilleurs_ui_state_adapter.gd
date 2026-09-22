extends RefCounted
class_name VeilleursUIStateAdapter

## Read-only bridge between the shared LITD UI and the active Veilleurs runtime.
## It deliberately does not mirror state into GameState/ExpeditionManager:
## VeilleursRuntime remains the single source of truth.

static func is_active() -> bool:
	return VeilleursRuntime != null and VeilleursRuntime.is_active()

static func snapshot() -> Dictionary:
	if not is_active():
		return {}
	return VeilleursRuntime.current_snapshot().duplicate(true)

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
	var rows := combatants()
	for id_value: Variant in rows.keys():
		var row: Dictionary = rows[id_value]
		if str(row.get("team", "")) == "watcher":
			result.append(row.duplicate(true))
	if not result.is_empty():
		return result

	var campaign_state := campaign()
	for watcher_value: Variant in campaign_state.get("watchers", []):
		if watcher_value is Dictionary:
			result.append((watcher_value as Dictionary).duplicate(true))
	return result

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
