#!/usr/bin/env bash
set -euo pipefail
python3 - <<'PY'
from pathlib import Path

# Keep the build self-healing for known syntax/import mistakes.
fixes = {
    'lib/main.dart': [
        ("import 'screens/login_screen.dart';", "import '../login_screen.dart';"),
        ("import 'screens/register_screen.dart';", "import '../register_screen.dart';"),
        ("import 'home_screen.dart';", "import '../home_screen.dart';"),
        ("await Supabase.initialize(url: supabaseUrl, anonKey: supabasePublishableKey);", "await Supabase.initialize(url: supabaseUrl, publishableKey: supabasePublishableKey);"),
    ],
}
for name, pairs in fixes.items():
    p = Path(name)
    s = p.read_text()
    for old, new in pairs:
        s = s.replace(old, new)
    p.write_text(s)

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

dart analyze
