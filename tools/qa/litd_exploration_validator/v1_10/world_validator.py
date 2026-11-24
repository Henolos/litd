from collections import deque, defaultdict
from time import monotonic
from jsonschema import Draft202012Validator
from validator import validate as legacy_validate

def validate(g, schema, max_states=10000, max_seconds=5):
    if g.get('schema_version') != 2:
        return legacy_validate(g,schema,max_states,max_seconds)
    deadline=monotonic()+max_seconds
    Draft202012Validator.check_schema(schema)
    if not Draft202012Validator(schema).is_valid(g): return 'invalid_schema'
    nodes={n['id']:n for n in g['nodes']}
    if len(nodes)!=len(g['nodes']) or g['entry_id'] not in nodes or not set(g['objectives'])<=nodes.keys(): return 'invalid'
    if any(e['from'] not in nodes or e['to'] not in nodes for e in g['edges']): return 'invalid'
    kinds=('resources','discoveries','narrative','context','world')
    def effects(state, obj):
        vals=[set(x) for x in state]
        for i,k in enumerate(kinds):
            vals[i].difference_update(obj.get('remove_'+k,[]))
            vals[i].update(obj.get('add_'+k,[]))
        return tuple(map(frozenset,vals))
    def allowed(vals,obj):
        return all(set(obj.get('require_'+k,[]))<=v and not set(obj.get('block_'+k,[]))&v for k,v in zip(kinds,vals))
    def arrive(p,vals,seen):
        if p not in seen: vals=effects(vals,nodes[p])
        return p,vals,seen|{p}
    start=arrive(g['entry_id'],tuple(frozenset(g.get('initial_'+k,[])) for k in kinds),frozenset())
    q=deque([start]); visited={start}; reverse=defaultdict(set); exits=set(); goals=set()
    while q:
        if len(visited)>max_states or monotonic()>=deadline: return 'indeterminate'
        s=q.popleft(); p,vals,seen=s; n=nodes[p]
        if n.get('exit') and allowed(vals,n.get('refuge',{})):
            exits.add(s)
            if set(g['objectives'])<=seen: goals.add(s)
        for e in g['edges']:
            if monotonic()>=deadline: return 'indeterminate'
            if e['from']!=p or not allowed(vals,e): continue
            t=arrive(e['to'],effects(vals,e),seen); reverse[t].add(s)
            if t not in visited:
                visited.add(t); q.append(t)
                if len(visited)>max_states: return 'indeterminate'
    if not goals: return 'invalid'
    safe=set(exits); q=deque(exits)
    while q:
        if monotonic()>=deadline: return 'indeterminate'
        for s in reverse[q.popleft()]:
            if s not in safe: safe.add(s); q.append(s)
    return 'valid' if safe==visited else 'invalid'
