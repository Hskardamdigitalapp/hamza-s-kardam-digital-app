#!/usr/bin/env bash
set -euo pipefail
python3 - <<'PY'
from pathlib import Path

# Repair only known source/API issues before the release build.
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

# Repair known parenthesis mistakes only when the old pattern exists.
p = Path('lib/screens/profile_screen.dart')
if p.exists():
    s = p.read_text()
    s = s.replace('BorderRadius.circular(16)))), ', 'BorderRadius.circular(16))))), ', 1)
    s = s.replace('BorderRadius.circular(16)))),\n', 'BorderRadius.circular(16))))),\n', 1)
    p.write_text(s)

p = Path('lib/screens/ussd_screen.dart')
if p.exists():
    s = p.read_text()
    s = s.replace(' ]))\n    ])),', ' ])))\n    ])),', 1)
    p.write_text(s)
PY

# Analyzer is validation only; informational diagnostics must not block the release build.
dart analyze
