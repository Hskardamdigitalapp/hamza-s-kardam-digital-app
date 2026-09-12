import 'package:flutter/material.dart';

const _bg = Color(0xFF061B49);
const _panel = Color(0xFF0A2C68);
const _gold = Color(0xFFB8860B);

class EducationScreen extends StatefulWidget {
  const EducationScreen({super.key});
  @override
  State<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen> {
  int quantity = 1;
  String exam = 'WAEC';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios_new)),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Education', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900)),
            Text('WAEC, NECO, NABTEB & JAMB', style: TextStyle(color: Colors.white60, fontSize: 14)),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(22),
        children: [
          _hero(),
          const SizedBox(height: 20),
          _quantity(),
          const SizedBox(height: 25),
          const Text('SELECT EXAM', style: TextStyle(color: Colors.white60, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
          const SizedBox(height: 12),
          _examCard('WAEC', 'https://www.waecnigeria.org/favicon.ico'),
          const SizedBox(height: 12),
          _examCard('NECO', 'https://neco.gov.ng/favicon.ico'),
          const SizedBox(height: 12),
          _examCard('NABTEB', 'https://nabteb.gov.ng/favicon.ico'),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: _panel, borderRadius: BorderRadius.circular(18)),
            child: Text(
              exam == 'WAEC'
                  ? 'WAEC is the currently documented VTpass education product.'
                  : 'This option is displayed, but its provider catalogue is not yet connected.',
              style: const TextStyle(color: Colors.white70, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }

  Widget _hero() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [_panel, _bg]),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: _gold),
      ),
      child: const Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Education', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
                SizedBox(height: 7),
                Text('Buy result pins & JAMB profile pins instantly.', style: TextStyle(color: Colors.white70, fontSize: 16)),
              ],
            ),
          ),
          SizedBox(width: 16),
          CircleAvatar(radius: 37, backgroundColor: _gold, child: Icon(Icons.school, color: _bg, size: 40)),
        ],
      ),
    );
  }

  Widget _quantity() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: _panel, borderRadius: BorderRadius.circular(22)),
      child: Row(
        children: [
          const Expanded(child: Text('Quantity', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 17))),
          const Text('Max 5', style: TextStyle(color: Colors.white54)),
          IconButton(onPressed: quantity > 1 ? () => setState(() => quantity--) : null, icon: const Icon(Icons.remove_circle_outline, color: Colors.white54)),
          Text('$quantity', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20)),
          IconButton(onPressed: quantity < 5 ? () => setState(() => quantity++) : null, icon: const Icon(Icons.add_circle_outline, color: _gold)),
        ],
      ),
    );
  }

  Widget _examCard(String name, String logo) {
    final selected = exam == name;
    return InkWell(
      onTap: () => setState(() => exam = name),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 92,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: _panel,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: selected ? _gold : Colors.white10, width: selected ? 2 : 1),
        ),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(image: NetworkImage(logo), fit: BoxFit.contain),
              ),
            ),
            const SizedBox(width: 16),
            Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
            const Spacer(),
            Icon(selected ? Icons.check_circle : Icons.circle_outlined, color: selected ? _gold : Colors.white24),
          ],
        ),
      ),
    );
  }
}
