# Hybrid dungeon graph: connected mandatory rooms

Scope: Les Veilleurs world generator (`scripts/world/hybrid_dungeon_generator.gd`).
The original LITD roguelike generator under `scripts/core` is unchanged.

## Problem and change

Mandatory authored rooms were appended without edges. Presence-only validation
accepted inaccessible rooms. The First Accord planner subsequently rebuilt its
protected spine, masking this defect for that consumer.

The generator now replaces generic critical-path slots with mandatory rooms,
respects the configured protected order, rebuilds a continuous directed spine,
and updates its entry/objective IDs. Optional rooms, secrets, retry limits and
authored fallback remain in the existing generator pipeline.

Validation rejects duplicate/empty IDs, dangling edges, absent entry/objective,
inaccessible ordinary or mandatory rooms, mandatory rooms with no visible route
to the objective, broken protected story order, and retreat metadata without
actual retreat flags.

## Validation

Base: `6282a9fa9d82477f326cb24b77376ae841be9b0a`.
Godot: `4.7.2.stable.official.ed1daf0bf`, matching repository CI.

- Project import: exit 0, no GDScript errors.
- New Godot smoke: 100 seeds for First Accord + 100 seeds for Voices under
  Sanctuary; full graph reproducibility; authored entry/finale identity;
  disconnected mandatory rooms, dangling edges, duplicate IDs and stale retreat
  counts rejected. Passed in full project and in isolated project without
  autoloads. Isolated run has no exit/resource errors.
- Same smoke against original generator: exit 1, demonstrating regression
  sensitivity.
- Python: 30 passed across first-accord hybrid data, hybrid generation,
  physical First Veil and ancient first-map contracts.
- `git diff --check`: passed.
- Smoke included in existing Godot / veilleurs CI domain.

## Existing limitation

`remanence_smoke.tscn` prints REMANENCE_SMOKE_OK but also reports a SCRIPT ERROR:
argument 2 of `dungeon_proxy_room.configure` is an untyped Array rather than the
required typed Array (`remanence_smoke_test.gd:214`). Reproduced independently
on unchanged base commit. It is not a passing integration test.
Resource-in-use warnings at full-project shutdown also reproduce on baseline;
the isolated generator run is clean.

## Remaining work

This increment fixes graph connectivity; it does not certify physical placement,
module compatibility, lock/key solvability, boss-bypass prevention or playtest
quality. First Accord retains its subsequent protected-spine reconstruction.
Production generation still requires validating the completed planner and
physical maps, then a player playtest. No code from third-party mods was copied.

## Source

Godot RandomNumberGenerator documentation: a fixed seed reproduces a sequence
within the same engine version; the algorithm is not a cross-version contract.
https://docs.godotengine.org/en/4.7/classes/class_randomnumbergenerator.html
