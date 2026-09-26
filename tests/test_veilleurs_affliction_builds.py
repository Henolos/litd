import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

def _load(path: str) -> dict:
    return json.loads((ROOT / path).read_text(encoding="utf-8"))

def _canonical_rows() -> dict[str, dict]:
    rows: dict[str, dict] = {}
    for watcher in ["mathilde", "marec", "anouk", "aurelien"]:
        data = _load(f"data/veilleurs/skills/{watcher}.json")
        fields = data["fields"]
        for tree_key in data["tree_order"]:
            tree = data["trees"][tree_key]
            for row in tree["skills"]:
                item = dict(zip(fields, row))
                rows[item["ID"]] = item
    return rows

def test_affliction_build_bindings_are_canonical_manual_actions():
    builds = _load("data/veilleurs/skills/affliction_builds.json")
    rows = _canonical_rows()
    bindings = builds["bindings"]
    assert len(bindings) == 7
    assert {entry["affliction"] for entry in bindings.values()} == {
        "bleed", "blind", "stun", "vulnerability", "weakness", "silence", "snare"
    }
    for skill_id, binding in bindings.items():
        assert skill_id in rows
        row = rows[skill_id]
        assert row["Arbre"] == binding["tree"]
        assert row["Type"] in {"Active", "Maîtresse"}
        assert binding["duration"] > 0
        assert binding["delivery"] in {"attack", "control"}

def test_required_tree_affliction_skills_have_explicit_runtime_overrides():
    contract = _load("data/veilleurs/skills/resolver_contract.json")
    overrides = contract["skill_overrides"]
    expected = {
        "MA-DIS-09": "generic_affliction_control",
        "MR-BRI-01": "generic_affliction_attack",
        "MR-BRI-05": "generic_affliction_attack",
        "MR-BRI-09": "generic_affliction_attack",
        "AN-DIS-06": "generic_affliction_control",
    }
    for skill_id, resolver_id in expected.items():
        override = overrides[skill_id]
        assert override["resolver_id"] == resolver_id
        assert override["status"] == "implemented"
        assert override["activation_mode"] == "action"
        assert override["entrypoint"] == "VeilleursAfflictionSkillRuntime.resolve"

def test_affliction_runtime_reuses_shared_status_and_hit_resolvers():
    runtime = (ROOT / "scripts/core/veilleurs_affliction_skill_runtime.gd").read_text(encoding="utf-8")
    router = (ROOT / "scripts/core/veilleurs_skill_resolver_router.gd").read_text(encoding="utf-8")
    assert 'veilleurs_status_resolver.gd' in runtime
    assert 'veilleurs_hit_resolver.gd' in runtime
    assert 'VeilleursStatusResolver' not in runtime
    assert 'AFFLICTION_BUILDS_PATH' in router
    assert '_apply_affliction_overlay' in router
    assert 'STATUS_RESOLVER.apply_affliction' in router
