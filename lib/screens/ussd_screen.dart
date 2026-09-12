import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/network_logo.dart';

class UssdScreen extends StatelessWidget {
  const UssdScreen({super.key});
  static const _navy = Color(0xFF061B49);
  static const _gold = Color(0xFFC89B3C);
  static const _codes = <String, List<Map<String, String>>>{
    'MTN': [{'title': 'Check Phone Number', 'code': '*663#'}, {'title': 'Check Airtime Balance', 'code': '*310#'}, {'title': 'Check Data Balance', 'code': '*323#'}],
    'Airtel': [{'title': 'Check Phone Number / Airtime', 'code': '*310#'}, {'title': 'Check Data Balance', 'code': '*323#'}],
    'Glo': [{'title': 'Check Phone Number', 'code': '*135*8#'}, {'title': 'Check Airtime Balance', 'code': '*310#'}, {'title': 'Check Data Balance', 'code': '*323#'}],
    'T2': [{'title': 'Check Phone Number', 'code': '*200#'}, {'title': 'Check Airtime Balance', 'code': '*310#'}, {'title': 'Check Data Balance', 'code': '*323#'}],
  };

  Future<void> _copy(BuildContext context, String code) async { await Clipboard.setData(ClipboardData(text: code)); if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$code copied to clipboard'))); }
  Future<void> _dial(BuildContext context, String code) async { final uri = Uri.parse('tel:${code.replaceAll('#', '%23')}'); if (!await launchUrl(uri)) await _copy(context, code); }

  @override Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF5F7FB),
    appBar: AppBar(title: const Text('USSD Codes', style: TextStyle(fontWeight: FontWeight.w800)), backgroundColor: _navy, foregroundColor: Colors.white),
    body: ListView(padding: const EdgeInsets.fromLTRB(16, 18, 16, 30), children: [
      const Text('Dial or copy network short codes', style: TextStyle(fontSize: 15, color: Colors.black54)),
      const SizedBox(height: 6), const Text('Quick USSD', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: _navy)),
      const SizedBox(height: 5), const Text('Check your balance, data or phone number. Tap any code to dial or copy it instantly.', style: TextStyle(color: Colors.black54, height: 1.35)),
      const SizedBox(height: 18), ..._codes.entries.map((entry) => _NetworkCard(network: entry.key, codes: entry.value, onDial: (code) => _dial(context, code), onCopy: (code) => _copy(context, code))),
    ]),
  );
}

class _NetworkCard extends StatelessWidget {
  const _NetworkCard({required this.network, required this.codes, required this.onDial, required this.onCopy});
  final String network;
  final List<Map<String, String>> codes;
  final ValueChanged<String> onDial;
  final ValueChanged<String> onCopy;

  @override Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 14), elevation: 0, color: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    child: Padding(padding: const EdgeInsets.fromLTRB(16, 16, 16, 8), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [NetworkLogo(network: network, size: 46), const SizedBox(width: 12), Expanded(child: Text(network, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: Color(0xFF061B49)))), Text('${codes.length} short codes', style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w600))]),
      const SizedBox(height: 10),
      ...codes.map((item) => ListTile(contentPadding: EdgeInsets.zero, title: Text(item['title']!, style: const TextStyle(fontWeight: FontWeight.w700)), subtitle: Text(item['code']!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF061B49))), trailing: Row(mainAxisSize: MainAxisSize.min, children: [IconButton(tooltip: 'Copy', onPressed: () => onCopy(item['code']!), icon: const Icon(Icons.copy_rounded)), IconButton(tooltip: 'Dial', onPressed: () => onDial(item['code']!), icon: const Icon(Icons.phone_in_talk_rounded, color: Color(0xFFC89B3C))) ]))
    ])),
  );
}
