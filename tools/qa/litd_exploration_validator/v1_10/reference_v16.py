"""V1.6 isolated oracle. Exit snapshots are candidates, not committed saves."""
from collections import deque, defaultdict, Counter
from dataclasses import dataclass
from time import monotonic
from pathlib import Path
import json
from jsonschema import Draft202012Validator
from world_validator import validate as previous_validate

@dataclass(frozen=True)
class PersistentState:
    resources: tuple = ()
    discoveries: frozenset = frozenset()
    narrative: frozenset = frozenset()
    world: frozenset = frozenset()
    rewards: frozenset = frozenset()

@dataclass(frozen=True)
class Result:
    status: str
    exits: frozenset = frozenset()
    abandoned: frozenset = frozenset()
    reason: str = ""
    explored: int = 0
    path: tuple = ()

KINDS=('discoveries','narrative','context','world')
def analyze(g,schema,prior=None,max_states=10000,max_seconds=5):
    deadline=monotonic()+max_seconds
    Draft202012Validator.check_schema(schema)
    if not Draft202012Validator(schema).is_valid(g): return Result('invalid_schema')
    if g['schema_version'] not in (3,4,5): return Result(previous_validate(g,schema,max_states,max_seconds))
    nodes={n['id']:n for n in g['nodes']}; objectives=set(g['objectives'])
    if len(nodes)!=len(g['nodes']) or g['entry_id'] not in nodes or not objectives<=nodes.keys(): return Result('invalid')
    adj=defaultdict(list)
    for e in g['edges']:
        if e['from'] not in nodes or e['to'] not in nodes: return Result('invalid')
        adj[e['from']].append(e)
    # Prior snapshot is authoritative; initial persistent fields are bootstrap only.
    prior=prior if prior is not None else PersistentState(tuple(sorted(g.get('initial_resources',{}).items())),frozenset(g.get('initial_discoveries',[])),frozenset(g.get('initial_narrative',[])),frozenset(g.get('initial_world',[])))
    if not isinstance(prior,PersistentState): return Result('invalid_schema')
    if type(prior.resources) is not tuple or any(type(x) is not tuple or len(x)!=2 for x in prior.resources): return Result('invalid_schema')
    if any(type(k) is not str or type(v) is not int for k,v in prior.resources): return Result('invalid_schema')
    if len(dict(prior.resources))!=len(prior.resources): return Result('invalid_schema')
    fields=('discoveries','narrative','world','rewards')
    if any(type(getattr(prior,k)) is not frozenset for k in fields): return Result('invalid_schema')
    payload={'resources':dict(prior.resources),**{k:list(getattr(prior,k)) for k in fields}}
    ps=json.loads(Path(__file__).with_name('persistent_state.schema.json').read_text())
    if not Draft202012Validator(ps).is_valid(payload): return Result('invalid_schema')
    if g['schema_version']==5 and 'closed:'+g['expedition_id'] in prior.narrative:
        return Result('closed',reason='explicit_irreversible_abandonment')
    optional=set(g.get('optional_objectives',[])); abandonable=set(g.get('abandonable_objectives',[]))
    if not optional<=nodes.keys() or not abandonable<=objectives or optional&objectives: return Result('invalid')
    required=objectives-abandonable
    # Only objective visits and one-shot node effects influence future transitions.
    tracked=objectives | {p for p,n in nodes.items() if any(k.startswith(("add_","remove_","require_","block_")) or k=="reward_id" for k in n)}
    def cost(obj,rewards):
        if obj.get("cost_once") and obj.get("reward_id") in rewards: return {}
        return obj.get("remove_resources",{})
    def allowed(inv,vals,obj,rewards=frozenset()):
        c=dict(inv)
        return (all(c.get(k,0)>=v for k,v in obj.get('require_resources',{}).items()) and all(c.get(k,0)<v for k,v in obj.get('block_resources',{}).items()) and all(c.get(k,0)>=v for k,v in cost(obj,rewards).items()) and all(set(obj.get('require_'+k,[]))<=v and not set(obj.get('block_'+k,[]))&v for k,v in zip(KINDS,vals)))
    def effects(inv,vals,rewards,obj):
        c=Counter(dict(inv)); c.subtract(cost(obj,rewards))
        original_rewards=rewards
        rid=obj.get('reward_id')
        if rid is None or rid not in rewards:
            c.update(obj.get('add_resources',{}))
            if rid is not None: rewards=rewards|{rid}
        if rid is None or rid not in original_rewards:
            vals=tuple((v-set(obj.get('remove_'+k,[])))|set(obj.get('add_'+k,[])) for k,v in zip(KINDS,vals))
        return tuple(sorted((k,v) for k,v in c.items() if v>0)),vals,rewards
    def arrive(p,inv,vals,rewards,seen):
        if p not in seen:
            if not allowed(inv,vals,nodes[p],rewards): return None
            inv,vals,rewards=effects(inv,vals,rewards,nodes[p])
        return p,inv,vals,rewards,seen|({p} if p in tracked else set())
    start=arrive(g['entry_id'],prior.resources,(prior.discoveries,prior.narrative,frozenset(g.get('initial_context',[])),prior.world),prior.rewards,frozenset())
    if start is None:return Result('invalid')
    parents={start:None}
    def diagnostic(status,reason,state=None):
        path=[]
        while state is not None:
            path.append(state[0]); state=parents[state]
        return Result(status,reason=reason,explored=len(visited),path=tuple(reversed(path)))
    q=deque([start]); visited={start}; reverse=defaultdict(set); exits=set(); snapshots=set(); goals=set(); abandoned=set(); abandoned_states=set()
    while q:
        if len(visited)>max_states:return diagnostic('indeterminate','state_budget')
        if monotonic()>=deadline:return diagnostic('indeterminate','time_budget')
        s=q.popleft();p,inv,vals,rewards,seen=s
        if nodes[p].get('exit') and allowed(inv,vals,nodes[p].get('refuge',{}),rewards):
            exits.add(s)
            if required<=seen and not objectives<=seen and nodes[p].get('allow_abandon',False):
                abandoned_states.add(s);abandoned.add(PersistentState(inv,vals[0],vals[1]|({'closed:'+g['expedition_id']} if g.get('abandon_closes_expedition') else set()),vals[3],rewards))
            if objectives<=seen:
                goals.add(s);snapshots.add(PersistentState(inv,vals[0],vals[1],vals[3],rewards))
        for e in adj[p]:
            if monotonic()>=deadline:return diagnostic('indeterminate','time_budget')
            if not allowed(inv,vals,e,rewards):continue
            t=arrive(e['to'],*effects(inv,vals,rewards,e),seen)
            if t is None:return diagnostic('invalid','blocked_arrival',s)
            reverse[t].add(s)
            if t not in visited:
                visited.add(t);parents[t]=s;q.append(t)
                if len(visited)>max_states:return diagnostic('indeterminate','state_budget',t)
    if not goals:return diagnostic('invalid','no_completion',s)
    safe=set(goals|abandoned_states);q=deque(safe)
    while q:
        if monotonic()>=deadline:return diagnostic('indeterminate','time_budget')
        for s in reverse[q.popleft()]:
            if s not in safe:safe.add(s);q.append(s)
    return Result('valid',frozenset(snapshots),frozenset(abandoned),explored=len(visited)) if safe==visited else diagnostic('invalid','irreversible_block',min(visited-safe,key=lambda x:(x[0],repr(x))))
