"""Non-destructive checks for the six owner-approved LITD hero art sheets.

Run: python -m unittest discover -s tests/python -p 'test_validated_hero_art_library.py'
"""
import hashlib
import json
import re
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
MANIFEST = ROOT / "docs/art/validated_heroes_manifest_20261111.json"
EXPECTED_HEROES = {"mathilde", "marec", "anouk", "aurelien", "effrie", "lya"}
PLAYABLE_QUARTET = {"mathilde", "marec", "anouk", "aurelien"}


class ValidatedHeroArtLibraryTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.manifest = json.loads(MANIFEST.read_text(encoding="utf-8"))
        cls.assets = cls.manifest["assets"]

    def test_manifest_schema_and_approval(self):
        self.assertEqual(self.manifest["schema_version"], 1)
        self.assertEqual(self.manifest["art_approval"], "validated_by_user")
        self.assertEqual(len(self.assets), 6)
        self.assertEqual({a["hero"] for a in self.assets}, EXPECTED_HEROES)
        self.assertEqual(len({a["id"] for a in self.assets}), 6)
        self.assertEqual(len({a["target_path"] for a in self.assets}), 6)
        self.assertEqual({a["id"] for a in self.assets},
                         {f"LITD-HERO-{i:03d}" for i in range(1, 7)})

    def test_original_files_and_sha256(self):
        for asset in self.assets:
            with self.subTest(hero=asset["hero"]):
                path = asset["target_path"]
                self.assertEqual(path, f"art/library/heroes/{asset['hero']}/reference.jpg")
                self.assertEqual(asset["source_archive_member"], path)
                self.assertRegex(asset["sha256"], r"^[0-9a-f]{64}$")
                self.assertEqual(asset["art_status"], "validated")
                file_path = ROOT / path
                self.assertTrue(file_path.is_file(), f"Missing approved original: {path}")
                data = file_path.read_bytes()
                self.assertEqual(len(data), asset["size_bytes"])
                self.assertEqual(hashlib.sha256(data).hexdigest(), asset["sha256"])
                self.assertTrue(data.startswith(b"\\xff\\xd8\\xff"), f"Not JPEG: {path}")
                self.assertTrue(data.endswith(b"\\xff\\xd9"), f"Truncated JPEG: {path}")

    def test_no_unregistered_hero_originals(self):
        expected = {a["target_path"] for a in self.assets}
        actual = {p.relative_to(ROOT).as_posix()
                  for p in (ROOT / "art/library/heroes").glob("*/reference.jpg")}
        self.assertEqual(actual, expected)

    def test_quartet_runtime_mapping_remains_unchanged(self):
        # Guardrail only: this test does not change or activate gameplay characters.
        code = (ROOT / "scripts/ui/main_v52.gd").read_text(encoding="utf-8")
        match = re.search(r"const CANONICAL_HERO_IDS := \\[(.*?)\\]", code)
        self.assertIsNotNone(match)
        active = set(re.findall(r'"([^"]+)"', match.group(1)))
        self.assertEqual(active, PLAYABLE_QUARTET)
        self.assertFalse({"effrie", "lya"} & active)


if __name__ == "__main__":
    unittest.main()
