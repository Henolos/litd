"""Documentary capture model checks; not gameplay tests."""
from pathlib import Path
import re
import pytest

MASTER = Path(__file__).resolve().parents[2] / "docs/conception/LITD1_DOCUMENT_MAITRE.md"

def model(s, mutation="none"):
    allowed = s.get("eligible", False) and (not s.get("restricted") or s.get("ng") or mutation == "ng")
    transfer = bool(allowed and (s.get("victory") or mutation == "defeat") and (not s.get("full") or mutation != "full"))
    return dict(allowed=bool(allowed), transfer=transfer, progress=transfer and mutation != "delay",
                occupied=mutation != "rank", pa=2 if mutation == "pa" else 1,
                identities=2 if mutation == "duplicate" else 1, transport=mutation == "transport")

CASES = [
    ("ng", dict(eligible=True, restricted=True, ng=False, victory=True), "allowed", False),
    ("defeat", dict(eligible=True, victory=False), "transfer", False),
    ("full", dict(eligible=True, victory=True, full=True), "transfer", True),
    ("delay", dict(eligible=True, victory=True, full=True), "progress", True),
    ("rank", {}, "occupied", True),
    ("pa", {}, "pa", 1),
    ("duplicate", {}, "identities", 1),
    ("transport", {}, "transport", False),
]

@pytest.mark.parametrize("mutation,state,key,expected", CASES)
def test_reference_and_mutation(mutation, state, key, expected):
    assert model(state)[key] == expected
    assert model(state, mutation)[key] != expected

def test_documentary_inventory():
    ids = re.findall(r"^- (CAP-[A-K]\d{2}) :", MASTER.read_text(encoding="utf-8"), re.M)
    counts = dict(A=12,B=12,C=12,D=16,E=20,F=12,G=20,I=16,J=20,K=12)
    expected = {f"CAP-{k}{i:02}" for k,n in counts.items() for i in range(1,n+1)}
    assert len(ids) == len(set(ids)) == 152
    assert set(ids) == expected

@pytest.mark.parametrize("rule,phrase", [
    ("CAP-I01", "Aucun transfert automatique"),
    ("CAP-J02", "Aucune saturation"),
    ("CAP-J11", "ne suspend pas"),
    ("CAP-K02", "ne libère pas automatiquement"),
    ("CAP-D12", "Aucun PA supplémentaire"),
    ("CAP-K12", "sans duplication"),
    ("CAP-G03", "ARCH-07"),
])
def test_normative_anchor(rule, phrase):
    lines = MASTER.read_text(encoding="utf-8").splitlines()
    matches = [line for line in lines if line.startswith(f"- {rule} :")]
    assert len(matches) == 1
    assert phrase in matches[0]
