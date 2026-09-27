import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SKILL_FILES = [
    "data/veilleurs/skills/mathilde.json",
    "data/veilleurs/skills/marec.json",
    "data/veilleurs/skills/anouk.json",
    "data/veilleurs/skills/aurelien.json",
]

def load(path):
    return json.loads((ROOT / path).read_text(encoding="utf-8"))

def canonical_skills():
    out = {}
    for path in SKILL_FILES:
        data = load(path)
        fields = data["fields"]
        for tree_key in data["tree_order"]:
            for row in data["trees"][tree_key]["skills"]:
                item = dict(zip(fields, row))
                out[item["ID"]] = item
    return out

def test_build_skill_references_are_canonical():
    skills = canonical_skills()
    builds = load("data/veilleurs/skills/affliction_build_synergies.json")["builds"]
    for build in builds.values():
        referenced = build["opener"] + build["payoffs"] + build["support"]
        assert referenced
        for skill_id in referenced:
            assert skill_id in skills
            assert skills[skill_id]["Veilleur"] == build["hero"]

def test_builds_have_openers_payoffs_and_support():
    builds = load("data/veilleurs/skills/affliction_build_synergies.json")["builds"]
    for build in builds.values():
        assert build["afflictions"]
        assert build["opener"]
        assert build["payoffs"]
        assert build["support"]
        assert build["loop"]

def test_only_validated_afflictions_are_in_live_builds():
    data = load("data/veilleurs/skills/affliction_build_synergies.json")
    live = {a for b in data["builds"].values() for a in b["afflictions"]}
    prototypes = set(data["policy"]["prototype_afflictions"])
    assert live <= {"bleed", "blind", "stun", "vulnerability", "weakness", "silence", "snare"}
    assert not live & prototypes

def test_cross_build_synergies_do_not_add_free_damage_multipliers():
    data = load("data/veilleurs/skills/affliction_build_synergies.json")
    for synergy in data["cross_build_synergies"]:
        effect = synergy["effect"].lower()
        assert "x2" not in effect
        assert "double damage" not in effect
        assert "dégâts doublés" not in effect
