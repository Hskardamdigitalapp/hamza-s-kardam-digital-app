import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/wallet_service.dart';
import '../widgets/network_logo.dart';

class DataScreen extends StatefulWidget {
  const DataScreen({super.key});
  @override State<DataScreen> createState() => _DataScreenState();
}

class _DataScreenState extends State<DataScreen> {
  static const _navy = Color(0xFF061B49);
  static const _gold = Color(0xFFC89B3C);
  static const _bg = Color(0xFFF5F7FB);
  static const _storage = FlutterSecureStorage();
  final _formKey = GlobalKey<FormState>();
  final _phone = TextEditingController();
  String _network = 'MTN';
  bool _loadingPlans = true, _buying = false, _saveBeneficiary = false;
  List<Map<String, dynamic>> _plans = [];
  Map<String, dynamic>? _selected;
  List<String> _beneficiaries = [];

  @override
  void initState() { super.initState(); _loadBeneficiaries(); _loadPlans(); }
  @override
  void dispose() { _phone.dispose(); super.dispose(); }

  Future<void> _loadBeneficiaries() async {
    final raw = await _storage.read(key: 'kardam_data_beneficiaries');
    if (!mounted || raw == null || raw.isEmpty) return;
    setState(() => _beneficiaries = raw.split(',').where((e) => e.trim().isNotEmpty).toSet().toList());
  }

  Future<void> _saveBeneficiaryNumber() async {
    if (!_saveBeneficiary) return;
    final number = _phone.text.replaceAll(RegExp(r'\D'), '');
    if (number.length < 10) return;
    final list = {..._beneficiaries, number}.toList();
    await _storage.write(key: 'kardam_data_beneficiaries', value: list.join(','));
    if (mounted) setState(() => _beneficiaries = list);
  }

