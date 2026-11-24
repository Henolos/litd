import unittest,json,copy
from pathlib import Path
from validator import validate
S=json.loads(Path('graph_v1_1.schema.json').read_text())
V0=json.loads(Path('graph_v0.schema.reconstructed.json').read_text())
CASES=json.loads(Path('graph_v0.fixtures.reconstructed.json').read_text())
class Extension(unittest.TestCase):
 def test_historical(self):
  for c in CASES:
   with self.subTest(case=c['id']):self.assertEqual(validate(c['graph'],V0),'valid' if c['expected'] else 'invalid')
 def graph(self):return copy.deepcopy(CASES[0]['graph'])
 def test_secret_discovered(self):
  g=self.graph();g['edges'][2]['secret_requires']=['key'];self.assertEqual(validate(g,S),'valid')
 def test_secret_undiscovered(self):
  g=self.graph();g['edges'][2]['secret_requires']=['discovery'];self.assertEqual(validate(g,S),'invalid')
 def test_narrative_gate(self):
  g=self.graph();g['edges'][2].update(secret_requires=['key'],narrative_requires=['permission']);self.assertEqual(validate(g,S),'invalid')
 def test_refuge_allowed(self):self.assertEqual(validate(self.graph(),S),'valid')
 def test_refuge_blocked(self):
  g=self.graph();g['nodes'][0]['refuge_blocks']=['key'];self.assertEqual(validate(g,S),'invalid')
 def test_refuge_resolution(self):
  g=self.graph();g['nodes'][0]['refuge_blocks']=['key'];g['edges'][2]['consumes']=['key'];self.assertEqual(validate(g,S),'valid')
 def test_schema_wrong_type(self):
  g=self.graph();g['edges'][2]['secret_requires']='key';self.assertEqual(validate(g,S),'invalid_schema')
