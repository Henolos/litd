import json
from pathlib import Path

from tools.blender.generate_dismemberment_jobs import build_jobs

ROOT = Path(__file__).resolve().parents[2]


def test_dismemberment_blender_jobs_cover_profiles_and_unique_bosses():
    jobs = build_jobs(ROOT)
    generic = [job for job in jobs if job["type"] == "generic_profile"]
    bosses = [job for job in jobs if job["type"] == "unique_boss"]
    # Check the generated roster against its source contract, not a stale count.
    contract = json.loads((ROOT / "data/blender/dismemberment_contract.json").read_text(encoding="utf-8"))
    expected_profiles = set(contract["generic_profiles"])
    assert {job["profile_id"] for job in generic} == expected_profiles
    assert len(bosses) == 11
    assert len(jobs) == len(expected_profiles) + len(bosses)


def test_each_blender_anatomy_part_has_bone_and_vfx_socket():
    for job in build_jobs(ROOT):
        for part in job["parts"]:
            assert part["bone"].startswith("BONE_")
            assert part["vfx_socket"].startswith("FX_")
            if part.get("severable", True):
                assert part["sever_socket"].startswith("SEVER_")
                assert part["detached_mesh"].startswith("DETACHED_")
                assert part["wound_cap"].startswith("CAP_")


def test_blender_contract_keeps_three_presentation_modes():
    for job in build_jobs(ROOT):
        assert set(job["presentation_modes"]) == {"full", "reduced", "off"}
