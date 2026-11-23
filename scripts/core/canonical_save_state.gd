extends RefCounted
class_name LITDCanonicalSaveState

# Canonical projection for persistent state only. Callers must provide the
# domain-approved persistent state; transient fields are rejected, not stripped.
const SCHEMA_VERSION := 1
const EXCLUDED_ROOT_FIELDS := ["metadata", "qa_snapshot", "runtime_cache", "animations", "ui_state"]

static func canonical_body(campaign_id: String, revision: int, persistent_state: Dictionary) -> String:
    if campaign_id.is_empty() or revision < 0:
        return ""
    for field in EXCLUDED_ROOT_FIELDS:
        if persistent_state.has(field):
            return ""
    if not _supported(persistent_state):
        return ""
    var record := {
        "schema_version": SCHEMA_VERSION,
        "campaign_id": campaign_id,
        "revision": revision,
        "persistent_state": persistent_state
    }
    # Godot JSON.stringify sorts dictionary keys recursively when sort_keys=true.
    return JSON.stringify(record, "", true, true)

static func canonical_sha256(campaign_id: String, revision: int, persistent_state: Dictionary) -> String:
    var body := canonical_body(campaign_id, revision, persistent_state)
    return "" if body.is_empty() else body.sha256_text()

static func _supported(value: Variant) -> bool:
    match typeof(value):
        TYPE_NIL, TYPE_BOOL, TYPE_INT, TYPE_STRING:
            return true
        TYPE_FLOAT:
            return is_finite(value)
        TYPE_ARRAY:
            for entry in value:
                if not _supported(entry):
                    return false
            return true
        TYPE_DICTIONARY:
            for key in value.keys():
                if typeof(key) != TYPE_STRING or not _supported(value[key]):
                    return false
            return true
        _:
            return false
