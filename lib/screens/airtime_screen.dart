import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/wallet_service.dart';
import '../widgets/network_logo.dart';

class AirtimeScreen extends StatefulWidget {
  const AirtimeScreen({super.key});
  @override State<AirtimeScreen> createState() => _AirtimeScreenState();
}

class _AirtimeScreenState extends State<AirtimeScreen> {
  static const _navy = Color(0xFF061B49);
  static const _gold = Color(0xFFC89B3C);
  static const _bg = Color(0xFFF5F7FB);
  static const _storage = FlutterSecureStorage();
  final _formKey = GlobalKey<FormState>();
  final _phone = TextEditingController();
  final _amount = TextEditingController();
  String _network = 'MTN';
  bool _loading = false;
  bool _saveBeneficiary = false;
  List<String> _beneficiaries = [];

  @override
  void initState() { super.initState(); _loadBeneficiaries(); }
  @override
  void dispose() { _phone.dispose(); _amount.dispose(); super.dispose(); }

  Future<void> _loadBeneficiaries() async {
    final raw = await _storage.read(key: 'kardam_airtime_beneficiaries');
    if (!mounted || raw == null || raw.isEmpty) return;
    setState(() => _beneficiaries = raw.split(',').where((e) => e.trim().isNotEmpty).toSet().toList());
  }

