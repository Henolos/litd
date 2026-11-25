import unittest
from transaction_preview import Preview
from canonical_candidate import project
from expedition_validator import PersistentState

class TestPreview(unittest.TestCase):
    def setUp(self):
        self.p = Preview('A')
        self.c = project(PersistentState(campaign_id='A'), base_revision=0, transaction_id='t1')
    def test_advance(self):
        p, status = self.p.apply(self.c)
        self.assertEqual((p.revision,status,self.p.revision),(1,'candidate',0))
    def test_duplicate(self):
        p,_ = self.p.apply(self.c)
        self.assertEqual(p.apply(self.c),(p,'duplicate'))
    def test_conflict(self):
        p,_ = self.p.apply(self.c)
        with self.assertRaisesRegex(ValueError,'transaction conflict'):
            p.apply(dict(self.c,base_revision=1))
    def test_revision(self):
        p,_ = self.p.apply(self.c)
        with self.assertRaisesRegex(ValueError,'revision conflict'):
            p.apply(dict(self.c,transaction_id='t2'))
    def test_campaign(self):
        with self.assertRaisesRegex(ValueError,'campaign conflict'):
            self.p.apply(dict(self.c,campaign_id='B'))
    def test_next(self):
        p,_ = self.p.apply(self.c)
        q,_ = p.apply(dict(self.c,transaction_id='t2',base_revision=1))
        self.assertEqual(q.revision,2)
        self.assertEqual(q.apply(self.c),(q,'duplicate'))
