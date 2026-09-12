import 'package:flutter/material.dart';
import '../services/wallet_service.dart';

class AirtimeToCashScreen extends StatefulWidget {
  const AirtimeToCashScreen({super.key});
  @override State<AirtimeToCashScreen> createState() => _AirtimeToCashScreenState();
}

class _AirtimeToCashScreenState extends State<AirtimeToCashScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phone = TextEditingController(); final _amount = TextEditingController(); final _bank = TextEditingController(); final _account = TextEditingController(); final _name = TextEditingController();
  String _network = 'MTN'; bool _loading = false; late Future<Map<String, dynamic>> _kycFuture;
  @override void initState() { super.initState(); _kycFuture = WalletService.getMyKycStatus(); }
  @override void dispose() { _phone.dispose(); _amount.dispose(); _bank.dispose(); _account.dispose(); _name.dispose(); super.dispose(); }
  void _snack(String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return; setState(() => _loading = true);
    try {
      await WalletService.createAirtimeCashRequest(network: _network == 'T2' ? '9mobile' : _network, phone: _phone.text.trim(), amount: double.parse(_amount.text.trim()), payoutBank: _bank.text.trim(), accountNumber: _account.text.trim(), accountName: _name.text.trim());
      if (!mounted) return; _phone.clear(); _amount.clear(); _bank.clear(); _account.clear(); _name.clear(); _snack('Airtime-to-Cash request submitted successfully.');
    } catch (e) { if (mounted) _snack(e.toString().replaceFirst('Exception: ', '')); } finally { if (mounted) setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Airtime to Cash'), backgroundColor: const Color(0xFF061B49), foregroundColor: Colors.white),
    body: FutureBuilder<Map<String, dynamic>>(future: _kycFuture, builder: (context, snap) {
      if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
      if (snap.hasError) return _locked(1, 'unverified');
      final kyc = snap.data ?? {}; final tier = int.tryParse('${kyc['tier'] ?? 1}') ?? 1; final status = '${kyc['status'] ?? 'unverified'}';
      if (tier < 2 || status != 'verified') return _locked(tier, status);
      return Form(key: _formKey, child: ListView(padding: const EdgeInsets.all(20), children: [
        _header(), const SizedBox(height: 18),
        DropdownButtonFormField<String>(value: _network, decoration: const InputDecoration(labelText: 'Network'), items: const ['MTN', 'Airtel', 'Glo', 'T2'].map((n) => DropdownMenuItem(value: n, child: Text(n))).toList(), onChanged: (v) => setState(() => _network = v!)),
        const SizedBox(height: 14), TextFormField(controller: _phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Airtime phone number', prefixIcon: Icon(Icons.phone)), validator: (v) => v == null || !RegExp(r'^\d{10,11}$').hasMatch(v.trim()) ? 'Enter a valid phone number' : null),
        const SizedBox(height: 14), TextFormField(controller: _amount, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Airtime amount', prefixText: '₦ ', prefixIcon: Icon(Icons.payments_outlined)), validator: (v) { final amount = double.tryParse(v?.trim() ?? ''); return amount == null || amount < 100 ? 'Minimum amount is ₦100' : null; }),
        const SizedBox(height: 22), const Text('Payout Account', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF061B49))), const SizedBox(height: 12),
        TextFormField(controller: _bank, decoration: const InputDecoration(labelText: 'Bank name', prefixIcon: Icon(Icons.account_balance)), validator: (v) => v == null || v.trim().isEmpty ? 'Enter bank name' : null),
        const SizedBox(height: 14), TextFormField(controller: _account, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Account number', prefixIcon: Icon(Icons.numbers)), validator: (v) => v == null || !RegExp(r'^\d{10}$').hasMatch(v.trim()) ? 'Enter 10-digit account number' : null),
        const SizedBox(height: 14), TextFormField(controller: _name, decoration: const InputDecoration(labelText: 'Account name', prefixIcon: Icon(Icons.person_outline)), validator: (v) => v == null || v.trim().isEmpty ? 'Enter account name' : null),
        const SizedBox(height: 24), SizedBox(height: 54, child: ElevatedButton.icon(onPressed: _loading ? null : _submit, icon: _loading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.send), label: Text(_loading ? 'Submitting...' : 'Submit Request'), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC89B3C), foregroundColor: const Color(0xFF061B49), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), textStyle: const TextStyle(fontWeight: FontWeight.w800)))),
        const SizedBox(height: 14), const Text('Your request will be reviewed and processed after submission.', textAlign: TextAlign.center, style: TextStyle(color: Colors.black54, fontSize: 12)),
      ]));
    }),
  );

  Widget _header() => Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: const Color(0xFF061B49), borderRadius: BorderRadius.circular(20)), child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(Icons.currency_exchange, color: Color(0xFFE7C66A), size: 38), SizedBox(height: 8), Text('Convert Airtime to Cash', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)), SizedBox(height: 5), Text('Your Tier 2 identity verification is active. Enter your airtime and payout details.', style: TextStyle(color: Colors.white70))]));

  Widget _locked(int tier, String status) { final pending = status == 'pending'; return Center(child: SingleChildScrollView(padding: const EdgeInsets.all(22), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Container(width: 82, height: 82, decoration: const BoxDecoration(color: Color(0xFFF4E8C6), shape: BoxShape.circle), child: const Icon(Icons.lock_outline, size: 42, color: Color(0xFF061B49))), const SizedBox(height: 20), const Text('Tier 2 Verification Required', textAlign: TextAlign.center, style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900, color: Color(0xFF061B49))), const SizedBox(height: 10), Text(pending ? 'Your NIN/BVN verification is pending review.' : 'Airtime to Cash is available only after your account reaches verified Tier 2.', textAlign: TextAlign.center, style: const TextStyle(color: Colors.black54, fontSize: 15)), const SizedBox(height: 20), Text('Current account: Tier $tier', style: const TextStyle(fontWeight: FontWeight.w800)), const SizedBox(height: 16), if (!pending) ElevatedButton.icon(onPressed: () => Navigator.pushNamed(context, '/profile'), icon: const Icon(Icons.verified_user), label: const Text('Go to Profile & Verify'), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC89B3C), foregroundColor: Colors.black)), if (pending) const Text('Please wait for verification approval.', style: TextStyle(color: Color(0xFF061B49), fontWeight: FontWeight.w700))])); }
}
