extends RefCounted
class_name DungeonProfile

# Normalize existing authored rules; no second profile catalogue.
const RANGE_KEYS := ["room_count", "critical_length", "branching_target", "loop_target", "secret_target", "retreat_points", "encounter_budget", "resource_budget"]

static func resolve(config: Dictionary, rules: Dictionary) -> Dictionary:
    var profiles: Dictionary = rules.get("default_profiles", {})
    var id_value := str(config.get("profile", "medium"))
    if not profiles.has(id_value):
        return {"ok":false, "errors":["unknown_dungeon_profile:" + id_value]}
    var profile: Dictionary = profiles[id_value].duplicate(true)
    for key in RANGE_KEYS:
        if config.has(key):
            profile[key] = config[key].duplicate() if config[key] is Array else config[key]
    var errors: Array[String] = []
    for key in RANGE_KEYS:
        var value: Variant = profile.get(key, [])
        if not value is Array or value.size() != 2:
            errors.append("invalid_profile_range:" + key)
            continue
        if not (value[0] is int or value[0] is float) or not (value[1] is int or value[1] is float):
            errors.append("invalid_profile_range:" + key)
            continue
        if not is_finite(float(value[0])) or not is_finite(float(value[1])) or float(value[0]) != floor(float(value[0])) or float(value[1]) != floor(float(value[1])) or int(value[0]) < 0 or int(value[1]) < int(value[0]) or int(value[1]) > 1000:
            errors.append("invalid_profile_range:" + key)
        else:
            profile[key] = [int(value[0]), int(value[1])]
    if errors.is_empty():
        if int(profile["critical_length"][0]) < 3 or int(profile["room_count"][0]) < 3 or int(profile["critical_length"][1]) > int(profile["room_count"][1]) or config.get("mandatory_rooms", []).size() > int(profile["room_count"][1]):
            errors.append("incompatible_profile_size")
    profile["id"] = id_value
    profile["biome_tags"] = config.get("biome_tags", []).duplicate()
    return {"ok":errors.is_empty(), "errors":errors, "profile":profile}
