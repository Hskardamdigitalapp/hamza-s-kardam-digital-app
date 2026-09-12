import 'package:flutter/material.dart';

const _bg = Color(0xFF061B49);
const _panel = Color(0xFF0A2C68);
const _gold = Color(0xFFB8860B);

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
      appBar: AppBar(
        backgroundColor: _bg,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios_new)),
        title: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Education', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900)),
          Text('WAEC, NECO, NABTEB & JAMB', style: TextStyle(color: Colors.white60, fontSize: 14)),
        ]),
        actions: [TextButton(onPressed: () {}, child: const Text('History', style: TextStyle(color: _gold)))],
      ),
      body: ListView(padding: const EdgeInsets.all(22), children: [
        _hero(),
        const SizedBox(height: 20),
        _quantityCard(),
        const SizedBox(height: 25),
        const Text('SELECT EXAM', style: TextStyle(color: Colors.white60, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
        const SizedBox(height: 12),
        Row(children: [
          _examCard('WAEC', 'https://www.waecnigeria.org/favicon.ico'),
          const SizedBox(width: 10),
          _examCard('NECO', 'https://neco.gov.ng/favicon.ico'),
          const SizedBox(width: 10),
          _examCard('NABTEB', 'https://nabteb.gov.ng/favicon.ico'),
        ]),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: _panel, borderRadius: BorderRadius.circular(18)),
          child: Text(
            _exam == 'WAEC' ? 'WAEC is the currently documented VTpass education product.' : 'This option is displayed, but its provider catalogue is not yet connected.',
            style: const TextStyle(color: Colors.white70, height: 1.35),
          ),
        ),
      ]),
    );
  }

  Widget _hero() => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(gradient: const LinearGradient(colors: [_panel, _bg]), borderRadius: BorderRadius.circular(25), border: Border.all(color: _gold)),
    child: Row(children: [
      const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Education', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
        SizedBox(height: 7),
        Text('Buy result pins & JAMB profile pins instantly.', style: TextStyle(color: Colors.white70, fontSize: 16)),
      ])),
      Container(width: 75, height: 75, decoration: const BoxDecoration(color: _gold, shape: BoxShape.circle), child: const Icon(Icons.school, color: _bg, size: 40)),
    ]),
  );

  Widget _quantityCard() => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(color: _panel, borderRadius: BorderRadius.circular(22)),
    child: Row(children: [
      const Expanded(child: Text('Quantity', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 17))),
      const Text('Max 5', style: TextStyle(color: Colors.white54)),
      IconButton(onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null, icon: const Icon(Icons.remove_circle_outline, color: Colors.white54)),
      Text('$_quantity', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20)),
      IconButton(onPressed: _quantity < 5 ? () => setState(() => _quantity++) : null, icon: const Icon(Icons.add_circle_outline, color: _gold)),
    ]),
  );

  Widget _examCard(String name, String logo) {
    final selected = _exam == name;
    return Expanded(child: InkWell(
      onTap: () => setState(() => _exam = name),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 140,
        decoration: BoxDecoration(color: _panel, borderRadius: BorderRadius.circular(18), border: Border.all(color: selected ? _gold : Colors.white10, width: selected ? 2 : 1)),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(width: 52, height: 52, color: Colors.white, child: Image.network(logo, fit: BoxFit.contain, errorBuilder: (_, __, ___) => Center(child: Text(name[0], style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 22)))),
          const SizedBox(height: 10),
          Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
        ]),
      ),
    ));
  }
}
