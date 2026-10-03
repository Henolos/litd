from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def _text(path: str) -> str:
    return (ROOT / path).read_text(encoding="utf-8")


def test_target_resolver_owns_rank_and_body_zone_contract() -> None:
    resolver = _text("scripts/core/combat/veilleurs_target_resolver.gd")
    assert 'preload("res://scripts/core/combat_targeting_rules.gd")' in resolver
    assert "static func validate_target_contract" in resolver
    assert "static func body_zones_for_action" in resolver
    assert "static func can_target_body_zone" in resolver
    assert "RULES.can_target" in resolver


def test_sandbox_checks_target_contract_before_canonical_resolution() -> None:
    sandbox = _text("scripts/core/veilleurs_combat_sandbox_runtime.gd")
    assert "TARGET_RESOLVER.validate_target_contract" in sandbox
    assert "CANONICAL_ADAPTER.resolve_enemy_action" in sandbox


def test_existing_death_compaction_remains_the_only_formation_compaction_path() -> None:
    runtime = _text("scripts/core/combat_position_runtime.gd")
    death = _text("scripts/core/combat/veilleurs_death_resolver.gd")
    assert "func compact_enemy_formation" in runtime
    assert "compact_enemy_formation(enemies)" in death
