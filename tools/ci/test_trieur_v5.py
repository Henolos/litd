#!/usr/bin/env python3
"""Safety regression tests for Trieur governance, archive and sorter bridge."""
from __future__ import annotations

import json
import tempfile
import unittest
from pathlib import Path
from unittest import mock

from tools.ci import trieur_file_sorter_bridge as bridge
from tools.ci import trieur_governance_gate as gate
from tools.ci import trieur_safe_archive as archive


BASE_POLICY = {
    "allowed_statuses": ["canonical", "active", "superseded", "archived"],
    "runtime_forbidden_statuses": ["superseded", "archived"],
    "managed_roots": ["data", "scenes", "scripts", "docs"],
    "archive_root": "archive",
    "rules": {
        "superseded_requires_replacement": True,
        "replacement_must_exist": True,
        "replacement_cycles_forbidden": True,
        "archived_must_live_under_archive_root_when_moved": True,
        "duplicate_canonical_keys_forbidden": True,
        "runtime_must_not_reference_inactive_entries": False,
        "managed_paths_must_stay_in_managed_roots": True,
        "archive_requires_target": True,
        "archive_target_must_be_under_archive_root": True,
    },
    "entries": [],
}


class TempRepoTestCase(unittest.TestCase):
    def setUp(self) -> None:
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name)
        for name in ("data", "scenes", "scripts", "docs", "governance", "archive"):
            (self.root / name).mkdir(parents=True, exist_ok=True)
        (self.root / "data" / "a.json").write_text("{}", encoding="utf-8")
        (self.root / "data" / "b.json").write_text("{}", encoding="utf-8")

    def tearDown(self) -> None:
        self.tmp.cleanup()

    def policy(self, entries: list[dict]) -> dict:
        value = json.loads(json.dumps(BASE_POLICY))
        value["entries"] = entries
        return value


class GovernanceGateTests(TempRepoTestCase):
    def run_gate(self, policy: dict) -> None:
        with mock.patch.object(gate, "ROOT", self.root):
            gate.validate_entries(policy)

    def test_missing_replacement_is_rejected(self) -> None:
        policy = self.policy([
            {"id": "old", "path": "data/a.json", "status": "superseded", "replaced_by": "missing"}
        ])
        with self.assertRaises(SystemExit):
            self.run_gate(policy)

    def test_replacement_cycle_is_rejected(self) -> None:
        policy = self.policy([
            {"id": "a", "path": "data/a.json", "status": "superseded", "replaced_by": "b"},
            {"id": "b", "path": "data/b.json", "status": "superseded", "replaced_by": "a"},
        ])
        with self.assertRaises(SystemExit):
            self.run_gate(policy)

    def test_duplicate_canonical_key_is_rejected(self) -> None:
        policy = self.policy([
            {"id": "a", "path": "data/a.json", "status": "canonical", "canonical_key": "same"},
            {"id": "b", "path": "data/b.json", "status": "canonical", "canonical_key": "same"},
        ])
        with self.assertRaises(SystemExit):
            self.run_gate(policy)

    def test_path_escape_is_rejected(self) -> None:
        outside = self.root.parent / "outside.json"
        outside.write_text("{}", encoding="utf-8")
        try:
            policy = self.policy([
                {"id": "escape", "path": "../outside.json", "status": "active"}
            ])
            with self.assertRaises(SystemExit):
                self.run_gate(policy)
        finally:
            outside.unlink(missing_ok=True)

    def test_archive_target_escape_is_rejected(self) -> None:
        policy = self.policy([
            {
                "id": "old",
                "path": "data/a.json",
                "status": "archived",
                "archive_enabled": True,
                "archive_target": "data/not-archive.json",
            }
        ])
        with self.assertRaises(SystemExit):
            self.run_gate(policy)


