#!/usr/bin/env python3
"""Validate the reset boundary and original reference bytes, without executing retired gameplay."""
from __future__ import annotations
import argparse
import hashlib
import json
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[2]
MANIFEST = 'docs/reconstruction/RESET_20261112_MANIFEST.json'
AUTHORIZED_REVISIONS = 'docs/reconstruction/AUTHORIZED_REFERENCE_REVISIONS_20261123.json'
HEX_SHA256 = re.compile(r'^[0-9a-f]{64}$')


def _authorized_reference_hashes(root: Path, references: list[dict]) -> tuple[dict[str, str], list[str]]:
    """Load exact, evidence-backed replacements without changing reset hashes."""
    path = root / AUTHORIZED_REVISIONS
    if not path.is_file():
        return {}, []
    errors: list[str] = []
    try:
        ledger = json.loads(path.read_text(encoding='utf-8'))
    except (OSError, json.JSONDecodeError):
        return {}, ['invalid_authorized_reference_ledger']
    if not isinstance(ledger, dict) or ledger.get('schema_version') != 1:
        return {}, ['invalid_authorized_reference_ledger']
    entries = ledger.get('revisions')
    if not isinstance(entries, list):
        return {}, ['invalid_authorized_reference_ledger']

    frozen = {item['path']: item['sha256'] for item in references}
    if len(frozen) != len(references):
        errors.append('duplicate_preservation_manifest_path')
    authorized: dict[str, str] = {}
    seen_paths: set[str] = set()
    for index, entry in enumerate(entries):
        label = f'authorized_revision_{index}'
        if not isinstance(entry, dict):
            errors.append(f'{label}_invalid')
            continue
        ref = entry.get('path')
        old_hash = entry.get('original_sha256')
        new_hash = entry.get('authorized_sha256')
        evidence = entry.get('evidence_ref')
        reason = entry.get('reason')
        if not isinstance(ref, str) or ref not in frozen:
            errors.append(f'{label}_unknown_path')
            continue
        if ref in seen_paths:
            errors.append(f'{label}_duplicate_path')
            continue
        seen_paths.add(ref)
        if old_hash != frozen[ref] or not isinstance(new_hash, str) or not HEX_SHA256.fullmatch(new_hash) or new_hash == old_hash:
            errors.append(f'{label}_hash_mismatch')
            continue
        evidence_path = Path(evidence) if isinstance(evidence, str) else Path('/')
        evidence_file = root / evidence_path
        if (
            not isinstance(evidence, str)
            or not evidence.strip()
            or evidence_path.is_absolute()
            or '..' in evidence_path.parts
            or not evidence_file.resolve().is_relative_to(root.resolve())
            or not evidence_file.is_file()
        ):
            errors.append(f'{label}_evidence_missing')
            continue
        if not isinstance(reason, str) or len(reason.strip()) < 40:
            errors.append(f'{label}_reason_missing')
            continue
        authorized[ref] = new_hash
    return authorized, errors


def validate(root: Path = ROOT, group: str = 'all') -> list[str]:
    manifest = json.loads((root / MANIFEST).read_text())
    errors = []
    references = manifest['preserved_reference_files']
    if not references:
        errors.append('empty_preservation_manifest')
    authorized_hashes, ledger_errors = _authorized_reference_hashes(root, references)
    errors.extend(ledger_errors)
    for item in references:
        path = root / item['path']
        actual_hash = hashlib.sha256(path.read_bytes()).hexdigest() if path.is_file() else None
        if actual_hash not in {item['sha256'], authorized_hashes.get(item['path'])}:
            errors.append('reference_changed:' + item['path'])
    if group == 'lore':
        if not any('remanence' in item['path'].lower() for item in references):
            errors.append('remanence_reference_missing')
        return errors
    for name in manifest['removed_runtime_files']:
        if (root / name).exists():
            errors.append('retired_runtime_returned:' + name)
    allowed = set(manifest['technical_scripts'])
    production = {p.relative_to(root).as_posix() for p in (root / 'scripts').rglob('*.gd') if '/tests/' not in p.as_posix()}
    if production != allowed:
        errors.append('technical_script_scope:' + repr(sorted(production ^ allowed)))
    project = (root / 'project.godot').read_text()
    main_scene = re.search(r'^run/main_scene="([^"]+)"$', project, re.MULTILINE)
    approved_main_scene = 'res://scenes/hub/game_hub.tscn'
    if main_scene and main_scene.group(1) != approved_main_scene:
        errors.append('retired_game_bootstrap_returned')
    if main_scene and not (root / main_scene.group(1)[6:]).is_file():
        errors.append('missing_game_bootstrap_scene')
    if 'GameState=' in project or 'VeilleursRuntime=' in project:
        errors.append('retired_game_bootstrap_returned')
    for section in ['SaveManager=', 'GameSettings=']:
        if section not in project:
            errors.append('technical_autoload_missing:' + section)
    sources = [root / 'project.godot', *(root / 'scripts').rglob('*.gd'), *(root / 'scenes').rglob('*.tscn'), *(root / 'tests/godot').glob('*.gd')]
    for path in sources:
        for target in re.findall(r'res://[A-Za-z0-9_./-]+', path.read_text()):
            if not target.startswith('res://reports/') and not (root / target[6:]).exists():
                errors.append(f'broken_resource:{path.relative_to(root)}:{target}')
    return errors


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument('--group', choices=['all', 'lore'], default='all')
    args = parser.parse_args()
    errors = validate(group=args.group)
    for error in errors:
        print('FAIL', error)
    print(f'RECONSTRUCTION_{args.group.upper()}_AUDIT_' + ('FAIL' if errors else 'OK'))
    return bool(errors)


if __name__ == '__main__':
    raise SystemExit(main())
