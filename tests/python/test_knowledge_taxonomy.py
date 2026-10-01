import json
from pathlib import Path

from tools.quality import validate_knowledge as guardian


def _taxonomy() -> dict:
    return json.loads(guardian.TAXONOMY.read_text(encoding="utf-8"))


def test_canonical_taxonomy_is_valid():
    assert guardian.validate_taxonomy() == []


def test_taxonomy_cannot_authorize_core_write(tmp_path: Path, monkeypatch):
    payload = _taxonomy()
    payload["principles"]["core_write_allowed"] = True
    path = tmp_path / "taxonomy.json"
    path.write_text(json.dumps(payload), encoding="utf-8")
    monkeypatch.setattr(guardian, "TAXONOMY", path)
    assert "taxonomy must never authorize Core writes" in guardian.validate_taxonomy()


def test_taxonomy_requires_all_navigation_collections(tmp_path: Path, monkeypatch):
    payload = _taxonomy()
    payload["collections"] = [item for item in payload["collections"] if item["id"] != "architecture"]
    path = tmp_path / "taxonomy.json"
    path.write_text(json.dumps(payload), encoding="utf-8")
    monkeypatch.setattr(guardian, "TAXONOMY", path)
    assert any("architecture" in error for error in guardian.validate_taxonomy())


def test_taxonomy_relation_ids_are_unique(tmp_path: Path, monkeypatch):
    payload = _taxonomy()
    payload["relation_types"].append("related")
    path = tmp_path / "taxonomy.json"
    path.write_text(json.dumps(payload), encoding="utf-8")
    monkeypatch.setattr(guardian, "TAXONOMY", path)
    assert "taxonomy relation types must be a unique list" in guardian.validate_taxonomy()
