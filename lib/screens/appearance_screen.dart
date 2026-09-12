import 'package:flutter/material.dart';
import '../theme_controller.dart';

const _navy = Color(0xFF061B49);
const _navy2 = Color(0xFF0A2C68);
const _gold = Color(0xFFC89B3C);
const _bg = Color(0xFFF5F7FB);
const _darkBg = Color(0xFF101216);

class AppearanceScreen extends StatelessWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppThemeController.mode,
      builder: (context, selected, _) => Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text('Appearance', style: TextStyle(fontWeight: FontWeight.w900)),
          backgroundColor: _navy,
          foregroundColor: Colors.white,
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 32),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [_navy, _navy2]),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(Icons.palette_outlined, color: _gold, size: 34),
                SizedBox(height: 12),
                Text('Make the app yours', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                SizedBox(height: 6),
                Text('Choose Light, Dark, or let your phone decide with System default.', style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.4)),
              ]),
            ),
            const SizedBox(height: 18),
            _option(context, selected, ThemeMode.system, Icons.brightness_auto_outlined, 'System default', 'Match your phone\'s appearance.'),
            _option(context, selected, ThemeMode.light, Icons.light_mode_outlined, 'Light', 'Bright and clean.'),
            _option(context, selected, ThemeMode.dark, Icons.dark_mode_outlined, 'Dark', 'Easier on the eyes at night.'),
          ],
        ),
      ),
    );
  }

  Widget _option(BuildContext context, ThemeMode selected, ThemeMode mode, IconData icon, String title, String subtitle) {
    final active = selected == mode;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final card = dark ? _darkBg : Colors.white;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: active ? _gold : Theme.of(context).dividerColor, width: active ? 2 : 1),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(width: 50, height: 50, decoration: BoxDecoration(color: _gold.withOpacity(.16), borderRadius: BorderRadius.circular(16)), child: Icon(icon, color: _gold, size: 27)),
        title: Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
        subtitle: Padding(padding: const EdgeInsets.only(top: 4), child: Text(subtitle)),
        trailing: Icon(active ? Icons.check_circle : Icons.radio_button_unchecked, color: active ? _gold : Theme.of(context).hintColor, size: 28),
        onTap: () async => AppThemeController.setMode(mode),
      ),
    );
  }
}
