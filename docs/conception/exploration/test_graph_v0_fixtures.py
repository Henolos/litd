"""Synthetic reference oracle; not production validation."""
import json
import unittest
from pathlib import Path
from collections import deque

def accepts(g):
    nodes = {n["id"]: n for n in g["nodes"]}
    if len(nodes) != len(g["nodes"]) or g["entry_id"] not in nodes:
        return False
    if not set(g["objectives"]) <= nodes.keys():
        return False
    if any(e["from"] not in nodes or e["to"] not in nodes for e in g["edges"]):
        return False
    def arrive(p, keys, seen):
        if p not in seen:
            keys = keys | frozenset(nodes[p].get("grants", []))
        return p, keys, seen | {p}
    q = deque([arrive(g["entry_id"], frozenset(), frozenset())])
    visited = set()
    while q:
        state = q.popleft()
        if state in visited:
            continue
        visited.add(state)
        if len(visited) > 10000:
            return False
        p, keys, seen = state
        if nodes[p].get("exit") and set(g["objectives"]) <= seen:
            return True
        for e in g["edges"]:
            consume = frozenset(e.get("consumes", []))
            if e["from"] == p and (consume | frozenset(e.get("requires", []))) <= keys:
                q.append(arrive(e["to"], keys - consume, seen))
    return False

class FixtureTests(unittest.TestCase):
    def test_cases(self):
        cases = json.loads(Path(__file__).with_name("graph_v0.fixtures.json").read_text())
        for case in cases:
            with self.subTest(case=case["id"]):
                self.assertEqual(accepts(case["graph"]), case["expected"])

if __name__ == "__main__":
    unittest.main()
