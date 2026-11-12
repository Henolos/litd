import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_cinematic_proxemics_use_only_canonical_quartet() -> None:
    data = json.loads((ROOT / "data" / "relationship_proxemics.json").read_text(encoding="utf-8"))
    pairs = set(data["pair_defaults"])
    assert pairs == {
        "mathilde:aurelien",
        "mathilde:marec",
        "mathilde:anouk",
        "aurelien:marec",
        "aurelien:anouk",
        "marec:anouk",
    }

    serialized = json.dumps(data, ensure_ascii=False).lower()
    for legacy_name in ("darius", "malvor", "lysandra"):
        assert legacy_name not in serialized
