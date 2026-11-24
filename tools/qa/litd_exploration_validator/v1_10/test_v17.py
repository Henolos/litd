import unittest
from dataclasses import replace
from expedition_validator import analyze, PersistentState
from test_v15 import g5,S

def closing():
 g=g5();g.update(abandonable_objectives=['c'],abandon_closes_expedition=True);g['nodes'].append({'id':'d','exit':True,'allow_abandon':True,'add_world':['scar']});g['edges'].append({'from':'a','to':'d','remove_resources':{'key':2}});return g
class ClosureTests(unittest.TestCase):
 def test_collision(self):
  g=g5();g['initial_narrative']=['closed:e'];self.assertEqual(analyze(g,S,campaign_id='A').status,'valid')
 def test_repeat(self):
  g=closing();p=next(iter(analyze(g,S,campaign_id='A').abandoned));self.assertEqual(p.closures,frozenset({'e'}));self.assertNotIn('closed:e',p.narrative);self.assertEqual(analyze(g,S,p,campaign_id='A').status,'closed')
 def test_isolation(self):
  g=closing();p=next(iter(analyze(g,S,campaign_id='A').abandoned));self.assertEqual(analyze(g,S,p,campaign_id='B').reason,'campaign_mismatch');self.assertEqual(analyze(g,S,campaign_id='B').status,'valid')
 def test_persistence(self):
  g=closing();p=next(iter(analyze(g,S,campaign_id='A').abandoned));g['expedition_id']='e2';g['edges']=[{'from':'a','to':'c','require_world':['scar']}];r=analyze(g,S,p,campaign_id='A');self.assertEqual(r.status,'valid');q=next(iter(r.exits));self.assertIn('scar',q.world);self.assertEqual(q.closures,p.closures);self.assertEqual(q.resources,());self.assertEqual(q.rewards,p.rewards)
 def test_invalid_registry(self):
  self.assertEqual(analyze(g5(),S,PersistentState(campaign_id='A',closures=frozenset({''})),campaign_id='A').status,'invalid_schema')
 def test_unbound(self):
  self.assertEqual(analyze(g5(),S,PersistentState(narrative=frozenset({'closed:e'})),campaign_id='A').reason,'unbound_prior')
 def test_projection(self):
  from canonical_candidate import project
  p=next(iter(analyze(closing(),S,campaign_id='A').abandoned));x=project(p,base_revision=2,transaction_id='t1');self.assertEqual(x['persistent_state']['closures'],['e']);self.assertEqual(x['base_revision'],2);self.assertEqual(x['campaign_id'],'A')
  with self.assertRaises(ValueError):project(p,base_revision=-1,transaction_id='t1')
