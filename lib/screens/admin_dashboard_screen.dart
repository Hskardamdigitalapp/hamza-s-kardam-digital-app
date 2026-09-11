import 'package:flutter/material.dart';
import '../services/wallet_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  late Future<List<Map<String, dynamic>>> _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = WalletService.getAdminStats();
  }

  void _refresh() {
    setState(() => _statsFuture = WalletService.getAdminStats());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(onPressed: _refresh, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _statsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock_outline, size: 48),
                    const SizedBox(height: 12),
                    Text('Admin access required.', textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    ElevatedButton(onPressed: _refresh, child: const Text('Retry')),
                  ],
                ),
              ),
            );
          }

          final data = snapshot.data ?? [];
          final profiles = _find(data, 'profiles');
          final transactions = _find(data, 'transactions');
          final dataOrders = _find(data, 'data_orders');
          final airtimeOrders = _find(data, 'airtime_orders');
          final wallets = _find(data, 'wallets');
          final pending = [...transactions, ...dataOrders, ...airtimeOrders]
              .where((row) => row['status']?.toString().toLowerCase() == 'pending')
              .length;

          return RefreshIndicator(
            onRefresh: () async => _refresh(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text('Overview', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 14),
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.55,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _card('Users', profiles.length.toString(), Icons.people_outline),
                    _card('Wallets', wallets.length.toString(), Icons.account_balance_wallet_outlined),
                    _card('Transactions', transactions.length.toString(), Icons.receipt_long_outlined),
                    _card('Pending', pending.toString(), Icons.pending_actions_outlined),
                  ],
                ),
                const SizedBox(height: 24),
                const Text('Recent Activity', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                if (transactions.isEmpty)
                  const Card(child: Padding(padding: EdgeInsets.all(18), child: Text('No transactions yet.')))
                else
                  ...transactions.take(20).map((row) => Card(
                        child: ListTile(
                          leading: const CircleAvatar(child: Icon(Icons.receipt_long)),
                          title: Text(row['service']?.toString() ?? row['type']?.toString() ?? 'Transaction'),
                          subtitle: Text('${row['status'] ?? 'pending'} • ${row['created_at'] ?? ''}'),
                          trailing: Text('₦${row['amount'] ?? 0}'),
                        ),
                      )),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Map<String, dynamic>> _find(List<Map<String, dynamic>> data, String key) {
    for (final item in data) {
      if (item.containsKey(key)) return List<Map<String, dynamic>>.from(item[key] as List);
    }
    return [];
  }

  Widget _card(String title, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(icon, size: 30, color: Colors.green),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              Text(title),
            ])),
          ],
        ),
      ),
    );
  }
}