class ArchiveSafetyTests(TempRepoTestCase):
    def test_symlink_source_is_rejected(self) -> None:
        target = self.root / "data" / "real.txt"
        target.write_text("x", encoding="utf-8")
        link = self.root / "data" / "link.txt"
        try:
            link.symlink_to(target)
        except (OSError, NotImplementedError):
            self.skipTest("symlinks unavailable on this platform")
        policy = self.policy([
            {
                "id": "link",
                "path": "data/link.txt",
                "status": "archived",
                "archive_enabled": True,
                "archive_target": "archive/link.txt",
            }
        ])
        with mock.patch.object(archive, "ROOT", self.root):
            with self.assertRaises(SystemExit):
                archive.archive_candidates(policy)

    def test_registry_save_failure_rolls_filesystem_back(self) -> None:
        source = self.root / "data" / "move.txt"
        source.write_text("payload", encoding="utf-8")
        target = self.root / "archive" / "move.txt"
        policy = self.policy([
            {
                "id": "move",
                "path": "data/move.txt",
                "status": "archived",
                "archive_enabled": True,
                "archive_target": "archive/move.txt",
            }
        ])
        original = dict(policy["entries"][0])
        with mock.patch.object(archive, "ROOT", self.root), mock.patch.object(
            archive, "save_policy", side_effect=OSError("simulated registry failure")
        ):
            with self.assertRaises(SystemExit):
                archive.apply_move(policy, 0, "move", source, target)
        self.assertTrue(source.exists())
        self.assertFalse(target.exists())
        self.assertEqual(policy["entries"][0], original)

    def test_hash_mismatch_keeps_source(self) -> None:
        source = self.root / "data" / "hash.txt"
        source.write_text("payload", encoding="utf-8")
        target = self.root / "archive" / "hash.txt"
        policy = self.policy([{"id": "hash", "path": "data/hash.txt", "status": "archived"}])
        with mock.patch.object(archive, "ROOT", self.root), mock.patch.object(
            archive, "tree_hash", side_effect=["before", "after"]
        ):
            with self.assertRaises(SystemExit):
                archive.apply_move(policy, 0, "hash", source, target)
        self.assertTrue(source.exists())
        self.assertFalse(target.exists())


class BridgeTests(TempRepoTestCase):
    def prepare_bridge_files(self, trieur: dict, sorter: dict) -> None:
        trieur_path = self.root / "governance" / "trieur_policy.json"
        manifest_path = self.root / "data" / "maintenance" / "canonical_files.json"
        manifest_path.parent.mkdir(parents=True, exist_ok=True)
        trieur_path.write_text(json.dumps(trieur), encoding="utf-8")
        manifest_path.write_text(json.dumps(sorter), encoding="utf-8")

    @property
    def required_infra(self) -> list[str]:
        return [
            "governance/trieur_policy.json",
            "data/maintenance/canonical_files.json",
            "tools/ci/trieur_governance_gate.py",
            "tools/ci/trieur_safe_archive.py",
            "tools/ci/trieur_file_sorter_bridge.py",
        ]

    def test_canonical_cannot_also_be_obsolete(self) -> None:
        trieur = {"entries": [{"id": "canon", "path": "data/a.json", "status": "canonical"}]}
        sorter = {
            "canonical_paths": self.required_infra + ["data/a.json"],
            "obsolete_records": [{"path": "data/a.json"}],
        }
        self.prepare_bridge_files(trieur, sorter)
        with mock.patch.object(bridge, "ROOT", self.root), mock.patch.object(
            bridge, "TRIEUR", self.root / "governance" / "trieur_policy.json"
        ), mock.patch.object(
            bridge, "MANIFEST", self.root / "data" / "maintenance" / "canonical_files.json"
        ):
            with self.assertRaises(SystemExit):
                bridge.main()

    def test_inactive_cannot_remain_canonical_in_sorter(self) -> None:
        trieur = {"entries": [{"id": "old", "path": "data/a.json", "status": "archived"}]}
        sorter = {"canonical_paths": self.required_infra + ["data/a.json"], "obsolete_records": []}
        self.prepare_bridge_files(trieur, sorter)
        with mock.patch.object(bridge, "ROOT", self.root), mock.patch.object(
            bridge, "TRIEUR", self.root / "governance" / "trieur_policy.json"
        ), mock.patch.object(
            bridge, "MANIFEST", self.root / "data" / "maintenance" / "canonical_files.json"
        ):
            with self.assertRaises(SystemExit):
                bridge.main()


if __name__ == "__main__":
    unittest.main()
