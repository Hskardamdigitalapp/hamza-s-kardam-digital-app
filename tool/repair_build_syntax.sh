#!/usr/bin/env bash
set -euo pipefail
python3 - <<'PY'
from pathlib import Path

p = Path('lib/screens/profile_screen.dart')
s = p.read_text()
old = 'BorderRadius.circular(16)))), '
if old in s:
    s = s.replace(old, 'BorderRadius.circular(16))))), ', 1)
else:
    old = 'BorderRadius.circular(16)))),\n'
    if old not in s:
        raise SystemExit('Profile syntax pattern not found')
    s = s.replace(old, 'BorderRadius.circular(16))))),\n', 1)
p.write_text(s)

p = Path('lib/screens/ussd_screen.dart')
lines = p.read_text().splitlines(True)
changed = False
for i, line in enumerate(lines):
    if line.lstrip().startswith('...codes.map((item)'):
        if ' ]))' not in line:
            raise SystemExit('USSD syntax pattern not found')
        lines[i] = line.replace(' ]))', ' ])))', 1)
        changed = True
        break
if not changed:
    raise SystemExit('USSD map line not found')
p.write_text(''.join(lines))
PY
