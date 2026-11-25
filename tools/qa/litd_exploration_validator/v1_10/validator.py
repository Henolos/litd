from collections import deque, defaultdict
from time import monotonic
from jsonschema import Draft202012Validator

# First extension of the V0 state model; no runtime integration.
def validate(g, schema, max_states=10000, max_seconds=5):
    Draft202012Validator.check_schema(schema)
    errors=list(Draft202012Validator(schema).iter_errors(g))
    if errors: return 'invalid_schema'
    nodes={n['id']:n for n in g['nodes']}
    if len(nodes)!=len(g['nodes']) or g['entry_id'] not in nodes or not set(g['objectives'])<=nodes.keys(): return 'invalid'
    if any(e['from'] not in nodes or e['to'] not in nodes for e in g['edges']): return 'invalid'
    def arrive(p,keys,seen):
        if p not in seen: keys=keys|frozenset(nodes[p].get('grants',[]))
        return p,keys,seen|{p}
    start=arrive(g['entry_id'],frozenset(),frozenset())
    q=deque([start]); visited={start}; reverse=defaultdict(set); goals=set(); exits=set(); deadline=monotonic()+max_seconds
    while q:
        if len(visited)>max_states or monotonic()>=deadline: return 'indeterminate'
        s=q.popleft(); p,keys,seen=s
        if (nodes[p].get('exit') and set(nodes[p].get('refuge_requires', [])) <= keys and not (set(nodes[p].get('refuge_blocks', [])) & keys)):
            exits.add(s)
            if set(g['objectives'])<=seen: goals.add(s)
        for e in g['edges']:
            consume=frozenset(e.get('consumes',[]))
            if e['from']==p and (consume|frozenset(e.get('requires',[]))|frozenset(e.get('secret_requires',[]))|frozenset(e.get('narrative_requires',[])))<=keys:
                t=arrive(e['to'],keys-consume,seen); reverse[t].add(s)
                if t not in visited:
                    visited.add(t); q.append(t)
                    if len(visited)>max_states: return 'indeterminate'
    if not goals: return 'invalid'
    # Every reachable state must retain a route to an exit (abandonment allowed).
    safe=set(exits); q=deque(exits)
    while q:
        if monotonic()>=deadline: return 'indeterminate'
        for s in reverse[q.popleft()]:
            if s not in safe: safe.add(s); q.append(s)
    return 'valid' if safe==visited else 'invalid'
