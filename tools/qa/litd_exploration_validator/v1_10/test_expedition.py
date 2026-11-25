import unittest,json
from pathlib import Path
from expedition_validator import analyze, PersistentState
S=json.loads(Path(__file__).with_name('graph_v1_3.schema.json').read_text())
def graph():
 return dict(schema_version=3,map_id='m',expedition_id='e',region_id='r',entry_id='a',nodes=[{'id':'a','exit':True,'add_resources':{'key':2},'reward_id':'r1'},{'id':'b'},{'id':'c','exit':True,'add_narrative':['done'],'add_world':['bridge']}],edges=[{'from':'a','to':'b','remove_resources':{'key':1}},{'from':'b','to':'c','remove_resources':{'key':1}}],objectives=['c'])
class ExpeditionTests(unittest.TestCase):
 def test_two_keys(self): self.assertEqual(analyze(graph(),S).status,'valid')
 def test_insufficient(self):
  g=graph();g['nodes'][0]['add_resources']['key']=1;self.assertEqual(analyze(g,S).status,'invalid')
 def test_zero(self):
  g=graph();g['nodes'][0]['add_resources']['key']=0;self.assertEqual(analyze(g,S).status,'invalid_schema')
 def test_snapshot(self):
  r=analyze(graph(),S);self.assertEqual(r.exits,frozenset({PersistentState((),frozenset(),frozenset({'done'}),frozenset({'bridge'}),frozenset({'r1'}))}))
 def test_next_expedition(self):
  prior=next(iter(analyze(graph(),S).exits));g=graph();g['expedition_id']='e2';g['edges']=[{'from':'a','to':'c','require_narrative':['done'],'require_world':['bridge']}];r=analyze(g,S,prior);self.assertEqual(r.status,'valid');self.assertEqual(next(iter(r.exits)).resources,())
 def test_reward_edge(self):
  g=graph();g['edges'][0].update(reward_id='r1',add_resources={'key':5});r=analyze(g,S);self.assertEqual(next(iter(r.exits)).resources,())
 def test_budget(self): self.assertEqual(analyze(graph(),S,max_states=1).status,'indeterminate')
 def test_context_reset(self):
  g=graph();g['nodes'][2]['add_context']=['combat'];p=next(iter(analyze(g,S).exits));g['edges']=[{'from':'a','to':'c','block_context':['combat']}];self.assertEqual(analyze(g,S,p).status,'valid')
