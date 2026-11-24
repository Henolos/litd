import unittest, random, copy
from expedition_validator import analyze
from reference_v15 import analyze as reference
from test_v15 import S,g5

def branching(n):
 g=g5();g['nodes']=[{'id':'a','exit':True},{'id':'z','exit':True}]+[{'id':f'b{i}'} for i in range(n)];g['objectives']=['z'];g['edges']=[{'from':'a','to':'z'},{'from':'z','to':'a'}]+[e for i in range(n) for e in ({'from':'a','to':f'b{i}'},{'from':f'b{i}','to':'a'})];return g

def semantic(r):
 def snapshots(xs):return { (x.resources,x.discoveries,x.narrative,x.world,x.rewards) for x in xs}
 return r.status,snapshots(r.exits),snapshots(r.abandoned)
class Optimization(unittest.TestCase):
 def test_branching(self):
  g=branching(8);a=analyze(g,S);b=reference(g,S);self.assertEqual(semantic(a),semantic(b));self.assertLess(a.explored,b.explored)
 def test_large(self):self.assertEqual(analyze(branching(16),S).status,'valid')
 def test_dead_end(self):
  g=branching(8);g['edges'].remove({'from':'b7','to':'a'});self.assertEqual(analyze(g,S).status,'invalid')
 def test_differential(self):
  rng=random.Random(42)
  for i in range(100):
   g=branching(3)
   for n in g['nodes'][2:]:
    if rng.random()<.4:n['add_world']=[n['id']]
   for e in g['edges']:
    if rng.random()<.2:e['require_world']=['b0']
    if rng.random()<.2:e['remove_world']=['b0']
   if rng.random()<.4:g['edges'].pop(rng.randrange(len(g['edges'])))
   with self.subTest(i=i):self.assertEqual(semantic(analyze(g,S)),semantic(reference(g,S)))
