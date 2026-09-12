import 'package:flutter/material.dart';

const _navy = Color(0xFF061B49);
const _navy2 = Color(0xFF0A2C68);
const _gold = Color(0xFFB8860B);
const _bg = Color(0xFF061B49);

class CableTvScreen extends StatefulWidget {
  const CableTvScreen({super.key});
  @override State<CableTvScreen> createState() => _CableTvScreenState();
}

class _CableTvScreenState extends State<CableTvScreen> {
  final _smartCard = TextEditingController();
  String _provider = 'DStv';
  bool _save = false;

  @override
  void dispose() { _smartCard.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        foregroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios_new)),
        title: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Cable TV', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900)), Text('DSTV, GOtv, Startimes & Showmax', style: TextStyle(color: Colors.white60, fontSize: 14))]),
        actions: [TextButton.icon(onPressed: () {}, icon: const Icon(Icons.history, color: _gold), label: const Text('History', style: TextStyle(color: _gold, fontWeight: FontWeight.w800)))],
      ),
      body: ListView(padding: const EdgeInsets.fromLTRB(28, 18, 28, 40), children: [
        _hero(),
        const SizedBox(height: 22),
        _inputCard(),
        const SizedBox(height: 28),
        const Text('SELECT PROVIDER', style: TextStyle(color: Colors.white60, fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: 1.4)),
        const SizedBox(height: 12),
        Row(children: [
          _providerCard('DStv', 'DStv', 'https://www.dstv.com/favicon.ico'),
          const SizedBox(width: 14),
          _providerCard('GOtv', 'GOtv', 'https://www.gotvafrica.com/favicon.ico'),
          const SizedBox(width: 14),
          _providerCard('Startimes', 'Startimes', 'https://www.startimestv.com/favicon.ico'),
        ]),
        const SizedBox(height: 18),
        _saveCard(),
        const SizedBox(height: 18),
        Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: _navy2, borderRadius: BorderRadius.circular(18)), child: const Row(children: [Icon(Icons.info_outline, color: _gold), SizedBox(width: 12), Expanded(child: Text('Provider plans and payment are connected to the VTpass billing flow when enabled. This screen intentionally does not fake a successful purchase.', style: TextStyle(color: Colors.white70, height: 1.35)))])),
      ]),
    );
  }

  Widget _hero() => Container(padding: const EdgeInsets.fromLTRB(36, 28, 22, 28), decoration: BoxDecoration(gradient: const LinearGradient(colors: [_navy2, _navy]), borderRadius: BorderRadius.circular(28), border: Border.all(color: _gold.withValues(alpha: .65))), child: Row(children: [const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Cable TV', style: TextStyle(color: Colors.white, fontSize: 29, fontWeight: FontWeight.w900)), SizedBox(height: 8), Text('Renew or top up your subscription in seconds.', style: TextStyle(color: Colors.white70, fontSize: 17, height: 1.35, fontWeight: FontWeight.w600))])), Container(width: 92, height: 92, decoration: const BoxDecoration(color: _gold, shape: BoxShape.circle), child: const Icon(Icons.live_tv_rounded, color: _navy, size: 48))]));

  Widget _inputCard() => Container(padding: const EdgeInsets.all(22), decoration: BoxDecoration(color: _navy2, borderRadius: BorderRadius.circular(24)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [const Text('Smart Card / IUC Number', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w900)), const Spacer(), TextButton.icon(onPressed: () {}, icon: const Icon(Icons.chevron_right, color: _gold), label: const Text('Beneficiaries', style: TextStyle(color: _gold, fontWeight: FontWeight.w800)))]), const SizedBox(height: 10), TextField(controller: _smartCard, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700), decoration: InputDecoration(hintText: 'Enter Smart Card / IUC Number', hintStyle: const TextStyle(color: Colors.white38, fontWeight: FontWeight.w700), suffixIcon: Container(margin: const EdgeInsets.all(7), decoration: BoxDecoration(color: _gold.withValues(alpha: .13), borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.badge_outlined, color: _gold)), filled: true, fillColor: _navy, border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none)))]));

  Widget _providerCard(String title, String value, String logo) { final selected = _provider == value; return Expanded(child: InkWell(onTap: () => setState(() => _provider = value), borderRadius: BorderRadius.circular(22), child: AnimatedContainer(duration: const Duration(milliseconds: 180), height: 135, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: _navy2, borderRadius: BorderRadius.circular(22), border: Border.all(color: selected ? _gold : Colors.white10, width: selected ? 1.8 : 1)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Container(width: 42, height: 42, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)), child: ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.network(logo, fit: BoxFit.contain, errorBuilder: (_, __, ___) => Center(child: Text(title.substring(0, 1), style: const TextStyle(color: _navy, fontWeight: FontWeight.w900, fontSize: 20))))), const SizedBox(height: 10), Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800))])))); }

  Widget _saveCard() => Container(padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14), decoration: BoxDecoration(color: _navy2, borderRadius: BorderRadius.circular(22)), child: Row(children: [Container(width: 48, height: 48, decoration: BoxDecoration(color: _gold.withValues(alpha: .12), borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.bookmark, color: _gold)), const SizedBox(width: 14), const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Save as Beneficiary', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)), Text('Quickly reuse this smart card next time.', style: TextStyle(color: Colors.white54, height: 1.3))])), Switch(value: _save, activeColor: _gold, onChanged: (v) => setState(() => _save = v))]));
}
