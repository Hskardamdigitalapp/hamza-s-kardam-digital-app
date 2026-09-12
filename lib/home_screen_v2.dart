import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'services/wallet_service.dart';

const _navy = Color(0xFF061B49);
const _navy2 = Color(0xFF0A2C68);
const _gold = Color(0xFFB8860B);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<double> _balance;
  bool _hide = false;
  bool _showAllServices = false;

  @override
  void initState() { super.initState(); _balance = WalletService.getBalance(); }
  Future<void> _refresh() async { setState(() => _balance = WalletService.getBalance()); await _balance; }

  Future<void> _whatsapp([String text = 'Hello HAMZA S. KARDAM DIGITAL APP, I need help.']) async {
    await launchUrl(Uri.parse('https://wa.me/2349044444921?text=${Uri.encodeComponent(text)}'), mode: LaunchMode.externalApplication);
  }

  String _greeting(String? name) {
    final h = DateTime.now().hour;
    final g = h < 12 ? 'Good Morning' : h < 17 ? 'Good Afternoon' : 'Good Evening';
    return '$g, ${name?.isNotEmpty == true ? name : 'Welcome'} 👋';
  }

  Future<void> _homeSimSwap() async {
    final address = TextEditingController();
    String network = 'MTN';
    final submitted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(builder: (context, setDialogState) => AlertDialog(
        backgroundColor: _navy2,
        title: const Text('Home SIM Swap', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Align(alignment: Alignment.centerLeft, child: Text('Price: ₦2,500', style: TextStyle(color: _gold, fontSize: 18, fontWeight: FontWeight.w900))),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: network,
            dropdownColor: _navy2,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            decoration: const InputDecoration(labelText: 'Network', labelStyle: TextStyle(color: Colors.white70)),
            items: const [DropdownMenuItem(value: 'MTN', child: Text('MTN')), DropdownMenuItem(value: 'Airtel', child: Text('Airtel'))],
            onChanged: (v) => setDialogState(() => network = v ?? network),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: address,
            maxLines: 3,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(labelText: 'Your address', hintText: 'Send the exact location where we should come', labelStyle: TextStyle(color: Colors.white70), hintStyle: TextStyle(color: Colors.white38)),
          ),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: address.text.trim().isEmpty ? null : () => Navigator.pop(dialogContext, true), child: const Text('Request')),
        ],
      )),
    );
    if (submitted == true && address.text.trim().isNotEmpty) {
      await _whatsapp('Hello HAMZA S. KARDAM DIGITAL APP, I want $network Home SIM Swap. Price: ₦2,500. My address is: ${address.text.trim()}');
    }
    address.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final bg = dark ? _navy : const Color(0xFFF5F7FB);
    final text = dark ? Colors.white : _navy;
    final user = WalletService.currentUser;
    final name = user?.userMetadata?['full_name']?.toString().trim();
    final avatar = WalletService.avatarUrl;
    return Scaffold(
      backgroundColor: bg,
      body: RefreshIndicator(color: _gold, onRefresh: _refresh, child: ListView(padding: const EdgeInsets.only(bottom: 100), children: [_top(name, avatar), _wallet(dark), _services(text, dark), const SizedBox(height: 12)])),
      bottomNavigationBar: _bottom(),
    );
  }

  Widget _top(String? name, String? avatar) => Container(
    padding: const EdgeInsets.fromLTRB(20, 52, 20, 24),
    decoration: const BoxDecoration(gradient: LinearGradient(colors: [_navy2, _navy]), borderRadius: BorderRadius.vertical(bottom: Radius.circular(30))),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [CircleAvatar(radius: 21, backgroundColor: _gold, child: Text('HK', style: TextStyle(color: _navy, fontWeight: FontWeight.w900))), SizedBox(width: 10), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('HAMZA S. KARDAM', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)), Text('DIGITAL APP', style: TextStyle(color: _gold, fontWeight: FontWeight.w900, fontSize: 11))])]),
        const SizedBox(height: 22),
        Text(_greeting(name), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
        const SizedBox(height: 3),
        const Text('Fast • Reliable • Secure', style: TextStyle(color: Colors.white70)),
      ])),
      Column(children: [
        GestureDetector(onTap: () => Navigator.pushNamed(context, '/profile'), child: CircleAvatar(radius: 29, backgroundColor: _gold, backgroundImage: avatar?.isNotEmpty == true ? NetworkImage(avatar!) : null, child: avatar?.isNotEmpty == true ? null : const Icon(Icons.person, color: _navy, size: 34))),
        IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none, color: Colors.white, size: 27)),
      ]),
    ]),
  );

  Widget _wallet(bool dark) => Padding(
    padding: const EdgeInsets.all(18),
    child: Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(gradient: const LinearGradient(colors: [_navy2, _navy]), borderRadius: BorderRadius.circular(24), border: Border.all(color: _gold)),
      child: FutureBuilder<double>(future: _balance, builder: (_, s) {
        final b = s.data ?? 0;
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [const Icon(Icons.account_balance_wallet_outlined, color: _gold), const SizedBox(width: 8), const Text('Wallet Balance', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)), const Spacer(), IconButton(onPressed: () => setState(() => _hide = !_hide), icon: Icon(_hide ? Icons.visibility_off : Icons.visibility, color: Colors.white70))]),
          Text(_hide ? '₦ ••••••' : '₦${b.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900)),
          const SizedBox(height: 14),
          Row(children: [Expanded(child: ElevatedButton.icon(onPressed: () => Navigator.pushNamed(context, '/wallet'), icon: const Icon(Icons.add), label: const Text('Fund Wallet'))), const SizedBox(width: 10), Expanded(child: OutlinedButton.icon(onPressed: () => Navigator.pushNamed(context, '/transactions'), icon: const Icon(Icons.history), label: const Text('History'), style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: _gold))))]),
        ]);
      }),
    ),
  );

  Widget _services(Color text, bool dark) {
    final services = <Map<String, dynamic>>[
      {'i': Icons.wifi, 't': 'Buy Data', 'f': () => Navigator.pushNamed(context, '/data')},
      {'i': Icons.phone_android, 't': 'Buy Airtime', 'f': () => Navigator.pushNamed(context, '/airtime')},
      {'i': Icons.currency_exchange, 't': 'Airtime to Cash', 'f': () => Navigator.pushNamed(context, '/airtime-to-cash')},
      {'i': Icons.sim_card, 't': 'Buy SIMs', 'f': () => _whatsapp('Hello, I want to buy a SIM.')},
      {'i': Icons.swap_horiz, 't': 'SIM Swap', 'f': () => _homeSimSwap()},
      {'i': Icons.live_tv, 't': 'Cable TV', 'f': () => Navigator.pushNamed(context, '/cable-tv')},
      {'i': Icons.school, 't': 'Education', 'f': () => Navigator.pushNamed(context, '/education')},
      {'i': Icons.app_registration, 't': 'Registration', 'f': () => Navigator.pushNamed(context, '/registration')},
      {'i': Icons.bolt, 't': 'Electricity', 'f': () => _soon('Electricity')},
      {'i': Icons.home_work_outlined, 't': 'Home Service', 'f': () => _homeSimSwap()},
      {'i': Icons.account_balance, 't': 'Withdraw', 'f': () => Navigator.pushNamed(context, '/wallet')},
      {'i': Icons.person_add_alt_1, 't': 'Send to User', 'f': () => _soon('Send to User')},
      {'i': Icons.savings, 't': 'Earn', 'f': () => _soon('Earn')},
      {'i': Icons.currency_bitcoin, 't': 'Crypto', 'f': () => Navigator.pushNamed(context, '/fund-crypto')},
      {'i': Icons.flight, 't': 'Flight', 'f': () => _soon('Flight')},
      {'i': Icons.card_giftcard, 't': 'Gift Card', 'f': () => _soon('Gift Card')},
    ];
    final visible = _showAllServices ? services : services.take(4).toList();
    return Padding(padding: const EdgeInsets.symmetric(horizontal: 18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Text('Our Services', style: TextStyle(color: text, fontSize: 22, fontWeight: FontWeight.w900)), const Spacer(), TextButton(onPressed: () => setState(() => _showAllServices = !_showAllServices), child: Text(_showAllServices ? 'Show less' : 'View all', style: const TextStyle(color: _gold, fontWeight: FontWeight.w800)))]),
      const SizedBox(height: 8),
      GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: visible.length, gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, mainAxisSpacing: 14, crossAxisSpacing: 10, childAspectRatio: .78), itemBuilder: (_, i) => _tile(visible[i]['i'] as IconData, visible[i]['t'] as String, visible[i]['f'] as VoidCallback, text, dark)),
    ]));
  }

  Widget _tile(IconData icon, String label, VoidCallback tap, Color text, bool dark) => InkWell(onTap: tap, borderRadius: BorderRadius.circular(18), child: Column(children: [Container(width: 58, height: 58, decoration: BoxDecoration(color: dark ? const Color(0xFF102A56) : Colors.white, borderRadius: BorderRadius.circular(17), border: Border.all(color: dark ? Colors.white10 : _gold.withValues(alpha: .25))), child: Icon(icon, color: _gold, size: 30)), const SizedBox(height: 7), Expanded(child: Text(label, textAlign: TextAlign.center, style: TextStyle(color: text, fontSize: 12, fontWeight: FontWeight.w700)))]));

  Widget _bottom() => NavigationBar(backgroundColor: Theme.of(context).cardColor, indicatorColor: _gold.withValues(alpha: .16), selectedIndex: 0, onDestinationSelected: (i) { if (i == 1) Navigator.pushNamed(context, '/orders'); if (i == 2) Navigator.pushNamed(context, '/transactions'); if (i == 3) Navigator.pushNamed(context, '/wallet'); if (i == 4) Navigator.pushNamed(context, '/profile'); }, destinations: const [NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home, color: _gold), label: 'Home'), NavigationDestination(icon: Icon(Icons.receipt_long_outlined), label: 'Orders'), NavigationDestination(icon: Icon(Icons.swap_horiz), label: 'Transactions'), NavigationDestination(icon: Icon(Icons.account_balance_wallet_outlined), label: 'Wallet'), NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile')]);

  void _soon(String name) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$name is not connected yet.')));
}
