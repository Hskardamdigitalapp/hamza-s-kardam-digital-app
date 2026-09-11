import 'package:flutter/material.dart';
import '../services/wallet_service.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});
  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<Map<String, dynamic>>> _load() async {
    final data = await WalletService.getDataOrders();
    final airtime = await WalletService.getAirtimeOrders();
    final all = <Map<String, dynamic>>[...data.map((e) => {...e, '_service': 'Data'}), ...airtime.map((e) => {...e, '_service': 'Airtime'})];
    all.sort((a, b) => (b['created_at']?.toString() ?? '').compareTo(a['created_at']?.toString() ?? ''));
    return all;
  }

  Future<void> _refresh() async {
    setState(() => _future = _load());
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Orders'), backgroundColor: Colors.green, foregroundColor: Colors.white),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
            if (snapshot.hasError) return ListView(children: [Padding(padding: const EdgeInsets.all(24), child: Text('Unable to load orders: ${snapshot.error}'))]);
            final orders = snapshot.data ?? [];
            if (orders.isEmpty) return ListView(children: const [SizedBox(height: 120), Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey), SizedBox(height: 16), Center(child: Text('No orders yet'))]);
            return ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final o = orders[i];
                final service = o['_service']?.toString() ?? 'Order';
                final status = o['status']?.toString() ?? 'pending';
                final amount = double.tryParse(o['amount']?.toString() ?? '') ?? 0;
                final network = o['network']?.toString() ?? '';
                final phone = o['phone']?.toString() ?? '';
                final plan = o['plan']?.toString();
                return Card(child: ListTile(
                  leading: CircleAvatar(child: Icon(service == 'Data' ? Icons.data_usage : Icons.phone_android)),
                  title: Text('$service${plan != null && plan.isNotEmpty ? ' • $plan' : ''}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('$network • $phone\n$status'),
                  isThreeLine: true,
                  trailing: Text('₦${amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                ));
              },
            );
          },
        ),
      ),
    );
  }
}
