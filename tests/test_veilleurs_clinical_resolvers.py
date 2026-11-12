import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def _load(path: str) -> dict:
    return json.loads((ROOT / path).read_text(encoding="utf-8"))


def test_entaille_anatomie_suture_are_explicit_prototype_bridges():
    contract = _load("data/veilleurs/skills/resolver_contract.json")
    assert contract["version"] >= 4
    expected = {
        "Entaille": "anatomical_lesion",
        "Anatomie": "anatomical_diagnostic",
        "Suture": "medical_treatment",
    }
    for tree, resolver_id in expected.items():
        family = contract["tree_families"][tree]
        assert family["resolver_id"] == resolver_id
        assert family["status"] == "prototype_bridge"
        assert family["entrypoint"] == "VeilleursClinicalCombatRuntime.resolve"
        assert family["reaction_entrypoint"] == "VeilleursClinicalReactionRuntime"
        coverage = family["coverage"]
        assert coverage["manual_actions"] is True
        assert coverage["posture"] is True
        assert coverage["reaction_hooks"] is True
        assert coverage["transformation_hooks"] is True


def test_unimplemented_trees_still_cannot_claim_runtime_execution():
    contract = _load("data/veilleurs/skills/resolver_contract.json")
    for tree in ["Bastion", "Brisure", "Serment", "Traque", "Disparition", "Sentence", "Concorde", "Dissidence"]:
        assert contract["tree_families"][tree]["status"] == "required"
