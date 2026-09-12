#!/usr/bin/env bash
set -euo pipefail
python3 - <<'PY'
from pathlib import Path

# Supabase API rename for current supabase_flutter.
p = Path('lib/main.dart')
if p.exists():
    s = p.read_text().replace(
        "await Supabase.initialize(url: supabaseUrl, anonKey: supabasePublishableKey);",
        "await Supabase.initialize(url: supabaseUrl, publishableKey: supabasePublishableKey);",
    )
    p.write_text(s)

# The repository also contains a legacy root main.dart. Keep its imports valid.
p = Path('main.dart')
if p.exists():
    s = p.read_text()
    s = s.replace("import 'screens/login_screen.dart';", "import 'lib/screens/login_screen.dart';")
    s = s.replace("import 'screens/register_screen.dart';", "import 'lib/screens/register_screen.dart';")
    s = s.replace("import 'screens/home_screen.dart';", "import 'lib/home_screen.dart';")
    s = s.replace(
        "await Supabase.initialize(url: supabaseUrl, anonKey: supabasePublishableKey);",
        "await Supabase.initialize(url: supabaseUrl, publishableKey: supabasePublishableKey);",
    )
    p.write_text(s)

# Fix the missing closing parenthesis in the data USSD card (the comma means
# InkWell closes on the following line, so do not add an extra ')' before it).
p = Path('lib/screens/data_screen.dart')
if p.exists():
    s = p.read_text()
    s = s.replace(
        "Icon(Icons.chevron_right_rounded, color: _navy)]))),\n  );",
        "Icon(Icons.chevron_right_rounded, color: _navy)])),\n  );",
    )
    p.write_text(s)

# Fix the missing closing parenthesis on the Profile logout button.
p = Path('lib/screens/profile_screen.dart')
if p.exists():
    s = p.read_text()
    s = s.replace(
        "shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)))),\n          ]));",
        "shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))))),\n          ]));",
    )
    p.write_text(s)

# Fix the missing closing parenthesis around each USSD ListTile map item.
p = Path('lib/screens/ussd_screen.dart')
if p.exists():
    s = p.read_text()
    s = s.replace(
        "icon: const Icon(Icons.phone_in_talk_rounded, color: Color(0xFFC89B3C))) ]))\n    ])),",
        "icon: const Icon(Icons.phone_in_talk_rounded, color: Color(0xFFC89B3C))) ])))\n    ])),",
    )
    p.write_text(s)
PY

# Keep informational diagnostics non-fatal while still failing on real Dart errors.
dart analyze --no-fatal-warnings
