import 'package:flutter/material.dart';
import '../services/wallet_service.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            FutureBuilder<double>(
              future: _balanceFuture,
              builder: (context, snapshot) {
                final balance = snapshot.data ?? 0;
                return Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Available Balance',
                          style: TextStyle(color: Colors.white70)),
                      const SizedBox(height: 8),
                      Text(
                        '₦${balance.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Payment gateway will be connected here.'),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add_card),
                          label: const Text('Fund Wallet'),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'Wallet Information',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Card(
              child: ListTile(
                leading: const Icon(Icons.security, color: Colors.green),
                title: const Text('Secure wallet'),
                subtitle: const Text(
                  'Your balance is managed by the secure Supabase backend.',
                ),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.history, color: Colors.green),
                title: const Text('Transaction history'),
                subtitle: const Text('View deposits and service transactions.'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.pushNamed(context, '/transactions'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
