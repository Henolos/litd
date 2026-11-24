import unittest
from validator import validate
SCHEMA={'type':'object','required':['entry_id','nodes','edges','objectives'],'properties':{'entry_id':{'type':'string'},'nodes':{'type':'array','items':{'type':'object','required':['id']}},'edges':{'type':'array'},'objectives':{'type':'array'}}}
def graph():
    return {'entry_id':'a','nodes':[{'id':'a','exit':True},{'id':'b','grants':['key']},{'id':'c'}],'edges':[{'from':'a','to':'b'},{'from':'b','to':'a'},{'from':'b','to':'c','requires':['key']},{'from':'c','to':'a'}],'objectives':['c']}
class Tests(unittest.TestCase):
    def test_valid(self): self.assertEqual(validate(graph(),SCHEMA),'valid')
    def test_trap(self):
        g=graph();g['nodes'].append({'id':'trap'});g['edges'].append({'from':'b','to':'trap'});self.assertEqual(validate(g,SCHEMA),'invalid')
    def test_budget(self): self.assertEqual(validate(graph(),SCHEMA,max_states=1),'indeterminate')
    def test_time(self): self.assertEqual(validate(graph(),SCHEMA,max_seconds=0),'indeterminate')
    def test_schema(self):
        g=graph();del g['nodes'];self.assertEqual(validate(g,SCHEMA),'invalid_schema')
    def test_reference(self):
        g=graph();g['edges'].append({'from':'a','to':'missing'});self.assertEqual(validate(g,SCHEMA),'invalid')
    def test_consumption(self):
        g=graph();g['edges'][2]['consumes']=['key'];g['edges'][3]['requires']=['key'];self.assertEqual(validate(g,SCHEMA),'invalid')
if __name__=='__main__': unittest.main()
