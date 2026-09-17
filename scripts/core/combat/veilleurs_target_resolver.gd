extends RefCounted
class_name VeilleursTargetResolver

const ZONES := ["head", "torso", "left_arm", "right_arm", "left_leg", "right_leg"]

static func normalize_zone(zone: String) -> String:
    return zone if zone in ZONES else "torso"

static func validate_index(collection: Array, index: int) -> Dictionary:
    if index < 0 or index >= collection.size(): return {"ok":false,"reason":"invalid_target"}
    return {"ok":true,"target":collection[index]}
