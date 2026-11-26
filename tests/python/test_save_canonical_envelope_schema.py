import copy
import json
from pathlib import Path

import pytest
from jsonschema import Draft202012Validator

ROOT = Path(__file__).resolve().parents[2]
SCHEMA = json.loads((ROOT / "docs/reconstruction/save_canonical_envelope_v1.schema.json").read_text(encoding="utf-8"))
VALIDATOR = Draft202012Validator(SCHEMA)


def fixture():
    return {"schema_version": 1, "campaign_id": "fixture", "revision": 4,
            "persistent_state": {"heroes": [{"id": "a", "alive": False}],
                                 "future_module": {"unknown": [None, True, 3.5, "值"]}}}


def test_schema_and_unknown_fields():
    Draft202012Validator.check_schema(SCHEMA)
    state = fixture()
    original = copy.deepcopy(state)
    VALIDATOR.validate(state)
    assert state == original


@pytest.mark.parametrize("key,value", [
    ("schema_version", 2), ("schema_version", True), ("campaign_id", ""),
    ("revision", -1), ("revision", 1.5), ("revision", True),
    ("persistent_state", []), ("unexpected", 1),
])
def test_invalid_envelope(key, value):
    state = fixture()
    state[key] = value
    assert not VALIDATOR.is_valid(state)


@pytest.mark.parametrize("key", ["schema_version", "campaign_id", "revision", "persistent_state"])
def test_required_fields(key):
    state = fixture()
    del state[key]
    assert not VALIDATOR.is_valid(state)


@pytest.mark.parametrize("key", ["metadata", "qa_snapshot", "runtime_cache", "animations", "ui_state"])
def test_root_exclusions_only(key):
    state = fixture()
    state["persistent_state"]["future_module"][key] = "preserved"
    VALIDATOR.validate(state)
    state["persistent_state"][key] = "excluded"
    assert not VALIDATOR.is_valid(state)
