import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]


def test_item_use_costs_action_but_transfer_is_free_for_both_sides():
    rules = json.loads((ROOT / "data/levels/ashlands_survival_rules.json").read_text(encoding="utf-8"))
    transfer = rules["combat_item_transfer"]
    assert rules["version"] >= 4
    assert transfer["personal_carriers"] is True
    assert transfer["using_item_on_ally_costs_action"] is True
    assert transfer["giving_item_to_ally_costs_action"] is False
    assert transfer["transfer_applies_item_effect"] is False
    assert transfer["heroes_and_enemies_share_rule"] is True


def _active_main_ui_chain(scene: str) -> list[str]:
    ui_script = r"(?:main_v\d+(?:_ge01)?|combat_sandbox_ui_v\d+)\.gd"
    match = re.search(
        rf'\[ext_resource path="(res://scripts/ui/{ui_script})" type="Script" id="1"\]',
        scene,
    )
    assert match is not None, "Main.tscn must expose a versioned main UI script as ext_resource id=1"

    chain: list[str] = []
    current = match.group(1)
    for _ in range(32):
        chain.append(current)
        file_path = ROOT / current.removeprefix("res://")
        source = file_path.read_text(encoding="utf-8")
        parent = re.search(
            rf'^extends "(res://scripts/ui/{ui_script})"',
            source,
            re.MULTILINE,
        )
        if parent is None:
            break
        current = parent.group(1)
    return chain
