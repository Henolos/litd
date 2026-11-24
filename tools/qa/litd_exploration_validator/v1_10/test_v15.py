import unittest,json
from pathlib import Path
from expedition_validator import analyze
from test_expedition import graph
S=json.loads(Path(__file__).with_name('graph_v1_5.schema.json').read_text())
def g5():
 g=graph();g['schema_version']=5;return g
class V15(unittest.TestCase):
 def test_cost_once(self):
  g=g5();g['edges'][0].update(reward_id='r1',cost_once=True);r=analyze(g,S);self.assertEqual(r.status,'valid');self.assertEqual(next(iter(r.exits)).resources,(('key',1),))
 def test_repeat_cost(self):
  g=g5();g['edges'][0].update(reward_id='r1');self.assertEqual(next(iter(analyze(g,S).exits)).resources,())
 def test_cost_requires_reward(self):
  g=g5();g['edges'][0]['cost_once']=True;self.assertEqual(analyze(g,S).status,'invalid_schema')
 def test_state_budget(self):
  r=analyze(g5(),S,max_states=1);self.assertEqual((r.status,r.reason,r.explored),('indeterminate','state_budget',2))
 def test_time_budget(self): self.assertEqual(analyze(g5(),S,max_seconds=0).reason,'time_budget')
 def test_block_path(self):
  g=g5();g['nodes'].append({'id':'d','exit':True});g['edges'].append({'from':'a','to':'d','remove_resources':{'key':2}});r=analyze(g,S);self.assertEqual((r.status,r.reason,r.path),('invalid','irreversible_block',('a','d')))
 def test_closure(self):
  g=g5();g.update(abandonable_objectives=['c'],abandon_closes_expedition=True);g['nodes'].append({'id':'d','exit':True,'allow_abandon':True});g['edges'].append({'from':'a','to':'d','remove_resources':{'key':2}});r=analyze(g,S);self.assertEqual(r.status,'valid');p=next(iter(r.abandoned));self.assertEqual(analyze(g,S,p).status,'closed');g['expedition_id']='other';self.assertNotEqual(analyze(g,S,p).status,'closed')
