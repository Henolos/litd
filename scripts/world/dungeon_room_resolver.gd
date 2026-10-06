extends RefCounted
class_name DungeonRoomResolver

const RUN_SEED := preload("res://scripts/world/dungeon_run_seed.gd")

static func _assign_modules(plan: Dictionary, config: Dictionary, library: Dictionary) -> void:
    var modules: Array = library.get("modules", [])
    for node in plan.get("nodes", []):
        var pool := str(node.get("module_pool", ""))
        var source_pool := _source_pool(config, pool)
        var candidates: Array = []
        for module in modules:
            if str(module.get("pool", "")) == source_pool and compatible(module, config):
                candidates.append(module)
        if candidates.is_empty():
            continue
        var rng := RUN_SEED.generator(int(plan.get("seed", 0)), "room", str(node.get("id", "")) + "|module")
        candidates.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return str(a.get("module_id", "")) < str(b.get("module_id", "")))
        var module := _weighted_pick(candidates, rng)
        if module.is_empty():
            continue
        node["module_id"] = str(module.get("module_id", ""))
        node["module_source_pool"] = source_pool
        node["module_pool_fallback"] = source_pool != pool
        var anchors: Array[String] = []
        for scar in module.get("scar_anchors", []):
            anchors.append(str(scar.get("anchor_id", "")))
        node["scar_anchors"] = anchors

    var boss := _find_node(plan.get("nodes", []), str(config.get("protected_story_order", []).back()))
    boss["module_id"] = str(config.get("protected_boss_module", ""))


static func _optional_pool_for_role(config: Dictionary, role: String, rng: RandomNumberGenerator) -> String:
    var candidates: Array = []
    var pools: Array = config.get("secret_room_pools", []) if role == "secret" else config.get("optional_room_pools", [])
    for entry in pools:
        if role in entry.get("roles", []):
            candidates.append(entry)
    candidates.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return str(a.get("pool", "")) < str(b.get("pool", "")))
    var selected := _weighted_pick(candidates, rng)
    if not selected.is_empty():
        return str(selected.get("pool", ""))
    if not candidates.is_empty():
        return "" # Explicitly disabled pools must not be re-enabled by fallback.
    # Preserve the existing service-room compatibility policy for generic roles.
    return "accord_service_rooms" if role != "secret" else ""


static func _source_pool(config: Dictionary, pool: String) -> String:
    return str(config.get("module_pool_fallbacks", {}).get(pool, pool))


static func _weighted_pick(candidates: Array, rng: RandomNumberGenerator) -> Dictionary:
    var total := 0.0
    for candidate in candidates:
        var weight := float(candidate.get("weight", 1.0))
        if is_finite(weight):
            total += maxf(0.0, weight)
    if total <= 0.0:
        return {}
    var roll := rng.randf() * total
    var last: Dictionary = {}
    for candidate in candidates:
        var weight := maxf(0.0, float(candidate.get("weight", 1.0)))
        if not is_finite(weight) or weight <= 0.0:
            continue
        last = candidate
        roll -= weight
        if roll < 0.0:
            return candidate
    return last


static func _module_ids(library: Dictionary) -> Dictionary:
    var result := {}
    for module in library.get("modules", []):
        result[str(module.get("module_id", ""))] = module
    return result

static func _find_node(nodes: Array, room_id: String) -> Dictionary:
    for node in nodes:
        if str(node.get("id", "")) == room_id:
            return node
    return {}

static func compatible(module: Dictionary, config: Dictionary) -> bool:
    var weight := float(module.get("weight", 1.0))
    if not is_finite(weight) or weight <= 0.0 or module.get("connectors", []).is_empty():
        return false
    var biomes: Array = config.get("biome_tags", [])
    if biomes.is_empty():
        return true
    for tag in module.get("biome_tags", []):
        if tag in biomes:
            return true
    return false
