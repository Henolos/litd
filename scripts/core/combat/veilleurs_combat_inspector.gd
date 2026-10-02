extends RefCounted
class_name VeilleursCombatInspector

signal entry_recorded(entry: Dictionary)

const DEFAULT_MAX_ENTRIES := 256

var enabled := OS.has_feature("debug")
var max_entries := DEFAULT_MAX_ENTRIES
var _entries: Array[Dictionary] = []
var _next_sequence := 1

func set_enabled(value: bool) -> void:
    enabled = value

func set_max_entries(value: int) -> void:
    max_entries = maxi(1, value)
    _trim_to_limit()

func clear() -> void:
    _entries.clear()
    _next_sequence = 1

func record(event: Dictionary, context: Dictionary = {}) -> void:
    if not enabled or event.is_empty():
        return
    var entry := {
        "sequence": _next_sequence,
        "event": event.duplicate(true),
        "context": context.duplicate(true),
    }
    _next_sequence += 1
    _entries.append(entry)
    _trim_to_limit()
    entry_recorded.emit(entry.duplicate(true))

func entries() -> Array[Dictionary]:
    return _entries.duplicate(true)

func latest() -> Dictionary:
    if _entries.is_empty():
        return {}
    return _entries[-1].duplicate(true)

func query(filters: Dictionary = {}) -> Array[Dictionary]:
    var matches: Array[Dictionary] = []
    for entry in _entries:
        if _matches(entry, filters):
            matches.append(entry.duplicate(true))
    return matches

func summary() -> Dictionary:
    var by_type: Dictionary = {}
    var by_source: Dictionary = {}
    var hits := 0
    var misses := 0
    var total_damage := 0
    for entry in _entries:
        var event: Dictionary = entry.get("event", {})
        var payload: Dictionary = event.get("payload", {})
        var context: Dictionary = entry.get("context", {})
        var event_type := str(event.get("type", "event"))
        var source := str(context.get("source", "unknown"))
        by_type[event_type] = int(by_type.get(event_type, 0)) + 1
        by_source[source] = int(by_source.get(source, 0)) + 1
        if event_type == "attack_hit":
            hits += 1
        elif event_type == "attack_miss":
            misses += 1
        total_damage += maxi(0, int(payload.get("damage", 0)))
    return {
        "entries": _entries.size(),
        "hits": hits,
        "misses": misses,
        "total_damage": total_damage,
        "by_type": by_type,
        "by_source": by_source,
    }

func formatted_lines(filters: Dictionary = {}) -> Array[String]:
    var lines: Array[String] = []
    for entry in query(filters):
        lines.append(format_entry(entry))
    return lines

static func format_entry(entry: Dictionary) -> String:
    var event: Dictionary = entry.get("event", {})
    var payload: Dictionary = event.get("payload", {})
    var context: Dictionary = entry.get("context", {})
    var pieces: Array[String] = []
    pieces.append("#%s %s %s -> %s" % [
        str(entry.get("sequence", "?")),
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

func _trim_to_limit() -> void:
    var limit := maxi(1, max_entries)
    while _entries.size() > limit:
        _entries.pop_front()

static func _matches(entry: Dictionary, filters: Dictionary) -> bool:
    if filters.is_empty():
        return true
    var event: Dictionary = entry.get("event", {})
    var context: Dictionary = entry.get("context", {})
    if filters.has("type") and str(event.get("type", "")) != str(filters.get("type", "")):
        return false
    if filters.has("actor_id") and str(event.get("actor_id", "")) != str(filters.get("actor_id", "")):
        return false
    if filters.has("target_id") and str(event.get("target_id", "")) != str(filters.get("target_id", "")):
        return false
    if filters.has("source") and str(context.get("source", "")) != str(filters.get("source", "")):
        return false
    return true
