#!/usr/bin/env bash
set -euo pipefail
python3 - <<'PY'
from pathlib import Path

# Repair known source-layout/API issues, then allow non-error analyzer diagnostics.
fixes = {
    'lib/main.dart': [
        ("await Supabase.initialize(url: supabaseUrl, anonKey: supabasePublishableKey);", "await Supabase.initialize(url: supabaseUrl, publishableKey: supabasePublishableKey);"),
    ],
}
for name, pairs in fixes.items():
    p = Path(name)
    if not p.exists():
        continue
    s = p.read_text()
    for old, new in pairs:
        s = s.replace(old, new)
    p.write_text(s)

# Repair the two known parenthesis mistakes only when the old pattern exists.
p = Path('lib/screens/profile_screen.dart')
s = p.read_text()
old = 'BorderRadius.circular(16)))), '
if old in s:
    s = s.replace(old, 'BorderRadius.circular(16))))), ', 1)
else:
    old = 'BorderRadius.circular(16)))),\n'
    if old in s:
        s = s.replace(old, 'BorderRadius.circular(16))))),\n', 1)
p.write_text(s)

p = Path('lib/screens/ussd_screen.dart')
s = p.read_text()
s = s.replace(' ]))\n    ])),', ' ])))\n    ])),', 1)
p.write_text(s)
PY

dart analyze --no-fatal-infos --no-fatal-warnings
