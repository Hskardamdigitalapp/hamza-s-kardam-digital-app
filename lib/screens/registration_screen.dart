import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

const _gold = Color(0xFFFFC72C);
const _bg = Color(0xFF101010);

class RegistrationScreen extends StatelessWidget {
  const RegistrationScreen({super.key});

  Future<void> _open(String url) async {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(backgroundColor: _bg, foregroundColor: Colors.white, elevation: 0, leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios_new)), title: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Registration', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900)), Text('Pilgrimage & business registration', style: TextStyle(color: Colors.white60, fontSize: 14))])),
      body: ListView(padding: const EdgeInsets.fromLTRB(28, 18, 28, 40), children: [
        Container(padding: const EdgeInsets.fromLTRB(36, 28, 22, 28), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF211F16), Color(0xFF171717)]), borderRadius: BorderRadius.circular(28), border: Border.all(color: _gold.withValues(alpha: .65))), child: Row(children: [const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Get registered', style: TextStyle(color: Colors.white, fontSize: 29, fontWeight: FontWeight.w900)), SizedBox(height: 8), Text('Plan your Hajj/Umrah or register your business — all in one place.', style: TextStyle(color: Colors.white70, fontSize: 17, height: 1.35, fontWeight: FontWeight.w600))])), Container(width: 92, height: 92, decoration: const BoxDecoration(color: _gold, shape: BoxShape.circle), child: const Icon(Icons.assignment_turned_in_rounded, color: Color(0xFF151515), size: 48))])),
        const SizedBox(height: 28),
        const Text('CHOOSE A SERVICE', style: TextStyle(color: Colors.white60, fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: 1.4)),
        const SizedBox(height: 12),
        _serviceCard(context, Icons.mosque_rounded, 'Hajj / Umrah', 'Book your pilgrimage with a trusted travel partner — packages, flights & visa.', 'bilalsadasubtravels.com', () => _open('https://bilalsadasubtravels.com')),
        const SizedBox(height: 14),
        _serviceCard(context, Icons.verified_rounded, 'CAC & Registrations', 'Register your business name or limited company with the Corporate Affairs Commission.', 'Start application', () => _open('https://pre.cac.gov.ng/')),
        const SizedBox(height: 14),
        InkWell(onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('My CAC applications will show your submitted applications once the CAC workflow is connected.'))), borderRadius: BorderRadius.circular(20), child: Container(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20), decoration: BoxDecoration(color: const Color(0xFF1A1A1D), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white10)), child: const Row(children: [Icon(Icons.receipt_long_rounded, color: _gold, size: 30), SizedBox(width: 16), Expanded(child: Text('My CAC applications', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w900))), Icon(Icons.chevron_right, color: Colors.white60)]))),
      ]),
    );
  }

  Widget _serviceCard(BuildContext context, IconData icon, String title, String description, String action, VoidCallback onTap) => InkWell(onTap: onTap, borderRadius: BorderRadius.circular(22), child: Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: const Color(0xFF1A1A1D), borderRadius: BorderRadius.circular(22), border: Border.all(color: Colors.white10)), child: Row(children: [Container(width: 68, height: 68, decoration: BoxDecoration(color: _gold.withValues(alpha: .12), borderRadius: BorderRadius.circular(18)), child: Icon(icon, color: _gold, size: 34)), const SizedBox(width: 16), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w900)), const SizedBox(height: 7), Text(description, style: const TextStyle(color: Colors.white60, fontSize: 14, height: 1.35, fontWeight: FontWeight.w600)), const SizedBox(height: 10), Row(children: [Text(action, style: const TextStyle(color: _gold, fontWeight: FontWeight.w900)), const SizedBox(width: 4), const Icon(Icons.arrow_forward, color: _gold, size: 18)])]))]));
}
