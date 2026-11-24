import unittest,json
from pathlib import Path
from world_validator import validate
S=json.loads(Path(__file__).with_name('graph_v1_2.schema.json').read_text())
def graph():
 return dict(schema_version=2,map_id='m',expedition_id='e',region_id='r',entry_id='a',nodes=[{'id':'a','exit':True},{'id':'b','add_resources':['key'],'add_narrative':['key'],'add_discoveries':['secret']},{'id':'c'}],edges=[{'from':'a','to':'b'},{'from':'b','to':'a'},{'from':'b','to':'c','require_resources':['key'],'remove_resources':['key'],'require_discoveries':['secret']},{'from':'c','to':'a','require_narrative':['key']}],objectives=['c'])
class WorldTests(unittest.TestCase):
 def test_separation(self): self.assertEqual(validate(graph(),S),'valid')
 def test_no_narrative_bypass(self):
  g=graph();g['nodes'][1].pop('add_narrative');self.assertEqual(validate(g,S),'invalid')
 def test_no_secret_bypass(self):
  g=graph();g['nodes'][1].pop('add_discoveries');self.assertEqual(validate(g,S),'invalid')
 def test_no_key_respawn(self):
  g=graph();g['edges'][3]['require_resources']=['key'];self.assertEqual(validate(g,S),'invalid')
 def test_persistent_consequence(self):
  g=graph();g['nodes'][2]['add_narrative']=['resolved'];g['edges'][3]['require_narrative']=['resolved'];self.assertEqual(validate(g,S),'valid')
 def test_forbid_narrative_reset(self):
  g=graph();g['edges'][3]['remove_narrative']=['key'];self.assertEqual(validate(g,S),'invalid_schema')
 def test_dynamic_safe(self):
  g=graph();g['nodes'][2]['add_world']=['collapsed'];g['edges'][3]['block_world']=['collapsed'];g['edges'].append({'from':'c','to':'a','require_world':['collapsed']});self.assertEqual(validate(g,S),'valid')
 def test_dynamic_trap(self):
  g=graph();g['nodes'][2]['add_world']=['collapsed'];g['edges'][3]['block_world']=['collapsed'];self.assertEqual(validate(g,S),'invalid')
 def test_dynamic_reversible(self):
  g=graph();g['nodes'][2]['add_world']=['collapsed'];g['edges'][3]['block_world']=['collapsed'];g['edges'].append({'from':'c','to':'c','require_world':['collapsed'],'remove_world':['collapsed']});self.assertEqual(validate(g,S),'valid')
 def test_context_resolution(self):
  g=graph();g['nodes'][0]['refuge']={'block_context':['combat']};g['nodes'][1]['add_context']=['combat'];g['edges'][3]['remove_context']=['combat'];self.assertEqual(validate(g,S),'valid')
 def test_context_trap(self):
  g=graph();g['nodes'][0]['refuge']={'block_context':['combat']};g['nodes'][1]['add_context']=['combat'];self.assertEqual(validate(g,S),'invalid')
 def test_budget(self): self.assertEqual(validate(graph(),S,max_states=1),'indeterminate')
 def test_time(self): self.assertEqual(validate(graph(),S,max_seconds=0),'indeterminate')
