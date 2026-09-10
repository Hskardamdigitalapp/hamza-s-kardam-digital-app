import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int index = 0;

  Future<void> logout() async {
    await Supabase.instance.client.auth.signOut();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HAMZA S. KARDAM DIGITAL'),
        actions: [
          IconButton(onPressed: logout, icon: const Icon(Icons.logout)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: const Color(0xFF0B2A20),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Wallet Balance',
                    style: TextStyle(color: Colors.white70, fontSize: 14)),
                SizedBox(height: 8),
                Text('₦0.00',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.w800)),
                SizedBox(height: 18),
                Text('Fund your wallet to buy data and airtime.',
                    style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(child: _action(Icons.account_balance_wallet, 'Fund Wallet')),
              const SizedBox(width: 12),
              Expanded(child: _action(Icons.receipt_long, 'Transactions')),
            ],
          ),
          const SizedBox(height: 22),
          const Text('Quick Services',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _service(Icons.wifi, 'Buy Data')),
              const SizedBox(width: 12),
              Expanded(child: _service(Icons.phone_android, 'Airtime')),
              const SizedBox(width: 12),
              Expanded(child: _service(Icons.more_horiz, 'More')),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Popular Data Bundles',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          _bundle('MTN', '10GB', '₦3,000'),
          _bundle('Airtel', '10GB', '₦3,000'),
          _bundle('Glo', '10GB', '₦3,000'),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) => setState(() => index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.shopping_bag_outlined), label: 'Orders'),
          NavigationDestination(icon: Icon(Icons.account_balance_wallet_outlined), label: 'Wallet'),
          NavigationDestination(icon: Icon(Icons.menu), label: 'More'),
        ],
      ),
    );
  }

  Widget _action(IconData icon, String title) {
    return FilledButton.tonalIcon(
      onPressed: () {},
      icon: Icon(icon),
      label: Text(title),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }

  Widget _service(IconData icon, String title) {
    return Card(
      elevation: 0,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
          child: Column(
            children: [
              Icon(icon, color: const Color(0xFF0A8F55), size: 30),
              const SizedBox(height: 8),
              Text(title, textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bundle(String network, String data, String price) {
    return Card(
      elevation: 0,
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFE4F4EC),
          child: Icon(Icons.sim_card, color: Color(0xFF0A8F55)),
        ),
        title: Text('$network • $data',
            style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: const Text('Fast activation'),
        trailing: Text(price,
            style: const TextStyle(fontWeight: FontWeight.w800)),
      ),
    );
  }
}