  Future<void> _loadPlans() async {
    setState(() => _loadingPlans = true);
    try {
      final plans = await WalletService.getDataPlans(_network == 'T2' ? '9mobile' : _network);
      if (mounted) setState(() { _plans = plans; _selected = plans.isEmpty ? null : plans.first; });
    } catch (e) {
      if (mounted) {
        setState(() { _plans = []; _selected = null; });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Unable to load data plans: $e')));
      }
    } finally { if (mounted) setState(() => _loadingPlans = false); }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _selected == null) return;
    setState(() => _buying = true);
    try {
      final result = await WalletService.buyData(
        network: _network == 'T2' ? '9mobile' : _network,
        phone: _phone.text.trim(),
        plan: _selected!['name'].toString(),
        variationCode: _selected!['code'].toString(),
        amount: double.parse(_selected!['amount'].toString()),
      );
      await _saveBeneficiaryNumber();
      if (!mounted) return;
      final status = result['status']?.toString() ?? 'processing';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(
        status == 'delivered' ? 'Data delivered successfully.' :
        status == 'processing' ? 'Data order is processing. Check Transactions for updates.' : 'Data order failed.',
      )));
      if (status == 'delivered' || status == 'processing') _phone.clear();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Unable to buy data: $e')));
    } finally { if (mounted) setState(() => _buying = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _navy, foregroundColor: Colors.white,
        title: const Text('Buy Data', style: TextStyle(fontWeight: FontWeight.w900)),
        actions: [IconButton(tooltip: 'History', onPressed: () => Navigator.pushNamed(context, '/transactions'), icon: const Icon(Icons.history_rounded))],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 30),
          children: [
            const Text('Top up data on any network', style: TextStyle(color: Colors.black54, fontSize: 15)),
            const SizedBox(height: 5),
            const Text('Buy Data', style: TextStyle(color: _navy, fontSize: 27, fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            const Text('Top up data bundles on any Nigerian network in seconds.', style: TextStyle(color: Colors.black54)),
            const SizedBox(height: 20),
            _sectionLabel('Phone Number'),
            TextFormField(
              controller: _phone, keyboardType: TextInputType.phone,
              decoration: InputDecoration(hintText: '08012345678', prefixIcon: const Icon(Icons.phone_rounded), suffixIcon: _beneficiaries.isEmpty ? null : IconButton(tooltip: 'Beneficiaries', icon: const Icon(Icons.contacts_rounded), onPressed: _showBeneficiaries)),
              validator: (v) => (v == null || v.replaceAll(RegExp(r'\D'), '').length < 10) ? 'Enter a valid phone number' : null,
            ),
            Align(alignment: Alignment.centerRight, child: TextButton.icon(onPressed: _beneficiaries.isEmpty ? null : _showBeneficiaries, icon: const Icon(Icons.people_alt_outlined), label: const Text('Beneficiaries'))),
            const SizedBox(height: 5),
            _sectionLabel('SELECT NETWORK'),
            const SizedBox(height: 9),
            _networkSelector(),
            const SizedBox(height: 20),
            _sectionLabel('Data Bundle'),
            const SizedBox(height: 9),
            if (_loadingPlans) const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
            else if (_plans.isEmpty) const Text('No plans available. Check provider configuration.', style: TextStyle(color: Colors.red))
            else _planList(),
            const SizedBox(height: 10),
            CheckboxListTile(value: _saveBeneficiary, onChanged: (v) => setState(() => _saveBeneficiary = v ?? false), contentPadding: EdgeInsets.zero, activeColor: _gold, title: const Text('Save as Beneficiary', style: TextStyle(fontWeight: FontWeight.w800)), subtitle: const Text('Quickly reuse this number next time.')),
            const SizedBox(height: 8),
            _ussdCard(),
            const SizedBox(height: 18),
            SizedBox(height: 54, child: FilledButton(onPressed: _buying || _loadingPlans || _selected == null ? null : _submit, style: FilledButton.styleFrom(backgroundColor: _navy, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), child: Text(_buying ? 'Processing...' : 'Buy Data', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)))),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Colors.black54, letterSpacing: .4));

  Widget _networkSelector() {
    const networks = ['MTN', 'Glo', 'Airtel', 'T2'];
    return SizedBox(
      height: 88,
      child: ListView.separated(
        scrollDirection: Axis.horizontal, itemCount: networks.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final n = networks[i], selected = n == _network;
          return InkWell(
            onTap: () { if (_network != n) { setState(() => _network = n); _loadPlans(); } },
            borderRadius: BorderRadius.circular(17),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180), width: 78, padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(color: selected ? const Color(0xFFFFF7D6) : Colors.white, borderRadius: BorderRadius.circular(17), border: Border.all(color: selected ? _gold : const Color(0xFFE5E5EA), width: selected ? 2 : 1)),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [NetworkLogo(network: n, size: 40), const SizedBox(height: 4), Text(n, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800))]),
            ),
          );
        },
      ),
    );
  }

  Widget _planList() => Wrap(spacing: 9, runSpacing: 9, children: _plans.take(12).map((p) {
    final selected = identical(p, _selected);
    return InkWell(
      onTap: () => setState(() => _selected = p), borderRadius: BorderRadius.circular(15),
      child: Container(width: 104, padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 12), decoration: BoxDecoration(color: selected ? const Color(0xFFFFF7D6) : Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: selected ? _gold : const Color(0xFFE5E5EA), width: selected ? 2 : 1)),
      child: Column(children: [Text('₦${p['amount']}', style: const TextStyle(color: _navy, fontSize: 16, fontWeight: FontWeight.w900)), const SizedBox(height: 3), Text(p['name'].toString(), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700))]),
      ),
    );
  }).toList());

  Widget _ussdCard() => InkWell(
    onTap: () => Navigator.pushNamed(context, '/ussd'), borderRadius: BorderRadius.circular(18),
    child: Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: _gold.withOpacity(.35))), child: const Row(children: [Icon(Icons.dialpad_rounded, color: _gold, size: 30), SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('USSD Enquiry', style: TextStyle(color: _navy, fontWeight: FontWeight.w900, fontSize: 16)), SizedBox(height: 3), Text('Check data balance and more', style: TextStyle(color: Colors.black54, fontSize: 12))])), Icon(Icons.chevron_right_rounded, color: _navy)])),
  );

  void _showBeneficiaries() {
    showModalBottomSheet<void>(context: context, showDragHandle: true, builder: (_) => SafeArea(child: ListView(padding: const EdgeInsets.all(18), children: [const Text('Beneficiaries', style: TextStyle(color: _navy, fontSize: 21, fontWeight: FontWeight.w900)), const SizedBox(height: 10), ..._beneficiaries.map((n) => ListTile(leading: const Icon(Icons.person_outline, color: _navy), title: Text(n, style: const TextStyle(fontWeight: FontWeight.w800)), trailing: const Icon(Icons.arrow_forward_ios, size: 15), onTap: () { Navigator.pop(context); setState(() => _phone.text = n); }))])));
  }
}
