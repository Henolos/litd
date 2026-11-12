import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]


def test_main_campaign_has_ten_ordered_chapters_with_quests_and_bosses():
    data = json.loads((ROOT / "data/world/main_campaign.json").read_text())
    chapters = data["chapters"]
    assert len(chapters) == 10
    assert [chapter["number"] for chapter in chapters] == list(range(1, 11))
    assert chapters[2]["id"] == "chapter_03_threshold"
    assert chapters[2]["unlock"] == "chapter_04_first_rupture"
    assert chapters[3]["id"] == "chapter_04_first_rupture"
    assert chapters[3]["unlock"] == "chapter_05_great_closure"
    assert chapters[4]["id"] == "chapter_05_great_closure"
    assert chapters[4]["unlock"] == "chapter_06_absent"
    assert chapters[5]["id"] == "chapter_06_absent"
    assert chapters[5]["unlock"] == "chapter_07_living_responsible"
    assert chapters[6]["id"] == "chapter_07_living_responsible"
    assert chapters[6]["unlock"] == "chapter_08_outer_world"
    assert chapters[7]["id"] == "chapter_08_outer_world"
    assert chapters[7]["unlock"] == "chapter_09_veil_nature"
    assert {b['id'] for b in chapters[7]['bosses']} == {'c08_boss_varkhane','c08_boss_azravel'}
    assert chapters[8]["id"] == "chapter_09_veil_nature"
    assert chapters[8]["unlock"] == "chapter_10_final_choice"
    assert chapters[8]["bosses"][0]["id"] == "c09_boss_consensus"
    assert chapters[9]["id"] == "chapter_10_final_choice"
    assert chapters[9]["unlock"] == "endings"
    assert chapters[9]["bosses"][0]["id"] == "c10_boss_final"




def test_final_chapter_keeps_non_binary_resolution():
    data = json.loads((ROOT / "data/world/main_campaign.json").read_text())
    boss = data["chapters"][-1]["bosses"][0]
    assert boss["name"] == "La Rupture Commune"
    assert "crise" in boss["truth"].lower()
