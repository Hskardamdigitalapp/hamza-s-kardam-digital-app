import 'package:flutter/material.dart';
import '../services/wallet_service.dart';

class DataScreen extends StatefulWidget {
  const DataScreen({super.key});

  @override
  State<DataScreen> createState() => _DataScreenState();
}

class _DataScreenState extends State<DataScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phone = TextEditingController();
  final _plan = TextEditingController();
  final _amount = TextEditingController();
  String _network = 'MTN';
  bool _loading = false;

  @override
  void dispose() { _phone.dispose(); _plan.dispose(); _amount.dispose(); super.dispose(); }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await WalletService.createDataOrder(
        network: _network,
        phone: _phone.text.trim(),
        plan: _plan.text.trim(),
        amount: double.parse(_amount.text.trim()),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order saved as pending. VTU provider connection is required before fulfilment.')));
      _phone.clear(); _plan.clear(); _amount.clear();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Unable to create order: $e')));
    } finally { if (mounted) setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buy Data'), backgroundColor: Colors.green, foregroundColor: Colors.white),
      body: Form(key: _formKey, child: ListView(padding: const EdgeInsets.all(20), children: [
        const Text('Choose network', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(value: _network, items: ['MTN','Airtel','Glo','9mobile'].map((n) => DropdownMenuItem(value: n, child: Text(n))).toList(), onChanged: (v) => setState(() => _network = v ?? 'MTN'), decoration: const InputDecoration(border: OutlineInputBorder(), prefixIcon: Icon(Icons.network_cell))),
        const SizedBox(height: 16),
        TextFormField(controller: _phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Phone number', border: OutlineInputBorder(), prefixIcon: Icon(Icons.phone)), validator: (v) => (v == null || v.trim().length < 10) ? 'Enter a valid phone number' : null),
        const SizedBox(height: 16),
        TextFormField(controller: _plan, decoration: const InputDecoration(labelText: 'Data plan (e.g. 1GB)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.data_usage)), validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter a data plan' : null),
        const SizedBox(height: 16),
        TextFormField(controller: _amount, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Amount (₦)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.payments)), validator: (v) { final n = double.tryParse(v?.trim() ?? ''); return n == null || n <= 0 ? 'Enter a valid amount' : null; }),
        const SizedBox(height: 22),
        SizedBox(height: 52, child: FilledButton.icon(onPressed: _loading ? null : _submit, icon: const Icon(Icons.shopping_cart_checkout), label: Text(_loading ? 'Saving...' : 'Continue'))),
        const SizedBox(height: 14),
        const Text('Note: live data fulfilment will be enabled after a VTU provider and server-side credentials are configured.', style: TextStyle(color: Colors.black54)),
      ])),
    );
  }
}
