import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/wallet_service.dart';

const _navy = Color(0xFF061B49);
const _navy2 = Color(0xFF0A2C68);
const _gold = Color(0xFFC89B3C);
const _goldLight = Color(0xFFE7C66A);
const _bg = Color(0xFFF5F7FB);

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});
  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  late Future<double> _balanceFuture;
  late Future<List<Map<String, dynamic>>> _accountsFuture;
  int _method = 0;
  final _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _balanceFuture = WalletService.getBalance();
    _accountsFuture = WalletService.getFundingAccounts();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    setState(() {
      _balanceFuture = WalletService.getBalance();
      _accountsFuture = WalletService.getFundingAccounts();
    });
    await Future.wait([_balanceFuture, _accountsFuture]);
  }

  @override
  Widget build(BuildContext context) {
    final name = WalletService.currentUser?.userMetadata?['full_name']?.toString().trim();
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _navy,
        foregroundColor: Colors.white,
        title: const Text('Fund Wallet', style: TextStyle(fontWeight: FontWeight.w900)),
        actions: [IconButton(onPressed: _refresh, icon: const Icon(Icons.refresh))],
      ),
      body: RefreshIndicator(
        color: _gold,
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 30),
          children: [
            FutureBuilder<double>(future: _balanceFuture, builder: (_, snap) {
              final balance = snap.data ?? 0;
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(gradient: const LinearGradient(colors: [_navy2, _navy]), borderRadius: BorderRadius.circular(24)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Wallet Balance', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 5),
                  Text('₦${balance.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900)),
                  if (name?.isNotEmpty == true) ...[const SizedBox(height: 4), Text(name!, style: const TextStyle(color: _goldLight, fontWeight: FontWeight.w700))],
                ]),
              );
            }),
            const SizedBox(height: 18),
            const Text('Choose how you want to add money.', style: TextStyle(color: _navy, fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _methodCard(0, Icons.account_balance, 'Bank Transfer', 'Your funding accounts')),
              const SizedBox(width: 10),
              Expanded(child: _methodCard(1, Icons.bolt, 'Dynamic Funding', 'One-time account')),
            ]),
            const SizedBox(height: 10),
            _cryptoCard(),
            const SizedBox(height: 18),
            if (_method == 0) _bankTransferSection() else _dynamicSection(),
          ],
        ),
      ),
    );
  }

  Widget _methodCard(int index, IconData icon, String title, String subtitle) {
    final active = _method == index;
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () => setState(() => _method = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(17),
        height: 124,
        decoration: BoxDecoration(color: active ? _goldLight : Colors.white, borderRadius: BorderRadius.circular(22), border: Border.all(color: active ? _gold : Colors.black12)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, color: active ? _navy : _navy2, size: 28), const Spacer(), Text(title, style: const TextStyle(color: _navy, fontSize: 16, fontWeight: FontWeight.w900)), Text(subtitle, style: const TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.w600))]),
      ),
    );
  }

  Widget _cryptoCard() => InkWell(
    borderRadius: BorderRadius.circular(20),
    onTap: () => Navigator.pushNamed(context, '/fund-crypto'),
    child: Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: _gold.withOpacity(.35))),
      child: const Row(children: [CircleAvatar(backgroundColor: Color(0xFFF0F2F7), child: Icon(Icons.currency_bitcoin, color: _navy)), SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Fund with Crypto', style: TextStyle(color: _navy, fontSize: 16, fontWeight: FontWeight.w900)), SizedBox(height: 3), Text('Deposit USDT, BTC, ETH and more — auto-converted to Naira', style: TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.w600))])), Icon(Icons.chevron_right, color: _navy)]),
    ),
  );

  Widget _bankTransferSection() => FutureBuilder<List<Map<String, dynamic>>>(
    future: _accountsFuture,
    builder: (context, snap) {
      if (snap.connectionState == ConnectionState.waiting) return const Center(child: Padding(padding: EdgeInsets.all(30), child: CircularProgressIndicator(color: _gold)));
      if (snap.hasError) return _notice(Icons.error_outline, 'Unable to load funding accounts. Pull down to retry.');
      final accounts = snap.data ?? [];
      if (accounts.isEmpty) return _emptyAccounts();
      return Container(
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
        child: Column(children: [
          const Text('Copy any of the account numbers below and fund your wallet.', textAlign: TextAlign.center, style: TextStyle(color: _navy, fontSize: 17, fontWeight: FontWeight.w800, height: 1.3)),
          const SizedBox(height: 18),
          ...List.generate(accounts.length, (i) => _accountCard(accounts[i], i + 1)),
        ]),
      );
    },
  );

  Widget _accountCard(Map<String, dynamic> account, int number) {
    final bank = account['bank_name']?.toString() ?? '';
    final accountNumber = account['account_number']?.toString() ?? '';
    final accountName = account['account_name']?.toString() ?? '';
    final charges = account['charges']?.toString();
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.black12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(child: Text(account['label']?.toString().isNotEmpty == true ? account['label'].toString() : 'Account $number', style: const TextStyle(color: _navy, fontSize: 16, fontWeight: FontWeight.w900))),
        const SizedBox(height: 14),
        _detail('Bank Name', bank),
        _detail('Account Number', accountNumber),
        _detail('Account Name', accountName),
        if (charges?.isNotEmpty == true) _detail('Charges', charges!),
        const SizedBox(height: 12),
        SizedBox(width: double.infinity, child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(backgroundColor: _navy, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 13)),
          onPressed: accountNumber.isEmpty ? null : () => _copy(accountNumber, 'Account number copied'),
          icon: const Icon(Icons.copy), label: Text('Copy Account Number $number'),
        )),
      ]),
    );
  }

  Widget _detail(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: Text(label, style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w700))), const SizedBox(width: 12), Flexible(child: Text(value, textAlign: TextAlign.right, style: const TextStyle(color: _navy, fontWeight: FontWeight.w900)))]),
  );

  Widget _emptyAccounts() => Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
    child: const Column(children: [Icon(Icons.account_balance_outlined, color: _gold, size: 48), SizedBox(height: 10), Text('No funding account is connected yet.', textAlign: TextAlign.center, style: TextStyle(color: _navy, fontSize: 18, fontWeight: FontWeight.w900)), SizedBox(height: 7), Text('We will show the real bank name, account number and account name here after a virtual-account provider is connected. No fake account number is used.', textAlign: TextAlign.center, style: TextStyle(color: Colors.black54, height: 1.35))]),
  );

  Widget _dynamicSection() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [CircleAvatar(backgroundColor: Color(0xFFFFF3D0), child: Icon(Icons.bolt, color: _gold)), SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('One-time virtual account', style: TextStyle(color: _navy, fontSize: 17, fontWeight: FontWeight.w900)), Text('Generate a temporary account for a specific amount.', style: TextStyle(color: Colors.black54, fontSize: 12))]))]),
        const SizedBox(height: 20),
        const Text('Amount to fund', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w700)),
        const SizedBox(height: 7),
        TextField(controller: _amountController, keyboardType: TextInputType.number, decoration: const InputDecoration(prefixText: '₦ ', hintText: '0', border: OutlineInputBorder())),
        const SizedBox(height: 10),
        Wrap(spacing: 8, runSpacing: 8, children: [1000, 2000, 5000, 10000].map((a) => OutlinedButton(onPressed: () => _amountController.text = a.toString(), child: Text('₦${a.toString()}'))).toList()),
        const SizedBox(height: 14),
        Container(padding: const EdgeInsets.all(13), decoration: BoxDecoration(color: const Color(0xFFFFF8DF), borderRadius: BorderRadius.circular(14)), child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(Icons.info_outline, color: _gold), SizedBox(width: 9), Expanded(child: Text('The account is temporary. Transfer the exact amount before it expires.'))])),
        const SizedBox(height: 16),
        SizedBox(width: double.infinity, child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: _goldLight, foregroundColor: _navy, padding: const EdgeInsets.symmetric(vertical: 15)), onPressed: _generateDynamic, icon: const Icon(Icons.bolt), label: const Text('Generate Account', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)))),
      ]),
    ),
  ]);

  void _generateDynamic() {
    final amount = double.tryParse(_amountController.text.trim()) ?? 0;
    if (amount < 100) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter at least ₦100.')));
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dynamic funding provider is not connected yet. No account was generated.')));
  }

  Widget _notice(IconData icon, String text) => Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), child: Row(children: [Icon(icon, color: _gold), const SizedBox(width: 10), Expanded(child: Text(text, style: const TextStyle(color: _navy, fontWeight: FontWeight.w700)))]));

  void _copy(String value, String message) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
