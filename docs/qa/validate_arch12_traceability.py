#!/usr/bin/env python3
"""Deterministic structural checks for the ARCH-12 traceability matrix.

This verifies inventory, locators, and reference integrity. It does not decide
whether a derived relationship is semantically correct or historically approved.
"""
from __future__ import annotations

import re
import sys
from collections import Counter
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
TRACE = ROOT / "docs/qa/ARCH12_TRACEABILITY_AND_SCENARIOS_2026-11-26.md"
MASTER = ROOT / "docs/conception/LITD1_DOCUMENT_MAITRE.md"
EXPECTED = {
    "ARCH-12": 20,
    "ARCH-12.1": 10,
    "ARCH-12.2": 10,
    "ARCH-12.3": 10,
    "ARCH-12.4": 10,
    "ARCH-12.5": 20,
}
TAG_RE = re.compile(r"\[(E-règle|E-groupe|E-réconciliation|D)\]")
CHAPTER_RE = re.compile(r"\bARCH-\d{2}(?:\.\d+)?\b")
ARCH_CITATION_RE = re.compile(r"\b(ARCH-\d{2}(?:\.\d+)?)\b")
NUMBER_RE = re.compile(r"R(\d+)(?:\s*[–-]\s*R?(\d+))?")
V8_CITATION_RE = re.compile(r"V8\.3[^;\]]*?R(\d+)((?:\s*/\s*R?\d+(?:\s*[–-]\s*R?\d+)?|\s*[–-]\s*R?\d+)*)")


def fail(errors: list[str], message: str) -> None:
    errors.append(message)


def get_sections(text: str) -> dict[str, str]:
    headings = list(re.finditer(r"^##\s+(ARCH-\d{2}(?:\.\d+)?)\b[^\n]*", text, re.M))
    result: dict[str, str] = {}
    for i, match in enumerate(headings):
        end = headings[i + 1].start() if i + 1 < len(headings) else len(text)
        result.setdefault(match.group(1), "")
        result[match.group(1)] += text[match.start():end]
    return result


def defined_rule_numbers(section: str) -> set[int]:
    numbers = {int(n) for n in re.findall(r"^\s*\*\*Règle\s+(\d+)", section, re.M)}
    numbers.update(int(n) for n in re.findall(r"^\s*(\d+)\.\s+", section, re.M))
    numbers.update(int(n) for n in re.findall(r"^\s*\|\s*(\d+)\s*\|", section, re.M))
    return numbers


def ranges_in(text: str) -> list[int]:
    values: list[int] = []
    for match in re.finditer(r"R(\d+)((?:\s*/\s*R?\d+(?:\s*[–-]\s*R?\d+)?|\s*[–-]\s*R?\d+)*)", text):
        values.append(int(match.group(1)))
        suffix = match.group(2)
        for item in re.finditer(r"(?:/\s*)?R?(\d+)(?:\s*[–-]\s*R?(\d+))?", suffix):
            lo = int(item.group(1))
            hi = int(item.group(2) or lo)
            values.extend(range(min(lo, hi), max(lo, hi) + 1))
    return values


def cited_rules(relation: str):
    for match in ARCH_CITATION_RE.finditer(relation):
        chapter = match.group(0)
        tail = relation[match.end():].split(";", 1)[0].split("]", 1)[0]
        next_chapter = ARCH_CITATION_RE.search(tail)
        if next_chapter:
            tail = tail[:next_chapter.start()]
        values = ranges_in(tail)
        if values:
            yield chapter, values
    for match in V8_CITATION_RE.finditer(relation):
        tail = "R" + match.group(1) + match.group(2)
        yield "V8.3", ranges_in(tail)


