import 'package:flutter/material.dart';

const _navy = Color(0xFF061B49);
const _navy2 = Color(0xFF0A2C68);
const _gold = Color(0xFFB8860B);
const _bg = Color(0xFF061B49);

class EducationScreen extends StatefulWidget {
  const EducationScreen({super.key});
  @override State<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen> {
  int _quantity = 1;
  String _exam = 'WAEC';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(backgroundColor: _bg, foregroundColor: Colors.white, elevation: 0, leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios_new)), title: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Education', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900)), Text('WAEC, NECO, NABTEB & JAMB', style: TextStyle(color: Colors.white60, fontSize: 14))]), actions: [TextButton.icon(onPressed: () {}, icon: const Icon(Icons.history, color: _gold), label: const Text('History', style: TextStyle(color: _gold, fontWeight: FontWeight.w800)))]),
      body: ListView(padding: const EdgeInsets.fromLTRB(28, 18, 28, 40), children: [
        Container(padding: const EdgeInsets.fromLTRB(36, 28, 22, 28), decoration: BoxDecoration(gradient: const LinearGradient(colors: [_navy2, _navy]), borderRadius: BorderRadius.circular(28), border: Border.all(color: _gold.withValues(alpha: .65))), child: Row(children: [const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Education', style: TextStyle(color: Colors.white, fontSize: 29, fontWeight: FontWeight.w900)), SizedBox(height: 8), Text('Buy result pins & JAMB profile pins instantly.', style: TextStyle(color: Colors.white70, fontSize: 17, height: 1.35, fontWeight: FontWeight.w600))])), Container(width: 92, height: 92, decoration: const BoxDecoration(color: _gold, shape: BoxShape.circle), child: const Icon(Icons.school_rounded, color: _navy, size: 48))])),
        const SizedBox(height: 22),
        Container(padding: const EdgeInsets.all(22), decoration: BoxDecoration(color: _navy2, borderRadius: BorderRadius.circular(24)), child: Row(children: [Container(width: 52, height: 52, decoration: BoxDecoration(color: _gold.withValues(alpha: .12), borderRadius: BorderRadius.circular(15)), child: const Icon(Icons.tag, color: _gold, size: 30)), const SizedBox(width: 14), const Expanded(child: Text('Quantity', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w900))), const Text('Max 5 per purchase', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w700)), const SizedBox(width: 8), IconButton(onPressed: _quantity <= 1 ? null : () => setState(() => _quantity--), icon: const Icon(Icons.remove_circle_outline, color: Colors.white54)), Text('$_quantity', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)), IconButton(onPressed: _quantity >= 5 ? null : () => setState(() => _quantity++), icon: const Icon(Icons.add_circle_outline, color: _gold))])),
        const SizedBox(height: 28),
        const Text('SELECT EXAM', style: TextStyle(color: Colors.white60, fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: 1.4)),
        const SizedBox(height: 12),
        Row(children: [_examCard('WAEC', 'https://www.waecnigeria.org/favicon.ico'), const SizedBox(width: 14), _examCard('NECO', 'https://neco.gov.ng/favicon.ico'), const SizedBox(width: 14), _examCard('NABTEB', 'https://nabteb.gov.ng/favicon.ico')]),
        const SizedBox(height: 20),
        Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: _navy2, borderRadius: BorderRadius.circular(18)), child: Row(children: [const Icon(Icons.info_outline, color: _gold), const SizedBox(width: 12), Expanded(child: Text(_exam == 'WAEC' ? 'WAEC is the currently documented VTpass education product. NECO/NABTEB remain visible only as service options until their provider catalogue is connected.' : 'This exam option is displayed in the service design, but its provider catalogue is not yet connected.', style: const TextStyle(color: Colors.white70, height: 1.35)))])),
      ]),
    );
  }

  Widget _examCard(String title, String logo) { final selected = _exam == title; return Expanded(child: InkWell(onTap: () => setState(() => _exam = title), borderRadius: BorderRadius.circular(22), child: AnimatedContainer(duration: const Duration(milliseconds: 180), height: 155, decoration: BoxDecoration(color: _navy2, borderRadius: BorderRadius.circular(22), border: Border.all(color: selected ? _gold : Colors.white10, width: selected ? 1.8 : 1)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Container(width: 54, height: 54, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)), child: ClipRRect(borderRadius: BorderRadius.circular(14), child: Image.network(logo, fit: BoxFit.contain, errorBuilder: (_, __, ___) => Center(child: Text(title[0], style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 24))))), const SizedBox(height: 14), Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 17))])))); }
}
