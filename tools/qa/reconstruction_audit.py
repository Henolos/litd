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


def validate(root: Path = ROOT, group: str = 'all') -> list[str]:
    manifest = json.loads((root / MANIFEST).read_text())
    errors = []
    references = manifest['preserved_reference_files']
    if not references:
        errors.append('empty_preservation_manifest')
    for item in references:
        path = root / item['path']
        if not path.is_file() or hashlib.sha256(path.read_bytes()).hexdigest() != item['sha256']:
            errors.append('reference_changed:' + item['path'])
    if group == 'lore':
        if not any('remanence' in item['path'].lower() for item in references):
            errors.append('remanence_reference_missing')
        return errors
    for name in manifest['removed_runtime_files']:
        if (root / name).exists():
            errors.append('retired_runtime_returned:' + name)
    # The immutable reset manifest describes the retained base. Explicitly reviewed
    # prototypes can extend it without granting old gameplay a path back in.
    prototype_manifest = root / 'docs/reconstruction/COMBAT_A_PROTOTYPE_MANIFEST.json'
    prototypes = json.loads(prototype_manifest.read_text()) if prototype_manifest.exists() else {'scripts': [], 'scenes': []}
    allowed = set(manifest['technical_scripts']) | set(prototypes['scripts'])
    production = {p.relative_to(root).as_posix() for p in (root / 'scripts').rglob('*.gd') if '/tests/' not in p.as_posix()}
    if production != allowed:
        errors.append('technical_script_scope:' + repr(sorted(production ^ allowed)))
    for name in prototypes['scripts'] + prototypes['scenes']:
        if name in manifest['removed_runtime_files'] or not (root / name).is_file():
            errors.append('prototype_scope_invalid:' + name)
    project = (root / 'project.godot').read_text()
    if 'run/main_scene=' in project or 'GameState=' in project or 'VeilleursRuntime=' in project:
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
