import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class RegistrationScreen extends StatelessWidget {
  const RegistrationScreen({super.key});

  static const _bg = Color(0xFF061B49);
  static const _panel = Color(0xFF0A2C68);
  static const _gold = Color(0xFFB8860B);

  Future<void> _open(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not open $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        foregroundColor: Colors.white,
        title: const Text('Registration'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          const Text('Pilgrimage & business registration', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: _panel, borderRadius: BorderRadius.circular(20), border: Border.all(color: _gold.withOpacity(.35))),
            child: const Row(
              children: [
                CircleAvatar(backgroundColor: _gold, child: Icon(Icons.checklist_rounded, color: Colors.white)),
                SizedBox(width: 14),
                Expanded(child: Text('Get registered', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800))),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _Card(
            icon: Icons.mosque_rounded,
            title: 'Hajj / Umrah',
            subtitle: 'Plan your pilgrimage with Bilalsadasub Travels — packages, flights & visa.',
            button: 'Open Travel Partner',
            onTap: () => _open('https://bilalsadasubtravels.com'),
          ),
          const SizedBox(height: 12),
          _Card(
            icon: Icons.business_center_rounded,
            title: 'CAC & Registrations',
            subtitle: 'Access the official CAC portal for business registration and related services.',
            button: 'Open CAC Portal',
            onTap: () => _open('https://pre.cac.gov.ng/'),
          ),
          const SizedBox(height: 12),
          _Card(
            icon: Icons.folder_copy_rounded,
            title: 'My CAC applications',
            subtitle: 'Continue or check applications through the official CAC portal.',
            button: 'Open CAC',
            onTap: () => _open('https://pre.cac.gov.ng/'),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.icon, required this.title, required this.subtitle, required this.button, required this.onTap});
  final IconData icon;
  final String title;
  final String subtitle;
  final String button;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: RegistrationScreen._panel, borderRadius: BorderRadius.circular(18)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: RegistrationScreen._gold, size: 30),
        const SizedBox(height: 10),
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        Text(subtitle, style: const TextStyle(color: Colors.white70, height: 1.4)),
        const SizedBox(height: 12),
        SizedBox(width: double.infinity, child: ElevatedButton(onPressed: onTap, child: Text(button))),
      ]),
    );
  }
}
