import 'package:flutter/material.dart';
import 'services/wallet_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<double> _balanceFuture;

  @override
  void initState() {
    super.initState();
    _balanceFuture = WalletService.getBalance();
  }

  Future<void> _refresh() async {
    setState(() => _balanceFuture = WalletService.getBalance());
    await _balanceFuture;
  }

  Future<void> _logout() async {
    await WalletService.logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final user = WalletService.currentUser;
    final name = user?.userMetadata?['full_name']?.toString();
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6),
      appBar: AppBar(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('HAMZA S. KARDAM', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [IconButton(onPressed: _logout, icon: const Icon(Icons.logout))],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Welcome ${name?.isNotEmpty == true ? name : ''} 👋', style: const TextStyle(fontSize: 16, color: Colors.black54)),
            const SizedBox(height: 4),
            const Text('HAMZA S. KARDAM DIGITAL APP', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 18),
            FutureBuilder<double>(
              future: _balanceFuture,
              builder: (context, snapshot) {
                final balance = snapshot.data ?? 0;
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(20)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Row(children: [Icon(Icons.account_balance_wallet_outlined, color: Colors.white), SizedBox(width: 8), Text('Wallet Balance', style: TextStyle(color: Colors.white, fontSize: 16))]),
                    const SizedBox(height: 12),
                    Text('₦${balance.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => Navigator.pushNamed(context, '/wallet'), child: const Text('Manage Wallet'))),
                  ]),
                );
              },
            ),
            const SizedBox(height: 24),
            const Text('Quick Services', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _serviceCard(Icons.wifi, 'Buy Data', () => Navigator.pushNamed(context, '/data'))),
              const SizedBox(width: 12),
              Expanded(child: _serviceCard(Icons.phone_android, 'Airtime', () => Navigator.pushNamed(context, '/airtime'))),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _serviceCard(Icons.receipt_long, 'My Orders', () => Navigator.pushNamed(context, '/transactions'))),
              const SizedBox(width: 12),
              Expanded(child: _serviceCard(Icons.history, 'Transactions', () => Navigator.pushNamed(context, '/transactions'))),
            ]),
            const SizedBox(height: 26),
            const Text('Popular Data Bundles', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _bundleCard('MTN Data', '1GB', '₦500'),
            const SizedBox(height: 10),
            _bundleCard('Airtel Data', '2GB', '₦700'),
            const SizedBox(height: 10),
            _bundleCard('Glo Data', '3GB', '₦800'),
            const SizedBox(height: 18),
            const Text('Live services will be enabled after VTU and payment provider credentials are configured.', style: TextStyle(color: Colors.black54)),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: Colors.green,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 1) Navigator.pushNamed(context, '/transactions');
          if (index == 2) Navigator.pushNamed(context, '/wallet');
          if (index == 3) _showMore();
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), activeIcon: Icon(Icons.receipt_long), label: 'Orders'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_outlined), activeIcon: Icon(Icons.account_balance_wallet), label: 'Wallet'),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'More'),
        ],
      ),
    );
  }

  Widget _serviceCard(IconData icon, String title, VoidCallback onTap) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(16),
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(children: [Icon(icon, color: Colors.green, size: 34), const SizedBox(height: 8), Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold))]),
    ),
  );

  Widget _bundleCard(String title, String amount, String price) => InkWell(
    onTap: () => Navigator.pushNamed(context, '/data'),
    borderRadius: BorderRadius.circular(16),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.green.withOpacity(.1), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.data_usage, color: Colors.green)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), const SizedBox(height: 4), Text(amount)])),
        Text(price, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ]),
    ),
  );

  void _showMore() {
    showModalBottomSheet<void>(context: context, showDragHandle: true, builder: (_) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
      ListTile(leading: const Icon(Icons.account_balance_wallet), title: const Text('Wallet'), onTap: () { Navigator.pop(context); Navigator.pushNamed(context, '/wallet'); }),
      ListTile(leading: const Icon(Icons.history), title: const Text('Transactions'), onTap: () { Navigator.pop(context); Navigator.pushNamed(context, '/transactions'); }),
      ListTile(leading: const Icon(Icons.person_outline), title: const Text('Profile'), subtitle: Text(WalletService.currentUser?.email ?? ''), onTap: () => Navigator.pop(context)),
      ListTile(leading: const Icon(Icons.logout), title: const Text('Logout'), onTap: () { Navigator.pop(context); _logout(); }),
    ])));
  }
}
