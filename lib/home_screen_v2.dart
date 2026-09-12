import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'services/wallet_service.dart';

const _bg = Color(0xFF061B49);
const _panel = Color(0xFF0A2C68);
const _gold = Color(0xFFB8860B);
const _muted = Color(0xFFB7C2D6);
const _address = 'Shop No. 32, Gidan Late Mallam Shitu, Opposite Hamidu Mosque, Shanta, Unguwar Hardo Shagari Road, Bauchi, Bauchi State, Nigeria';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<double> _balance;
  bool _hide = false;
  @override void initState() { super.initState(); _balance = WalletService.getBalance(); }
  Future<void> _refresh() async { setState(() => _balance = WalletService.getBalance()); await _balance; }
  Future<void> _whatsapp([String text = 'Hello H.salah Communication, I need help.']) async { await launchUrl(Uri.parse('https://wa.me/2349044444921?text=${Uri.encodeComponent(text)}'), mode: LaunchMode.externalApplication); }
  Future<void> _call() async { await launchUrl(Uri.parse('tel:07077777636'), mode: LaunchMode.externalApplication); }

  String _greeting(String? name) { final h = DateTime.now().hour; final g = h < 12 ? 'Good Morning' : h < 17 ? 'Good Afternoon' : 'Good Evening'; return '$g, ${name?.isNotEmpty == true ? name : 'Welcome'} 👋'; }

  @override Widget build(BuildContext context) {
    final user = WalletService.currentUser;
    final name = user?.userMetadata?['full_name']?.toString().trim();
    final avatar = WalletService.avatarUrl;
    return Scaffold(
      backgroundColor: _bg,
      body: RefreshIndicator(color: _gold, onRefresh: _refresh, child: ListView(padding: const EdgeInsets.only(bottom: 100), children: [_top(name, avatar), _wallet(), _services(), _shop()])),
      bottomNavigationBar: _bottom(),
    );
  }

  Widget _top(String? name, String? avatar) => Container(
    padding: const EdgeInsets.fromLTRB(20, 52, 20, 24),
    decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF0A2C68), _bg]), borderRadius: BorderRadius.vertical(bottom: Radius.circular(30))),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [CircleAvatar(radius: 21, backgroundColor: _gold, child: Text('HK', style: TextStyle(color: _bg, fontWeight: FontWeight.w900))), SizedBox(width: 10), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('HAMZA S. KARDAM', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)), Text('DIGITAL APP', style: TextStyle(color: _gold, fontWeight: FontWeight.w900, fontSize: 11))])]),
        const SizedBox(height: 22), Text(_greeting(name), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)), const SizedBox(height: 3), const Text('Fast • Reliable • Secure', style: TextStyle(color: Colors.white70)),
      ])),
      Column(children: [GestureDetector(onTap: () => Navigator.pushNamed(context, '/profile'), child: CircleAvatar(radius: 29, backgroundColor: _gold, backgroundImage: avatar?.isNotEmpty == true ? NetworkImage(avatar!) : null, child: avatar?.isNotEmpty == true ? null : const Icon(Icons.person, color: _bg, size: 34))), IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none, color: Colors.white, size: 27))]),
    ]),
  );

  Widget _wallet() => Padding(padding: const EdgeInsets.all(18), child: Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF0A2C68), _bg]), borderRadius: BorderRadius.circular(24), border: Border.all(color: _gold)), child: FutureBuilder<double>(future: _balance, builder: (_, s) { final b = s.data ?? 0; return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [const Icon(Icons.account_balance_wallet_outlined, color: _gold), const SizedBox(width: 8), const Text('Wallet Balance', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)), const Spacer(), IconButton(onPressed: () => setState(() => _hide = !_hide), icon: Icon(_hide ? Icons.visibility_off : Icons.visibility, color: Colors.white70))]), Text(_hide ? '₦ ••••••' : '₦${b.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900)), const SizedBox(height: 14), Row(children: [Expanded(child: ElevatedButton.icon(onPressed: () => Navigator.pushNamed(context, '/wallet'), icon: const Icon(Icons.add), label: const Text('Fund Wallet'))), const SizedBox(width: 10), Expanded(child: OutlinedButton.icon(onPressed: () => Navigator.pushNamed(context, '/transactions'), icon: const Icon(Icons.history), label: const Text('History')))])]); }))); 

  Widget _services() => Padding(padding: const EdgeInsets.symmetric(horizontal: 18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Our Services', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)), const SizedBox(height: 12), GridView.count(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisCount: 4, mainAxisSpacing: 14, crossAxisSpacing: 10, childAspectRatio: .78, children: [
    _tile(Icons.wifi, 'Buy Data', () => Navigator.pushNamed(context, '/data')), _tile(Icons.phone_android, 'Buy Airtime', () => Navigator.pushNamed(context, '/airtime')), _tile(Icons.currency_exchange, 'Airtime to Cash', () => Navigator.pushNamed(context, '/airtime-to-cash')), _tile(Icons.sim_card, 'Buy SIMs', () => _whatsapp('Hello, I want to buy a SIM.')), _tile(Icons.swap_horiz, 'SIM Swap', () => _whatsapp('Hello, I need SIM swap assistance.')), _tile(Icons.live_tv, 'Cable TV', () => Navigator.pushNamed(context, '/cable-tv')), _tile(Icons.school, 'Education', () => Navigator.pushNamed(context, '/education')), _tile(Icons.app_registration, 'Registration', () => Navigator.pushNamed(context, '/registration')), _tile(Icons.bolt, 'Electricity', () => _soon('Electricity')), _tile(Icons.home_work_outlined, 'Home Service', () => _whatsapp('Hello, I need home service.')), _tile(Icons.account_balance, 'Withdraw', () => Navigator.pushNamed(context, '/wallet')), _tile(Icons.person_add_alt_1, 'Send to User', () => _soon('Send to User')), _tile(Icons.savings, 'Earn', () => _soon('Earn')), _tile(Icons.currency_bitcoin, 'Crypto', () => Navigator.pushNamed(context, '/fund-crypto')), _tile(Icons.flight, 'Flight', () => _soon('Flight')), _tile(Icons.card_giftcard, 'Gift Card', () => _soon('Gift Card')),
  ])]));

  Widget _tile(IconData icon, String label, VoidCallback tap) => InkWell(onTap: tap, borderRadius: BorderRadius.circular(18), child: Column(children: [Container(width: 58, height: 58, decoration: BoxDecoration(color: const Color(0xFF102A56), borderRadius: BorderRadius.circular(17), border: Border.all(color: Colors.white10)), child: Icon(icon, color: _gold, size: 30)), const SizedBox(height: 7), Expanded(child: Text(label, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)))]));

  Widget _shop() => Padding(padding: const EdgeInsets.all(18), child: Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: _panel, borderRadius: BorderRadius.circular(20), border: Border.all(color: _gold.withValues(alpha: .35))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Row(children: [Icon(Icons.storefront_outlined, color: _gold), SizedBox(width: 9), Text('H.salah Communication', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w900))]), const SizedBox(height: 8), const Text(_address, style: TextStyle(color: _muted, fontSize: 13, height: 1.35)), const SizedBox(height: 12), Row(children: [Expanded(child: OutlinedButton.icon(onPressed: _call, icon: const Icon(Icons.call), label: const Text('0707 777 7636'))), const SizedBox(width: 10), Expanded(child: OutlinedButton.icon(onPressed: _whatsapp, icon: const Icon(Icons.chat), label: const Text('09044444921')))])])));

  Widget _bottom() => NavigationBar(backgroundColor: const Color(0xFF0A2C68), indicatorColor: _gold.withValues(alpha: .16), selectedIndex: 0, onDestinationSelected: (i) { if (i == 1) Navigator.pushNamed(context, '/orders'); if (i == 2) Navigator.pushNamed(context, '/transactions'); if (i == 3) Navigator.pushNamed(context, '/wallet'); if (i == 4) Navigator.pushNamed(context, '/profile'); }, destinations: const [NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home, color: _gold), label: 'Home'), NavigationDestination(icon: Icon(Icons.receipt_long_outlined), label: 'Orders'), NavigationDestination(icon: Icon(Icons.swap_horiz), label: 'Transactions'), NavigationDestination(icon: Icon(Icons.account_balance_wallet_outlined), label: 'Wallet'), NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile')]);
  void _soon(String name) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$name is not connected yet.')));
}
