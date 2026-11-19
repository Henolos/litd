#!/usr/bin/env python3
"""Audit non destructif des planches originales LITD 1.

Usage: python tools/art/audit_bestiary_originals.py ARCHIVE.zip REPO_ROOT
N'importe aucun fichier : le rapport JSON identifie les doublons exacts,
les noms en conflit et les images absentes de l'arborescence locale.
"""
import argparse
import hashlib
import json
import pathlib
import zipfile

IMAGE_EXTENSIONS = {".jpg", ".jpeg", ".png", ".webp", ".tif", ".tiff"}

def sha256(data):
    return hashlib.sha256(data).hexdigest()

def audit(archive, root):
    with zipfile.ZipFile(archive) as z:
        manifest = json.loads(z.read("MANIFEST_SHA256.json"))
        originals = []
        for entry in manifest:
            raw = z.read(entry["archive"])
            actual = sha256(raw)
            if actual != entry["sha256"] or len(raw) != entry["octets"]:
                raise ValueError("Archive/manifest mismatch: " + entry["archive"])
            originals.append((entry, raw))
    repo = pathlib.Path(root)
    if not repo.is_dir():
        raise ValueError("Repository directory not found")
    indexed = {}
    for path in repo.rglob("*"):
        if not path.is_file() or ".git" in path.parts or path.suffix.lower() not in IMAGE_EXTENSIONS:
            continue
        digest = sha256(path.read_bytes())
        indexed.setdefault(digest, []).append(str(path.relative_to(repo)))
    rows = []
    for entry, raw in originals:
        matches = indexed.get(entry["sha256"], [])
        rows.append({"creature": entry["nom"], "sha256": entry["sha256"],
                     "source_archive": entry["archive"],
                     "status": "present_exact" if matches else "absent_exact",
                     "matches": matches})
    return {"archive": str(archive), "repository": str(repo),
            "images_checked": len(rows),
            "exact_matches": sum(x["status"] == "present_exact" for x in rows),
            "missing_exact": sum(x["status"] == "absent_exact" for x in rows),
            "results": rows,
            "warning": "An absent exact match may still have a visually similar or re-encoded version; manual review before importing."}

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("archive", type=pathlib.Path)
    parser.add_argument("repo_root", type=pathlib.Path)
    args = parser.parse_args()
    print(json.dumps(audit(args.archive, args.repo_root), indent=2, ensure_ascii=False))
