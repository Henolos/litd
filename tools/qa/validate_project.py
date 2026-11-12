#!/usr/bin/env python3
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[2]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

if (ROOT / 'docs/reconstruction/RESET_20261112_MANIFEST.json').exists():
    from tools.qa.reconstruction_audit import main
else:
    from tools.qa.audit import main

if __name__ == '__main__':
    raise SystemExit(main())
