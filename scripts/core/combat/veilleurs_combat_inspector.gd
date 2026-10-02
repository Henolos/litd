extends RefCounted
class_name VeilleursCombatInspector

const DEFAULT_MAX_ENTRIES := 256

var enabled := OS.has_feature("debug")
var max_entries := DEFAULT_MAX_ENTRIES
var _entries: Array[Dictionary] = []

func set_enabled(value: bool) -> void:
    enabled = value

func clear() -> void:
    _entries.clear()

func record(event: Dictionary, context: Dictionary = {}) -> void:
    if not enabled or event.is_empty():
        return
    var entry := {
        "event": event.duplicate(true),
        "context": context.duplicate(true),
    }
    _entries.append(entry)
    while _entries.size() > maxi(1, max_entries):
        _entries.pop_front()

func entries() -> Array[Dictionary]:
    return _entries.duplicate(true)

func latest() -> Dictionary:
    if _entries.is_empty():
        return {}
    return _entries[-1].duplicate(true)

func formatted_lines() -> Array[String]:
    var lines: Array[String] = []
    for entry in _entries:
        lines.append(format_entry(entry))
    return lines

static func format_entry(entry: Dictionary) -> String:
    var event: Dictionary = entry.get("event", {})
    var payload: Dictionary = event.get("payload", {})
    var context: Dictionary = entry.get("context", {})
    var pieces: Array[String] = []
    pieces.append("%s %s -> %s" % [
        str(event.get("type", "event")),
        str(event.get("actor_id", "?")),
        str(event.get("target_id", "?")),
    ])
    if payload.has("damage"):
        pieces.append("damage=%s" % str(payload.get("damage")))
    if payload.has("roll"):
        pieces.append("roll=%s" % str(payload.get("roll")))
    if payload.has("accuracy"):
        pieces.append("accuracy=%s" % str(payload.get("accuracy")))
    elif payload.has("hit_chance"):
        pieces.append("accuracy=%s" % str(payload.get("hit_chance")))
    if payload.has("critical"):
        pieces.append("critical=%s" % str(payload.get("critical")))
    if payload.has("zone"):
        pieces.append("zone=%s" % str(payload.get("zone")))
    if context.has("round"):
        pieces.append("round=%s" % str(context.get("round")))
    if context.has("source"):
        pieces.append("source=%s" % str(context.get("source")))
    return " | ".join(pieces)
