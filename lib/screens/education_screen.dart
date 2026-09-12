import 'package:flutter/material.dart';

class EducationScreen extends StatefulWidget {
  const EducationScreen({super.key});
  @override
  State<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen> {
  static const _bg = Color(0xFF061B49);
  static const _panel = Color(0xFF0A2C68);
  static const _gold = Color(0xFFB8860B);
  int _quantity = 1;
  String? _selected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(backgroundColor: _bg, foregroundColor: Colors.white, title: const Text('Education'), elevation: 0),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          const Text('WAEC, NECO, NABTEB & JAMB', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: _panel, borderRadius: BorderRadius.circular(20), border: Border.all(color: _gold.withOpacity(.35))),
            child: const Row(children: [CircleAvatar(backgroundColor: _gold, child: Icon(Icons.school_rounded, color: Colors.white)), SizedBox(width: 14), Expanded(child: Text('Education', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)))]),
          ),
          const SizedBox(height: 12),
          const Text('Buy result pins & JAMB profile pins instantly.', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: _panel, borderRadius: BorderRadius.circular(18)),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Quantity', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              Row(children: [IconButton(onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null, icon: const Icon(Icons.remove_circle_outline, color: Colors.white)), Text('$_quantity', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)), IconButton(onPressed: _quantity < 5 ? () => setState(() => _quantity++) : null, icon: const Icon(Icons.add_circle_outline, color: _gold))]),
            ]),
          ),
          const SizedBox(height: 18),
          ...['WAEC', 'NECO', 'NABTEB', 'JAMB'].map((name) => Padding(padding: const EdgeInsets.only(bottom: 10), child: _ExamCard(name: name, selected: _selected == name, onTap: () => setState(() => _selected = name)))),
          if (_selected != null) Padding(padding: const EdgeInsets.only(top: 6), child: Text('Selected $_selected × $_quantity. Provider purchase will use the configured provider catalog.', style: const TextStyle(color: Colors.white70))),
        ],
      ),
    );
  }
}

class _ExamCard extends StatelessWidget {
  const _ExamCard({required this.name, required this.selected, required this.onTap});
  final String name;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(16),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF0A2C68), borderRadius: BorderRadius.circular(16), border: Border.all(color: selected ? const Color(0xFFB8860B) : Colors.white12, width: selected ? 2 : 1)),
      child: Row(children: [const Icon(Icons.school_rounded, color: Color(0xFFB8860B)), const SizedBox(width: 12), Expanded(child: Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800))), if (selected) const Icon(Icons.check_circle, color: Color(0xFFB8860B))]),
    ),
  );
}