def validate() -> list[str]:
    errors: list[str] = []
    trace = TRACE.read_text(encoding="utf-8")
    master = MASTER.read_text(encoding="utf-8")
    sections = get_sections(master)

    heading = "## Matrice individuelle des 80 règles"
    start = trace.find(heading)
    end = trace.find("\n## ", start + len(heading)) if start >= 0 else -1
    if start < 0:
        return ["Matrice individuelle introuvable."]
    matrix = trace[start:end if end >= 0 else len(trace)]
    rows = []
    for line in matrix.splitlines():
        if re.match(r"^\|\s*ARCH-12(?:\.\d+)?\s+\d+\s*\|", line):
            cells = [cell.strip() for cell in line.strip().strip("|").split("|")]
            if len(cells) != 9:
                fail(errors, f"Ligne mal formée ({len(cells)} cellules): {cells[0] if cells else line[:80]}")
                continue
            rows.append(cells)

    counts: Counter[str] = Counter()
    actual_ids = set()
    for cells in rows:
        rule = cells[0]
        match = re.fullmatch(r"(ARCH-12(?:\.\d+)?)\s+(\d+)", rule)
        if not match:
            fail(errors, f"Identifiant invalide: {rule}")
            continue
        chapter, number = match.group(1), int(match.group(2))
        counts[chapter] += 1
        actual_ids.add((chapter, number))
        if any(not cell.strip() for cell in cells):
            fail(errors, f"Champ vide dans {rule}")
        relation = cells[6]
        tags = TAG_RE.findall(relation)
        if not tags:
            fail(errors, f"Aucune qualification E/D dans {rule}")
        for tag_match in TAG_RE.finditer(relation):
            tag = tag_match.group(1)
            segment = relation[tag_match.end():].split(";", 1)[0].split("]", 1)[0]
            has_arch_rule = bool(re.search(r"ARCH-\d{2}(?:\.\d+)?[^;]*?R\d+", segment))
            has_v8_rule = bool(re.search(r"V8\.3[^;]*?R\d+", segment))
            has_chapter = bool(CHAPTER_RE.search(segment))
            if tag == "D" and not has_arch_rule:
                fail(errors, f"Lien [D] sans règle source explicite dans {rule}: {segment.strip()}")
            if tag == "E-règle" and not (has_arch_rule or has_v8_rule):
                fail(errors, f"Lien [E-règle] sans locator de règle dans {rule}: {segment.strip()}")
            if tag in {"E-groupe", "E-réconciliation"} and not (has_arch_rule or has_v8_rule or "§" in segment):
                fail(errors, f"Lien [{tag}] sans locator de groupe/section dans {rule}: {segment.strip()}")

        for chapter_ref in CHAPTER_RE.findall(relation):
            if chapter_ref not in sections:
                fail(errors, f"Chapitre référencé absent ({chapter_ref}) dans {rule}")
        for chapter_ref, numbers in cited_rules(relation):
            if chapter_ref == "V8.3":
                invalid = [n for n in numbers if n < 1 or n > 9]
            else:
                available = defined_rule_numbers(sections.get(chapter_ref, ""))
                invalid = [n for n in numbers if n not in available]
                if not available:
                    fail(errors, f"Règles sources illisibles pour {chapter_ref}, cité dans {rule}")
            if invalid:
                fail(errors, f"Règles sources hors plage ({chapter_ref} R{invalid}) dans {rule}")

        for locator in re.findall(r"§\s*([^,;]+)", relation):
            title = locator.strip().strip("«»")
            if not re.search(r"^###\s+" + re.escape(title) + r"\s*$", master, re.M | re.I):
                fail(errors, f"Locator de section introuvable ({title}) dans {rule}")

        for match in re.finditer(r"V8\.3", relation):
            window = relation[match.start():].split(";", 1)[0]
            if not re.search(r"R\d+", window):
                fail(errors, f"Renvoi V8.3 sans règle précise dans {rule}")

    for chapter, count in EXPECTED.items():
        if counts[chapter] != count:
            fail(errors, f"{chapter}: attendu {count} lignes, trouvé {counts[chapter]}")
        expected_ids = {(chapter, n) for n in range(1, count + 1)}
        missing = sorted(expected_ids - actual_ids)
        if missing:
            fail(errors, f"{chapter}: identifiants manquants {missing}")
    expected_total = sum(EXPECTED.values())
    if len(rows) != expected_total:
        fail(errors, f"Total attendu {expected_total}, trouvé {len(rows)}")

    scenarios = re.findall(r"^\|\s*(S\d{2})\s*\|", trace, re.M)
    if len(scenarios) != 70 or len(set(scenarios)) != 70:
        fail(errors, f"Scénarios candidats: attendu 70 identifiants distincts, trouvé {len(scenarios)} lignes/{len(set(scenarios))} uniques")

    if not errors:
        print("ARCH-12 matrix structural check: PASS")
        print("Rules: 80 (20/10/10/10/10/20); scenario IDs: 70 unique")
        print("Relationship cells and source locators: populated and syntactically resolvable")
        print("Scope limit: no semantic approval, source authenticity, implementation, or gameplay claim")
    return errors


if __name__ == "__main__":
    problems = validate()
    if problems:
        for problem in problems:
            print(f"ERROR: {problem}", file=sys.stderr)
        raise SystemExit(1)
