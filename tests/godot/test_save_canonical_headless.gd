extends SceneTree

const Canonical = preload("res://scripts/core/canonical_save_state.gd")
var failures := 0

func _initialize() -> void:
    call_deferred("_run")

func _check(ok: bool, description: String) -> void:
    if not ok:
        failures += 1
        push_error(description)

func _run() -> void:
    var first := {"party": [{"id": "hero", "hp": 17}], "guild": {"rank": 2, "funds": 30}}
    var reordered := {"guild": {"funds": 30, "rank": 2}, "party": [{"hp": 17, "id": "hero"}]}
    var body := Canonical.canonical_body("campaign-1", 4, first)
    var hash_value := Canonical.canonical_sha256("campaign-1", 4, first)
    _check(not body.is_empty(), "Canonical body must exist")
    _check(body == Canonical.canonical_body("campaign-1", 4, reordered), "Dictionary insertion order must not affect canonical encoding")
    _check(hash_value.length() == 64, "SHA-256 must be 64 hexadecimal characters")
    _check(hash_value == Canonical.canonical_sha256("campaign-1", 4, reordered), "Equivalent state must have identical hash")
    _check(hash_value != Canonical.canonical_sha256("campaign-1", 5, first), "Revision must be hashed")
    _check(hash_value != Canonical.canonical_sha256("campaign-2", 4, first), "Campaign identity must be hashed")
    _check(hash_value != Canonical.canonical_sha256("campaign-1", 4, {"party": [{"id": "hero", "hp": 16}], "guild": {"rank": 2, "funds": 30}}), "Persistent mutation must change hash")
    _check(Canonical.canonical_body("campaign-1", 4, {"metadata": {"timestamp": "now"}}).is_empty(), "Transient root metadata must be rejected")
    _check(Canonical.canonical_body("campaign-1", -1, first).is_empty(), "Negative revision must be rejected")
    _check(Canonical.canonical_body("", 4, first).is_empty(), "Missing campaign ID must be rejected")
    _check(Canonical.canonical_body("campaign-1", 4, {1: "bad-key"}).is_empty(), "Non-string dictionary key must be rejected")
    _check(Canonical.canonical_body("campaign-1", 4, {"bad": Vector2(1, 2)}).is_empty(), "Godot objects must be rejected")
    if failures == 0:
        print("SAVE_CANONICAL_CONTRACT_PASS")
    quit(1 if failures else 0)
