import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

const _navy = Color(0xFF061B49);
const _navy2 = Color(0xFF0A2C68);
const _gold = Color(0xFFFFC83D);
const _dark = Color(0xFF17191E);

class CustomerCareScreen extends StatelessWidget {
  const CustomerCareScreen({super.key});

  Future<void> _whatsapp(BuildContext context) async {
    final uri = Uri.parse('https://wa.me/2349044444921?text=${Uri.encodeComponent('Hello H.salah communication, I need customer care support.')}');
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('WhatsApp could not be opened.')));
  }

  Future<void> _call(BuildContext context) async {
    final ok = await launchUrl(Uri.parse('tel:07077777636'), mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Phone dialer could not be opened.')));
  }

  void _openAiHelp(BuildContext context) {
    showModalBottomSheet<void>(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (ctx) => Container(padding: const EdgeInsets.fromLTRB(20, 14, 20, 28), decoration: BoxDecoration(color: Theme.of(ctx).scaffoldBackgroundColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(30))), child: SafeArea(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Center(child: Container(width: 42, height: 4, decoration: BoxDecoration(color: Theme.of(ctx).dividerColor, borderRadius: BorderRadius.circular(4)))), const SizedBox(height: 18), const Row(children: [CircleAvatar(backgroundColor: Color(0x26FFC83D), child: Icon(Icons.auto_awesome_rounded, color: _gold)), SizedBox(width: 12), Text('AI Assistant', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900))]), const SizedBox(height: 8), const Text('Quick smart help for HAMZA S. KARDAM DIGITAL APP.'), const SizedBox(height: 18), _faq(ctx, 'How do I fund my wallet?', 'Open Wallet and choose Fund Wallet to see available funding options.'), _faq(ctx, 'How do I buy data or airtime?', 'Use Buy Data or Buy Airtime from Home, choose the network and enter the amount.'), _faq(ctx, 'Can I talk to a human?', 'Yes. Choose Talk to a real person and WhatsApp support will open.'), const SizedBox(height: 6), SizedBox(width: double.infinity, height: 52, child: ElevatedButton.icon(onPressed: () => _whatsapp(ctx), icon: const Icon(Icons.chat_outlined), label: const Text('Talk to a real person on WhatsApp'), style: ElevatedButton.styleFrom(backgroundColor: _gold, foregroundColor: _navy, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))))]))));
  }

  Widget _faq(BuildContext context, String q, String a) => Container(margin: const EdgeInsets.only(bottom: 9), padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E2025) : Colors.white, borderRadius: BorderRadius.circular(16)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(q, style: const TextStyle(fontWeight: FontWeight.w900)), const SizedBox(height: 4), Text(a, style: const TextStyle(color: Colors.grey))]));

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(backgroundColor: dark ? _dark : const Color(0xFFF5F7FB), appBar: AppBar(backgroundColor: _navy, foregroundColor: Colors.white, title: const Text('Customer Care', style: TextStyle(fontWeight: FontWeight.w900))), body: SafeArea(child: ListView(padding: const EdgeInsets.fromLTRB(18, 18, 18, 30), children: [
      Container(padding: const EdgeInsets.fromLTRB(22, 24, 22, 24), decoration: const BoxDecoration(gradient: LinearGradient(colors: [_navy, _navy2]), borderRadius: BorderRadius.all(Radius.circular(26))), child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [CircleAvatar(radius: 25, backgroundColor: Color(0x26FFC83D), child: Icon(Icons.support_agent_rounded, color: _gold, size: 30)), SizedBox(width: 14), Text('HAMZA S. KARDAM', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: 1.2))]), SizedBox(height: 22), Text('Hi there!', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)), SizedBox(height: 4), Text('How can we help today?', style: TextStyle(color: Colors.white70, fontSize: 17, fontWeight: FontWeight.w600)), SizedBox(height: 16), Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.circle, color: Color(0xFF39D98A), size: 12), SizedBox(width: 8), Text('Online · Replies in mins', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700))])])),
      const SizedBox(height: 20), const Text('Choose your support', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900)), const SizedBox(height: 12),
      _supportCard(context, Icons.auto_awesome_rounded, 'AI Assistant', 'Quick answers about the app, wallet and services', () => _openAiHelp(context)),
      _supportCard(context, Icons.support_agent_rounded, 'Talk to a real person', 'Real human support on WhatsApp', () => _whatsapp(context)),
      const SizedBox(height: 10),
      Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: dark ? const Color(0xFF1E2025) : Colors.white, borderRadius: BorderRadius.circular(22), border: Border.all(color: _gold.withOpacity(.22))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Contact us', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)), const SizedBox(height: 14), _contact(context, Icons.call_outlined, 'Call', '0707 777 7636', () => _call(context)), const SizedBox(height: 10), _contact(context, Icons.chat_outlined, 'WhatsApp', '09044444921', () => _whatsapp(context))])),
      const SizedBox(height: 20), const Text('Recent help', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)), const SizedBox(height: 10),
      Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: dark ? const Color(0xFF1E2025) : Colors.white, borderRadius: BorderRadius.circular(20)), child: const Row(children: [CircleAvatar(backgroundColor: Color(0x26FFC83D), child: Icon(Icons.headset_mic_outlined, color: _gold)), SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('H.salah Customer Care', style: TextStyle(fontWeight: FontWeight.w900)), SizedBox(height: 4), Text('We are here to help with your digital services.', style: TextStyle(color: Colors.grey))]))])),
    ]));
  }

  Widget _supportCard(BuildContext context, IconData icon, String title, String sub, VoidCallback onTap) { final dark = Theme.of(context).brightness == Brightness.dark; return Container(margin: const EdgeInsets.only(bottom: 12), decoration: BoxDecoration(color: dark ? const Color(0xFF1E2025) : Colors.white, borderRadius: BorderRadius.circular(22), border: Border.all(color: _gold.withOpacity(.18))), child: ListTile(contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9), leading: Container(width: 56, height: 56, decoration: BoxDecoration(color: _gold.withOpacity(.16), borderRadius: BorderRadius.circular(18)), child: Icon(icon, color: _gold, size: 29)), title: Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)), subtitle: Padding(padding: const EdgeInsets.only(top: 5), child: Text(sub)), trailing: Container(width: 42, height: 42, decoration: BoxDecoration(color: _gold, borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.arrow_forward_rounded, color: _navy)), onTap: onTap)); }
  Widget _contact(BuildContext context, IconData icon, String label, String value, VoidCallback onTap) => InkWell(onTap: onTap, borderRadius: BorderRadius.circular(16), child: Row(children: [Container(width: 44, height: 44, decoration: BoxDecoration(color: _gold.withOpacity(.16), borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: _gold)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(fontWeight: FontWeight.w800)), const SizedBox(height: 2), Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700))])), const Icon(Icons.chevron_right)]));
}
