from __future__ import annotations

from pathlib import Path

from tools.qa.combat_turn_audit import run as combat_turn_audit
from tools.qa.displacement_combat_audit import run as displacement_combat_audit
from tools.qa.enemy_family_tactics_audit import run as enemy_family_tactics_audit
from tools.qa.tactical_combat_audit import run as tactical_combat_audit
from tools.qa.veilleurs_canonical_skills_audit import audit as canonical_skills_audit
from tools.qa.veilleurs_playtest_readiness_audit import validate as playtest_readiness_audit
from tools.qa.veilleurs_vs001_persistence_ui_audit import audit as persistence_ui_audit
from tools.qa.veilleurs_vs001_playable_audit import audit as playable_slice_audit

ROOT = Path(__file__).resolve().parents[2]


def _text(path: str) -> str:
    return (ROOT / path).read_text(encoding="utf-8")


def _assert_report_green(report: dict) -> None:
    failures = [
        f"{item['name']}: {item.get('detail', '')}"
        for item in report.get("checks", [])
        if not item.get("ok", False)
    ]
    assert not failures, failures


def test_01_characters_and_stats_are_connected_to_runtime() -> None:
    game_state = _text("scripts/core/game_state.gd")
    for token in (
        "for hero in DataLoader.heroes:",
        "HeroSkillManager.prepare_hero(prepared_hero)",
        "CharacterTraitDirector.prepare_character(",
        "PersistentInjuryRuntime.prepare_character(prepared_hero)",
    ):
        assert token in game_state

    report = combat_turn_audit(ROOT)
    assert report["missing_stats"] == []


def test_02_skills_and_effects_use_the_canonical_veilleurs_contract() -> None:
    assert canonical_skills_audit() == []

    sandbox = _text("scripts/core/veilleurs_combat_sandbox_runtime.gd")
    for token in (
        'const HIT_RESOLVER := preload("res://scripts/core/combat/veilleurs_hit_resolver.gd")',
        'const DAMAGE_RESOLVER := preload("res://scripts/core/combat/veilleurs_damage_resolver.gd")',
        'const ANATOMY_RESOLVER := preload("res://scripts/core/combat/veilleurs_anatomy_resolver.gd")',
        'const COMBAT_EVENT := preload("res://scripts/core/combat/veilleurs_combat_event.gd")',
    ):
        assert token in sandbox


def test_03_states_and_statuses_are_resolved_in_the_combat_pipeline() -> None:
    sandbox = _text("scripts/core/veilleurs_combat_sandbox_runtime.gd")
    status = _text("scripts/core/combat/veilleurs_status_resolver.gd")

    assert 'const STATUS_RESOLVER := preload("res://scripts/core/combat/veilleurs_status_resolver.gd")' in sandbox
    assert "STATUS_RESOLVER.resolve_after_hit" in sandbox
    for state in ("pain_state", "bleeding_state", "vital_state", "public_vital_state"):
        assert state in status


def test_04_enemy_ai_keeps_family_tactics_and_observed_reactions() -> None:
    _assert_report_green(enemy_family_tactics_audit(ROOT))

    sandbox = _text("scripts/core/veilleurs_combat_sandbox_runtime.gd")
    reaction = _text("scripts/core/combat/veilleurs_reaction_resolver.gd")
    assert 'const REACTION_RESOLVER := preload("res://scripts/core/combat/veilleurs_reaction_resolver.gd")' in sandbox
    assert "REACTION_RESOLVER.observe_enemy" in sandbox
    assert '"decision":"guard_zone"' in reaction


def test_05_equipment_and_loot_share_persistent_item_instances() -> None:
    equipment = _text("scripts/core/equipment_manager.gd")
    expedition = _text("scripts/core/expedition_manager.gd")
    save = _text("scripts/core/save_manager.gd")

    for token in (
        "func generate_item(",
        "func add_generated_item(",
        '"instance_id"',
        "func serialize()",
        "func deserialize(data: Dictionary)",
    ):
        assert token in equipment
    assert "func generate_roguelike_loot(" in expedition
    assert '"equipment": EquipmentManager.serialize()' in save
    assert "EquipmentManager.deserialize(payload.get("equipment",{}))" in save


