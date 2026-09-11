import 'package:flutter/material.dart';
import '../services/wallet_service.dart';

class AirtimeScreen extends StatefulWidget {
  const AirtimeScreen({super.key});

  @override
  State<AirtimeScreen> createState() => _AirtimeScreenState();
}

class _AirtimeScreenState extends State<AirtimeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phone = TextEditingController();
  final _amount = TextEditingController();
  String _network = 'MTN';
  bool _loading = false;

  @override
  void dispose() {
    _phone.dispose();
    _amount.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await WalletService.createAirtimeOrder(
        network: _network,
        phone: _phone.text.trim(),
        amount: double.parse(_amount.text.trim()),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Order saved as pending. VTU provider connection is required before fulfilment.'),
      ));
      _phone.clear();
      _amount.clear();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Unable to create order: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buy Airtime'), backgroundColor: Colors.green, foregroundColor: Colors.white),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text('Choose network', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _network,
              items: ['MTN', 'Airtel', 'Glo', '9mobile'].map((n) => DropdownMenuItem(value: n, child: Text(n))).toList(),
              onChanged: (v) => setState(() => _network = v ?? 'MTN'),
              decoration: const InputDecoration(border: OutlineInputBorder(), prefixIcon: Icon(Icons.network_cell)),
            ),
            const SizedBox(height: 16),
            TextFormField(controller: _phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Phone number', border: OutlineInputBorder(), prefixIcon: Icon(Icons.phone)), validator: (v) => (v == null || v.trim().length < 10) ? 'Enter a valid phone number' : null),
            const SizedBox(height: 16),
            TextFormField(controller: _amount, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Amount (₦)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.payments)), validator: (v) { final n = double.tryParse(v?.trim() ?? ''); return n == null || n < 50 ? 'Minimum amount is ₦50' : null; }),
            const SizedBox(height: 22),
            SizedBox(height: 52, child: FilledButton.icon(onPressed: _loading ? null : _submit, icon: const Icon(Icons.shopping_cart_checkout), label: Text(_loading ? 'Saving...' : 'Continue'))),
            const SizedBox(height: 14),
            const Text('Note: live airtime fulfilment will be enabled after a VTU provider and server-side credentials are configured.', style: TextStyle(color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}
