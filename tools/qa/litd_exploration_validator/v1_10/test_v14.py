import unittest,json
from pathlib import Path
from expedition_validator import analyze,PersistentState
from test_expedition import graph,S
S4=json.loads(Path(__file__).with_name('graph_v1_4.schema.json').read_text())
class Audit(unittest.TestCase):
 def test_negative(self): self.assertEqual(analyze(graph(),S,PersistentState((('key',-5),))).status,'invalid_schema')
 def test_duplicate(self): self.assertEqual(analyze(graph(),S,PersistentState((('key',1),('key',2)))).status,'invalid_schema')
 def test_reward_effect(self):
  g=graph();g['edges'][0].update(reward_id='r1',add_narrative=['duplicate'],add_world=['duplicate']);r=analyze(g,S);p=next(iter(r.exits));self.assertNotIn('duplicate',p.narrative);self.assertNotIn('duplicate',p.world)
 def blocked(self):
  g=graph();g['nodes'].append({'id':'d','exit':True});g['edges'].append({'from':'a','to':'d','remove_resources':{'key':2}});return g
 def test_objective_block(self): self.assertEqual(analyze(self.blocked(),S).status,'invalid')
 def test_abandon(self):
  g=self.blocked();g.update(schema_version=4,abandonable_objectives=['c']);g['nodes'][-1]['allow_abandon']=True;g['nodes'][-1]['add_narrative']=['abandoned'];r=analyze(g,S4);self.assertEqual(r.status,'valid');p=next(iter(r.abandoned));self.assertIn('abandoned',p.narrative)
 def test_no_permission(self):
  g=self.blocked();g.update(schema_version=4,abandonable_objectives=['c']);self.assertEqual(analyze(g,S4).status,'invalid')
 def test_optional(self):
  g=graph();g.update(schema_version=4,optional_objectives=['b']);self.assertEqual(analyze(g,S4).status,'valid')
 def test_bad_prior(self): self.assertEqual(analyze(graph(),S,PersistentState(narrative=frozenset({3}))).status,'invalid_schema')