def test_06_inventory_has_one_authority_instead_of_a_duplicate_manager() -> None:
    project = _text("project.godot")
    equipment = _text("scripts/core/equipment_manager.gd")

    assert 'EquipmentManager="*res://scripts/core/equipment_manager.gd"' in project
    assert "InventoryManager=" not in project
    for token in (
        "signal inventory_changed(items: Array)",
        "var items: Array[Dictionary] = []",
        "var guild_stash: Array[Dictionary] = []",
        "var equipped_by_hero: Dictionary = {}",
        "store_in_guild_stash",
        "withdraw_from_guild_stash",
    ):
        assert token in equipment


def test_07_expeditions_connect_generation_inventory_and_save_state() -> None:
    project = _text("project.godot")
    expedition = _text("scripts/core/expedition_manager.gd")
    save = _text("scripts/core/save_manager.gd")

    assert 'ExpeditionManager="*res://scripts/core/expedition_manager.gd"' in project
    for token in (
        "func start_expedition(",
        "roguelike_runtime.start_run(expedition_seed)",
        "func generate_roguelike_loot(",
        "func add_loot_to_expedition(",
        "func serialize()",
        "func deserialize(data: Dictionary)",
    ):
        assert token in expedition
    assert '"expedition": ExpeditionManager.serialize()' in save
    assert "ExpeditionManager.deserialize(payload.get("expedition",{}))" in save


def test_08_save_and_remanence_round_trip_the_systemic_state() -> None:
    assert persistence_ui_audit() == []

    project = _text("project.godot")
    save = _text("scripts/core/save_manager.gd")
    for token in (
        'RemanenceRuntime="*res://scripts/core/remanence_runtime.gd"',
        'SaveManager="*res://scripts/core/save_manager.gd"',
    ):
        assert token in project
    assert '"remanence": RemanenceRuntime.serialize()' in save
    assert "RemanenceRuntime.deserialize(payload.get("remanence",{}))" in save
    assert '"veilleurs": _build_veilleurs_payload()' in save
    assert "VeilleursRuntime.deserialize(veilleurs_payload)" in save


def test_09_ui_ux_is_connected_to_the_playable_slice_contract() -> None:
    assert playable_slice_audit() == []
    assert persistence_ui_audit() == []

    project = _text("project.godot")
    for token in (
        'CombatantInspectionUI="*res://scripts/ui/combatant_inspection_ui.gd"',
        'ContextMenuUI="*res://scripts/ui/context_menu_ui_v3.gd"',
        'RemanenceArchivesUI="*res://scripts/ui/remanence_archives_ui.gd"',
    ):
        assert token in project


def test_10_vertical_slice_is_technically_ready_without_faking_human_playtests() -> None:
    assert playable_slice_audit() == []
    assert playtest_readiness_audit() == []

    readiness = _text("data/veilleurs/playtest_readiness_contract.json")
    assert '"cannot_promote_player_maturity": true' in readiness
    assert '"human_results_start_not_run": true' in readiness


def test_tactical_movement_and_corpses_are_in_the_same_validation_gate() -> None:
    _assert_report_green(tactical_combat_audit(ROOT))
    _assert_report_green(displacement_combat_audit(ROOT))
    assert canonical_skills_audit() == []

    project = _text("project.godot")
    corpse_runtime = _text("scripts/core/veilleurs_corpse_interaction_runtime.gd")
    assert 'VeilleursCorpseInteractionRuntime="*res://scripts/core/veilleurs_corpse_interaction_runtime.gd"' in project
    assert "RemanenceRuntime.update_world_scar" in corpse_runtime
    assert 'payload["corpse_state"] = "moved"' in corpse_runtime