  Future<void> _saveBeneficiaryNumber() async {
    final number = _phone.text.replaceAll(RegExp(r'\D'), '');
    if (number.length < 10 || !_saveBeneficiary) return;
    final list = {..._beneficiaries, number}.toList();
    await _storage.write(key: 'kardam_airtime_beneficiaries', value: list.join(','));
    if (mounted) setState(() => _beneficiaries = list);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final result = await WalletService.buyAirtime(network: _network, phone: _phone.text.trim(), amount: double.parse(_amount.text.trim()));
      await _saveBeneficiaryNumber();
      if (!mounted) return;
      final status = result['status']?.toString() ?? 'processing';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(status == 'delivered' ? 'Airtime delivered successfully.' : status == 'processing' ? 'Airtime order is processing. Check Transactions for updates.' : 'Airtime order failed.')));
      if (status == 'delivered' || status == 'processing') { _phone.clear(); _amount.clear(); }
    } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Unable to buy airtime: $e'))); }
    finally { if (mounted) setState(() => _loading = false); }
  }

  void _setAmount(int amount) { setState(() { _amount.text = amount.toString(); _amount.selection = TextSelection.collapsed(offset: _amount.text.length); }); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(backgroundColor: _navy, foregroundColor: Colors.white, title: const Text('Buy Airtime', style: TextStyle(fontWeight: FontWeight.w900)), actions: [IconButton(tooltip: 'History', onPressed: () => Navigator.pushNamed(context, '/transactions'), icon: const Icon(Icons.history_rounded))]),
      body: Form(key: _formKey, child: ListView(padding: const EdgeInsets.fromLTRB(16, 18, 16, 30), children: [
        const Text('Recharge any line in seconds', style: TextStyle(color: Colors.black54, fontSize: 15)),
        const SizedBox(height: 5),
        const Text('Buy Airtime', style: TextStyle(color: _navy, fontSize: 27, fontWeight: FontWeight.w900)),
        const SizedBox(height: 4),
        const Text('Top up any Nigerian line instantly for you or a friend.', style: TextStyle(color: Colors.black54)),
        const SizedBox(height: 20),
        _sectionLabel('Phone Number'),
        TextFormField(controller: _phone, keyboardType: TextInputType.phone, decoration: InputDecoration(hintText: '08012345678', prefixIcon: const Icon(Icons.phone_rounded), suffixIcon: _beneficiaries.isEmpty ? null : IconButton(tooltip: 'Beneficiaries', onPressed: _showBeneficiaries, icon: const Icon(Icons.contacts_rounded))), validator: (v) => (v == null || v.replaceAll(RegExp(r'\D'), '').length < 10) ? 'Enter a valid phone number' : null),
        Align(alignment: Alignment.centerRight, child: TextButton.icon(onPressed: _beneficiaries.isEmpty ? null : _showBeneficiaries, icon: const Icon(Icons.people_alt_outlined), label: const Text('Beneficiaries'))),
        const SizedBox(height: 7),
        _sectionLabel('SELECT NETWORK'),
        const SizedBox(height: 9),
        _networkSelector(),
        const SizedBox(height: 20),
        _sectionLabel('QUICK AMOUNT'),
        const SizedBox(height: 9),
        Wrap(spacing: 10, runSpacing: 10, children: [100, 200, 500, 1000].map((v) => InkWell(onTap: () => _setAmount(v), borderRadius: BorderRadius.circular(14), child: Container(width: 76, padding: const EdgeInsets.symmetric(vertical: 13), alignment: Alignment.center, decoration: BoxDecoration(color: _amount.text == v.toString() ? const Color(0xFFFFF7D6) : Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: _amount.text == v.toString() ? _gold : const Color(0xFFE5E5EA), width: _amount.text == v.toString() ? 2 : 1)), child: Text('₦$v', style: const TextStyle(color: _navy, fontWeight: FontWeight.w900))))).toList()),
        const SizedBox(height: 20),
        _sectionLabel('OR ENTER AMOUNT'),
        const SizedBox(height: 8),
        TextFormField(controller: _amount, keyboardType: const TextInputType.numberWithOptions(decimal: true), onChanged: (_) => setState(() {}), decoration: const InputDecoration(prefixText: '₦ ', hintText: 'Enter amount', prefixIcon: Icon(Icons.payments_rounded)), validator: (v) { final n = double.tryParse(v?.trim() ?? ''); return n == null || n < 50 ? 'Minimum amount is ₦50' : null; }),
        const SizedBox(height: 8),
        CheckboxListTile(value: _saveBeneficiary, onChanged: (v) => setState(() => _saveBeneficiary = v ?? false), contentPadding: EdgeInsets.zero, activeColor: _gold, title: const Text('Save as Beneficiary', style: TextStyle(fontWeight: FontWeight.w800)), subtitle: const Text('Quickly reuse this number next time.')),
        const SizedBox(height: 8),
        _ussdCard(),
        const SizedBox(height: 18),
        SizedBox(height: 54, child: FilledButton(onPressed: _loading ? null : _submit, style: FilledButton.styleFrom(backgroundColor: _navy, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), child: Text(_loading ? 'Processing...' : 'Buy Airtime', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)))),
      ])),
    );
  }

  Widget _sectionLabel(String text) => Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Colors.black54, letterSpacing: .4));

  Widget _networkSelector() => SizedBox(height: 88, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: 4, separatorBuilder: (_, __) => const SizedBox(width: 10), itemBuilder: (_, i) { final n = ['MTN', 'Glo', 'Airtel', '9mobile'][i]; final selected = n == _network; return InkWell(onTap: () => setState(() => _network = n), borderRadius: BorderRadius.circular(17), child: AnimatedContainer(duration: const Duration(milliseconds: 180), width: 78, padding: const EdgeInsets.all(7), decoration: BoxDecoration(color: selected ? const Color(0xFFFFF7D6) : Colors.white, borderRadius: BorderRadius.circular(17), border: Border.all(color: selected ? _gold : const Color(0xFFE5E5EA), width: selected ? 2 : 1)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [NetworkLogo(network: n, size: 40), const SizedBox(height: 4), Text(n, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800))]))); }));

  Widget _ussdCard() => InkWell(onTap: () => Navigator.pushNamed(context, '/ussd'), borderRadius: BorderRadius.circular(18), child: Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: _gold.withOpacity(.35))), child: const Row(children: [Icon(Icons.dialpad_rounded, color: _gold, size: 30), SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('USSD Enquiry', style: TextStyle(color: _navy, fontWeight: FontWeight.w900, fontSize: 16)), SizedBox(height: 3), Text('Check airtime balance and more', style: TextStyle(color: Colors.black54, fontSize: 12))])), Icon(Icons.chevron_right_rounded, color: _navy)]));

  void _showBeneficiaries() { showModalBottomSheet<void>(context: context, showDragHandle: true, builder: (_) => SafeArea(child: ListView(padding: const EdgeInsets.all(18), children: [const Text('Beneficiaries', style: TextStyle(color: _navy, fontSize: 21, fontWeight: FontWeight.w900)), const SizedBox(height: 10), ..._beneficiaries.map((n) => ListTile(leading: const Icon(Icons.person_outline, color: _navy), title: Text(n, style: const TextStyle(fontWeight: FontWeight.w800)), trailing: const Icon(Icons.arrow_forward_ios, size: 15), onTap: () { Navigator.pop(context); setState(() => _phone.text = n); }))]))); }
}
