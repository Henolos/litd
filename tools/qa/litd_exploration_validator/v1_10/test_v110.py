import unittest
from copy import deepcopy
from expedition_validator import PersistentState
from canonical_candidate import project
from transaction_preview import Preview

class CandidateTests(unittest.TestCase):
    def setUp(self):
        self.p=Preview('A')
        self.c=project(PersistentState(campaign_id='A'),base_revision=0,transaction_id='t')
    def reject(self,c):
        with self.assertRaises(ValueError): self.p.apply(c)
        self.assertEqual(self.p.revision,0)
        self.assertEqual(self.p.receipts,())
    def test_missing_state(self):
        c=dict(self.c); del c['persistent_state']; self.reject(c)
    def test_negative_candidate(self):
        c=deepcopy(self.c); c['persistent_state']['resources']={'key':-1}; self.reject(c)
    def test_invalid_projection(self):
        for resources in [(('key',-1),),(('key',0),),(('key',True),),(('key',1.0),),(('key',1),('key',2))]:
            with self.subTest(resources=resources), self.assertRaises(ValueError):
                project(PersistentState(resources=resources,campaign_id='A'),base_revision=0,transaction_id='t')
    def test_missing_fields(self):
        for field in self.c['persistent_state']:
            c=deepcopy(self.c); del c['persistent_state'][field]; self.reject(c)
    def test_extra_fields(self):
        self.reject(dict(self.c,extra=1))
        c=deepcopy(self.c); c['persistent_state']['extra']=1; self.reject(c)
    def test_bad_types(self):
        for v in (True,1.0,0,-1,'1',None):
            c=deepcopy(self.c); c['persistent_state']['resources']={'key':v}; self.reject(c)
    def test_bad_sets(self):
        for v in (['x','x'],[''],[1],'x'):
            c=deepcopy(self.c); c['persistent_state']['world']=v; self.reject(c)
    def test_bad_closure(self):
        c=deepcopy(self.c); c['persistent_state']['closures']=['x\n']; self.reject(c)
    def test_bad_revision(self):
        for v in (True,0.0,-1): self.reject(dict(self.c,base_revision=v))
    def test_valid_nonempty(self):
        c=project(PersistentState(resources=(('key',2),),world=frozenset({'open'}),campaign_id='A',closures=frozenset({'e'})),base_revision=0,transaction_id='t')
        p,status=self.p.apply(c); self.assertEqual((p.revision,status),(1,'candidate'))
        self.assertEqual(p.apply(c),(p,'duplicate'))
