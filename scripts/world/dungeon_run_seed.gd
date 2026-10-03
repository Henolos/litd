extends RefCounted
class_name DungeonRunSeed

# Versioned names isolate content randomness from topology. Reproducibility is
# guaranteed for the same data, generation version and Godot engine version.
const VERSION := 1
const STREAMS := ["layout", "room", "encounter", "event", "loot", "ai"]

static func compose(config: Dictionary, run_state: Dictionary, attempt_index: int) -> int:
    # Keep the existing layout seed contract, including retry semantics.
    var parts := [
        str(run_state.get("campaign_seed", config.get("campaign_seed", 0))),
        str(config.get("dungeon_id", "unknown_dungeon")),
        str(run_state.get("visit_index", config.get("visit_index", 0))),
        str(run_state.get("difficulty_band", config.get("difficulty_band", "normal"))),
        str(run_state.get("story_epoch", config.get("story_epoch", 0))),
        str(attempt_index)
    ]
    return "|".join(parts).hash()

static func derive(root_seed: int, stream: String, scope: String = "") -> int:
    return ("dungeon_rng_v%d|%d|%s|%s" % [VERSION, root_seed, stream, scope]).hash()

static func streams(root_seed: int) -> Dictionary:
    var result := {}
    for stream in STREAMS:
        result[stream] = root_seed if stream == "layout" else derive(root_seed, stream)
    return result

static func generator(root_seed: int, stream: String, scope: String = "") -> RandomNumberGenerator:
    var rng := RandomNumberGenerator.new()
    rng.seed = root_seed if stream == "layout" and scope == "" else derive(root_seed, stream, scope)
    return rng
