extends RefCounted
class_name DungeonEventDirector

const SEEDS := preload("res://scripts/world/dungeon_run_seed.gd")

# Resolve the existing module variation/lore/resource slots. These are plans, not
# new story content, rewards granted to inventory or combat effects.
static func populate(plan: Dictionary, library: Dictionary) -> Dictionary:
    var result := plan.duplicate(true)
    if not bool(result.get("ok", false)) or bool(result.get("fallback", false)):
        return result
    var modules := {}
    for module in library.get("modules", []):
        modules[str(module.get("module_id", ""))] = module
    for node in result.get("nodes", []):
        var module: Dictionary = modules.get(str(node.get("module_id", "")), {})
        var events: Array = []
        var slots: Array = module.get("variation_slots", []).duplicate(true)
        slots.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return str(a.get("slot_id", "")) < str(b.get("slot_id", "")))
        for slot in slots:
            var variants: Array = slot.get("allowed_variants", []).duplicate()
            variants.sort()
            if variants.is_empty():
                continue
            var rng := SEEDS.generator(int(node.get("event_seed", 0)), "event", str(slot.get("slot_id", "")))
            events.append({"slot_id":str(slot.get("slot_id", "")), "kind":str(slot.get("kind", "")), "variant":variants[rng.randi_range(0, variants.size() - 1)], "materialization_status":"definition_only"})
        node["room_events"] = events
        node["lore_reservations"] = module.get("lore_anchors", []).duplicate(true)
        node["resource_reservations"] = module.get("resource_anchors", []).duplicate(true)
    var validation := validate(result, library)
    result["event_report"] = validation
    result["ok"] = bool(validation["ok"])
    result["generation_report"]["events"] = validation.duplicate(true)
    return result

static func validate(plan: Dictionary, library: Dictionary) -> Dictionary:
    var errors: Array[String] = []
    var modules := {}
    var event_count := 0
    for module in library.get("modules", []):
        modules[str(module.get("module_id", ""))] = module
    for node in plan.get("nodes", []):
        var room_id := str(node.get("id", ""))
        var module: Dictionary = modules.get(str(node.get("module_id", "")), {})
        if module.is_empty():
            errors.append("event_module_missing:" + room_id)
            continue
        if not node.has("event_seed"):
            errors.append("event_seed_missing:" + room_id)
        var slots := {}
        for slot in module.get("variation_slots", []):
            var slot_id := str(slot.get("slot_id", ""))
            if slot_id == "" or slots.has(slot_id) or slot.get("allowed_variants", []).is_empty():
                errors.append("invalid_event_slot:" + room_id + ":" + slot_id)
            slots[slot_id] = slot
        var seen := {}
        for event in node.get("room_events", []):
            var slot_id := str(event.get("slot_id", ""))
            var slot: Dictionary = slots.get(slot_id, {})
            if seen.has(slot_id) or slot.is_empty() or event.get("variant", "") not in slot.get("allowed_variants", []) or str(event.get("kind", "")) != str(slot.get("kind", "")) or str(event.get("materialization_status", "")) != "definition_only":
                errors.append("invalid_room_event:" + room_id + ":" + slot_id)
            seen[slot_id] = true
            event_count += 1
        if seen.size() != slots.size():
            errors.append("event_slots_unresolved:" + room_id)
        for key in ["lore", "resource"]:
            if node.get(key + "_reservations", []) != module.get(key + "_anchors", []):
                errors.append("invalid_" + key + "_reservations:" + room_id)
    return {"ok":errors.is_empty(), "errors":errors, "event_count":event_count, "materialization_status":"definition_only"}
