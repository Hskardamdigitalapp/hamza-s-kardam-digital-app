#!/usr/bin/env bash
set -euo pipefail
python3 - <<'PY'
from pathlib import Path
fixes = {
    'lib/screens/profile_screen.dart': [
        ('BorderRadius.circular(16)))),', 'BorderRadius.circular(16))))),'),
    ],
    'lib/screens/ussd_screen.dart': [
        ('])))\n    ])),', ']))))\n    ])),'),
    ],
}
for name, pairs in fixes.items():
    p = Path(name)
    s = p.read_text()
    for old, new in pairs:
        if old not in s:
            raise SystemExit(f'Expected syntax pattern not found in {name}: {old!r}')
        s = s.replace(old, new, 1)
    p.write_text(s)
PY
