import unittest
from secure_validator import analyze
from expedition_validator import PersistentState
from canonical_candidate import project
from test_v17 import closing
from test_v15 import g5,S
class SecureTests(unittest.TestCase):
 def test_required_campaign(self):
  with self.assertRaises(TypeError): analyze(g5(),S)
 def test_bad_ids(self):
  for value in ('', ' A', 'A\n', 'é', 'a'*129, None):
   self.assertEqual(analyze(g5(),S,campaign_id=value).status,'invalid_schema')
 def test_unbound_prior(self):
  self.assertEqual(analyze(g5(),S,PersistentState(),campaign_id='A').status,'invalid_schema')
 def test_closure(self):
  g=closing();g['initial_narrative']=['closed:e'];r=analyze(g,S,campaign_id='A');self.assertEqual(r.status,'valid');p=next(iter(r.abandoned));self.assertEqual(analyze(g,S,p,campaign_id='A').status,'closed')
 def test_transaction(self):
  for value in ('', ' t', 't\n', 'é', 'a'*129, None):
   with self.assertRaises(ValueError): project(PersistentState(campaign_id='A'),base_revision=0,transaction_id=value)
 def test_expedition(self):
  g=g5();g['expedition_id']=' e';self.assertEqual(analyze(g,S,campaign_id='A').status,'invalid_schema')
