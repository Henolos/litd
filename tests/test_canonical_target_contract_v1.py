from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def _text(path: str) -> str:
    return (ROOT / path).read_text(encoding="utf-8")


def test_target_resolver_is_single_player_targeting_facade() -> None:
    resolver = _text("scripts/core/combat/veilleurs_target_resolver.gd")
    assert 'preload("res://scripts/core/combat_targeting_rules.gd")' in resolver
    assert "static func validate_target_contract" in resolver
    assert "static func body_zones_for_action" in resolver
    assert "static func can_target_body_zone" in resolver
    assert "RULES.can_target" in resolver


def test_sandbox_delegates_resolution_instead_of_reimplementing_it() -> None:
    sandbox = _text("scripts/core/veilleurs_combat_sandbox_runtime.gd")
    adapter = _text("scripts/core/combat/veilleurs_combat_sandbox_canonical_adapter.gd")
    assert 'CANONICAL_ADAPTER.resolve_enemy_action' in sandbox
    assert 'TARGET_RESOLVER.validate_target_contract' in sandbox
    assert 'HIT_RESOLVER.resolve' in adapter
    assert 'DAMAGE_RESOLVER.resolve' in adapter
    assert 'ANATOMY_RESOLVER.resolve' in adapter
    assert 'STATUS_RESOLVER.apply_affliction' in adapter
    assert 'DEATH_RESOLVER.resolve_actor' in adapter


def test_consolidation_does_not_add_parallel_runtime_or_main_layer() -> None:
    assert not (ROOT / "scripts/core/veilleurs_combat_sandbox_runtime_v2.gd").exists()
    assert not (ROOT / "scripts/ui/main_v53.gd").exists()


def test_existing_formation_compaction_remains_canonical() -> None:
    runtime = _text("scripts/core/combat_position_runtime.gd")
    death = _text("scripts/core/combat/veilleurs_death_resolver.gd")
    assert "func compact_enemy_formation" in runtime
    assert "compact_enemy_formation(enemies)" in death
