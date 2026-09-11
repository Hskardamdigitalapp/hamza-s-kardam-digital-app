import 'package:flutter/material.dart';
import '../services/wallet_service.dart';

const _navy = Color(0xFF061B49);
const _gold = Color(0xFFC89B3C);

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = WalletService.getTransactions();
  }

  Future<void> _refresh() async {
    setState(() => _future = WalletService.getTransactions());
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        backgroundColor: _navy,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        color: _gold,
        onRefresh: _refresh,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: _gold));
            }
            if (snapshot.hasError) {
              return ListView(children: [
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text('Unable to load transactions: ${snapshot.error}'),
                ),
              ]);
            }

            final items = snapshot.data ?? [];
            if (items.isEmpty) {
              return ListView(children: const [
                SizedBox(height: 120),
                Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Center(child: Text('No transactions yet')),
              ]);
            }

            return ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final tx = items[index];
                final amount = double.tryParse(tx['amount']?.toString() ?? '') ?? 0;
                final status = tx['status']?.toString() ?? 'pending';
                final service = tx['service']?.toString() ?? tx['type']?.toString() ?? 'Transaction';
                final network = tx['network']?.toString();

                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _navy.withOpacity(.08),
                      child: Icon(
                        amount < 0 ? Icons.arrow_upward : Icons.arrow_downward,
                        color: _navy,
                      ),
                    ),
                    title: Text(service, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text([
                      if (network != null && network.isNotEmpty) network,
                      status,
                      tx['created_at']?.toString() ?? '',
                    ].join(' • ')),
                    trailing: Text(
                      '₦${amount.abs().toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
