extends RefCounted
class_name VeilleursCombatKnowledgeAdapter

func capture(actions: Array, combatants: Dictionary, archives: VeilleursArchivesRuntime, context: Dictionary = {}) -> Dictionary:
    var recorded := 0
    var traces := 0
    var entry_ids: Array[String] = []
    var round_index := int(context.get("round", 0))
    for index in range(actions.size()):
        var value: Variant = actions[index]
        if not (value is Dictionary):
            continue
        var action: Dictionary = value
        if not bool(action.get("ok", false)):
            continue
        var actor_id := _actor_id(action)
        if actor_id == "" or not combatants.has(actor_id):
            continue
        var actor: Dictionary = combatants[actor_id]
        if str(actor.get("team", "")) != "enemy":
            continue
        var entry_id := str(actor.get("remanence_id", actor.get("definition_id", actor_id)))
        if entry_id == "":
            continue
        var definition_id := str(actor.get("definition_id", actor_id))
        archives.record_identity(entry_id, "enemy", {
            "name":str(actor.get("name", definition_id)),
            "definition_id":definition_id,
            "family":str(actor.get("family", ""))
        })
        var observation := _observation(action, actor_id, round_index, index, context)
        archives.record_combat_observation(entry_id, observation)
        recorded += 1
        if not entry_ids.has(entry_id):
            entry_ids.append(entry_id)
        if _is_evidence(action):
            archives.record_trace(entry_id, _trace(observation, action))
            traces += 1
    return {
        "recorded":recorded,
        "traces":traces,
        "entry_ids":entry_ids
    }

func _actor_id(action: Dictionary) -> String:
    for key: String in ["attacker", "enemy", "boss", "owner_id"]:
        var value := str(action.get(key, ""))
        if value != "":
            return value
    return ""

func _observation(action: Dictionary, actor_id: String, round_index: int, action_index: int, context: Dictionary) -> Dictionary:
    var action_type := str(action.get("action", "unknown"))
    var skill_id := str(action.get("skill_id", action.get("attack_kind", action_type)))
    var observation_id := "%s:%s:%d:%d" % [
        str(context.get("combat_node_id", "combat")),
        actor_id,
        round_index,
        action_index
    ]
    return {
        "observation_id":observation_id,
        "skill_id":skill_id,
        "pattern":action_type,
        "round":round_index,
        "target":str(action.get("target", "")),
        "zone":str(action.get("zone", "")),
        "hit":bool(action.get("hit", false)),
        "damage":int(action.get("damage", 0)),
        "status_applied":str(action.get("status_applied", "")),
        "decision_reason":str(action.get("decision_reason", "")),
        "memory_used":bool(action.get("memory_used", false)),
        "hypothesis":"enemy_pattern:%s" % skill_id,
        "source":"combat_runtime"
    }

func _is_evidence(action: Dictionary) -> bool:
    return bool(action.get("hit", false)) or int(action.get("damage", 0)) > 0 or str(action.get("status_applied", "")) != ""

func _trace(observation: Dictionary, action: Dictionary) -> Dictionary:
    return {
        "trace_id":"proof:%s" % str(observation.get("observation_id", "")),
        "source":"combat_runtime",
        "skill_id":str(observation.get("skill_id", "")),
        "target":str(observation.get("target", "")),
        "zone":str(observation.get("zone", "")),
        "damage":int(action.get("damage", 0)),
        "body":(action.get("body", {}) as Dictionary).duplicate(true) if action.get("body", {}) is Dictionary else {},
        "status_applied":str(action.get("status_applied", ""))
    }
