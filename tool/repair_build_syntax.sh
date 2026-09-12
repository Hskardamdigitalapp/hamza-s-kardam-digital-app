#!/usr/bin/env bash
set -euo pipefail
python3 - <<'PY'
from pathlib import Path

# Repair only known source/API issues before the release build.
fixes = {
    'lib/main.dart': [
        ("await Supabase.initialize(url: supabaseUrl, anonKey: supabasePublishableKey);", "await Supabase.initialize(url: supabaseUrl, publishableKey: supabasePublishableKey);"),
    ],
    'lib/screens/data_screen.dart': [
        ("Icon(Icons.chevron_right_rounded, color: _navy)])),", "Icon(Icons.chevron_right_rounded, color: _navy)]))),"),
    ],
    'lib/screens/airtime_screen.dart': [
        ("Icon(Icons.chevron_right_rounded, color: _navy)])));", "Icon(Icons.chevron_right_rounded, color: _navy)])));"),
        ("Icon(Icons.chevron_right_rounded, color: _navy)]))));", "Icon(Icons.chevron_right_rounded, color: _navy)])));"),
        ("Icon(Icons.chevron_right_rounded, color: _navy)]));", "Icon(Icons.chevron_right_rounded, color: _navy)])));"),
    ],
    'lib/screens/ussd_screen.dart': [
        ("color: _gold", "color: Color(0xFFC89B3C)"),
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

# Repair the airtime-to-cash locked-state closing delimiter if present.
p = Path('lib/screens/airtime_to_cash_screen.dart')
if p.exists():
    s = p.read_text()
    old = "Text('Please wait for verification approval.', style: TextStyle(color: Color(0xFF061B49), fontWeight: FontWeight.w700))])); }"
    new = "Text('Please wait for verification approval.', style: TextStyle(color: Color(0xFF061B49), fontWeight: FontWeight.w700))]))); }"
    s = s.replace(old, new)
    p.write_text(s)
PY

# Warnings are not build blockers; Dart errors still fail this validation.
dart analyze --no-fatal-warnings
