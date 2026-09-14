#!/usr/bin/env python3
"""Regression tests for Trieur V6 canonical coverage alignment."""
from __future__ import annotations

import json
import tempfile
import unittest
from pathlib import Path
from unittest import mock

from tools.ci import trieur_file_sorter_bridge as bridge


class TrieurV6BridgeTests(unittest.TestCase):
    def setUp(self) -> None:
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name)
        (self.root / "governance").mkdir(parents=True)
        (self.root / "data" / "maintenance").mkdir(parents=True)
        (self.root / "docs").mkdir(parents=True)
        self.trieur_path = self.root / "governance" / "trieur_policy.json"
        self.manifest_path = self.root / "data" / "maintenance" / "canonical_files.json"

    def tearDown(self) -> None:
        self.tmp.cleanup()

    @property
    def infra(self) -> list[str]:
        return [
            "governance/trieur_policy.json",
            "data/maintenance/canonical_files.json",
            "tools/ci/trieur_governance_gate.py",
            "tools/ci/trieur_safe_archive.py",
            "tools/ci/trieur_file_sorter_bridge.py",
        ]

    def run_bridge(self, trieur: dict, sorter: dict) -> None:
        self.trieur_path.write_text(json.dumps(trieur), encoding="utf-8")
        self.manifest_path.write_text(json.dumps(sorter), encoding="utf-8")
        with mock.patch.object(bridge, "ROOT", self.root), mock.patch.object(
            bridge, "TRIEUR", self.trieur_path
        ), mock.patch.object(bridge, "MANIFEST", self.manifest_path):
            bridge.main()

    def test_managed_sorter_canonical_requires_trieur_entry(self) -> None:
        trieur = {"managed_roots": ["data", "docs"], "entries": []}
        sorter = {"canonical_paths": self.infra + ["docs/canon.md"], "obsolete_records": []}
        with self.assertRaises(SystemExit):
            self.run_bridge(trieur, sorter)

    def test_external_infra_canonical_does_not_require_lifecycle_entry(self) -> None:
        trieur = {"managed_roots": ["data", "docs"], "entries": []}
        sorter = {"canonical_paths": self.infra, "obsolete_records": []}
        self.run_bridge(trieur, sorter)

    def test_bidirectional_alignment_accepts_registered_managed_canonical(self) -> None:
        trieur = {
            "managed_roots": ["data", "docs"],
            "entries": [
                {"id": "doc", "path": "docs/canon.md", "status": "canonical"}
            ],
        }
        sorter = {"canonical_paths": self.infra + ["docs/canon.md"], "obsolete_records": []}
        self.run_bridge(trieur, sorter)


if __name__ == "__main__":
    unittest.main()
