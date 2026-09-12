import 'package:flutter/material.dart';
import '../services/wallet_service.dart';

const _navy = Color(0xFF061B49);
const _navy2 = Color(0xFF0A2C68);
const _gold = Color(0xFFC89B3C);
const _bg = Color(0xFFF5F7FB);

class TransferToBankScreen extends StatefulWidget {
  const TransferToBankScreen({super.key});
  @override State<TransferToBankScreen> createState() => _TransferToBankScreenState();
}

class _TransferToBankScreenState extends State<TransferToBankScreen> {
  List<Map<String, dynamic>> _banks = [];
  Map<String, dynamic>? _bank;
  final _accountController = TextEditingController();
  final _amountController = TextEditingController();
  String _accountName = '';
  bool _loadingBanks = true;
  bool _verifying = false;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _loadBanks();
    _accountController.addListener(() {
      if (_accountName.isNotEmpty) setState(() => _accountName = '');
    });
  }

  @override
  void dispose() {
    _accountController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _loadBanks() async {
    try {
      final banks = await WalletService.getBanks();
      if (mounted) setState(() { _banks = banks; _loadingBanks = false; });
    } catch (e) {
      if (mounted) {
        setState(() => _loadingBanks = false);
        _showError(e.toString());
      }
    }
  }

  Future<void> _verify() async {
    final bank = _bank;
    final account = _accountController.text.replaceAll(RegExp(r'\D'), '');
    if (bank == null) return _showError('Please select a bank.');
    if (account.length != 10) return _showError('Account number must be 10 digits.');
    setState(() => _verifying = true);
    try {
      final result = await WalletService.resolveBankAccount(bankCode: bank['code'].toString(), accountNumber: account);
      if (mounted) setState(() => _accountName = result['account_name'].toString());
    } catch (e) {
      if (mounted) _showError(e.toString());
    } finally {
      if (mounted) setState(() => _verifying = false);
    }
  }

  Future<void> _send() async {
    final bank = _bank;
    final amount = double.tryParse(_amountController.text.replaceAll(',', '').trim());
    if (bank == null || _accountName.isEmpty || amount == null || amount < 100) {
      _showError('Select a bank, verify the account and enter at least ₦100.');
      return;
    }
    final balance = await WalletService.getBalance();
    if (amount > balance) return _showError('Insufficient wallet balance.');

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Bank Transfer', style: TextStyle(color: _navy, fontWeight: FontWeight.w900)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _summary('Bank', bank['name'].toString()),
            _summary('Account', _accountController.text),
            _summary('Name', _accountName),
            _summary('Amount', '₦${amount.toStringAsFixed(2)}'),
            const SizedBox(height: 10),
            const Text('The wallet will be debited when the transfer is submitted. If the provider later fails the transfer, the app will automatically refund the wallet.', style: TextStyle(fontSize: 12, color: Colors.black54)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Confirm & Send')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _sending = true);
    try {
      final result = await WalletService.transferToBank(
        bankCode: bank['code'].toString(),
        bankName: bank['name'].toString(),
        accountNumber: _accountController.text.replaceAll(RegExp(r'\D'), ''),
        accountName: _accountName,
        amount: amount,
      );
      if (!mounted) return;
      final status = result['status']?.toString() ?? 'processing';
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          icon: Icon(status == 'successful' ? Icons.check_circle : Icons.schedule, color: _gold, size: 48),
          title: Text(status == 'successful' ? 'Transfer Successful' : 'Transfer Processing', style: const TextStyle(color: _navy, fontWeight: FontWeight.w900)),
          content: Text(status == 'successful' ? '₦${amount.toStringAsFixed(2)} has been sent to $_accountName.' : 'Your transfer has been submitted. Reference: ${result['reference'] ?? 'pending'}. We will update the transaction when the bank/provider confirms the final status.'),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Done'))],
        ),
      );
      if (mounted) {
        _amountController.clear();
        setState(() { _accountController.clear(); _accountName = ''; });
      }
    } catch (e) {
      if (mounted) _showError(e.toString());
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Widget _summary(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [SizedBox(width: 72, child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.w700))), Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w800, color: _navy)))])
  );

  void _showError(String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message.replaceFirst('Exception: ', ''))));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(title: const Text('Transfer to Bank'), backgroundColor: _navy, foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(gradient: const LinearGradient(colors: [_navy2, _navy]), borderRadius: BorderRadius.circular(22), border: Border.all(color: _gold, width: 1.2)),
            child: const Row(children: [Icon(Icons.account_balance, color: _gold, size: 34), SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Send money securely', style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w900)), SizedBox(height: 3), Text('Verify the recipient first, then send from your Kardam wallet.', style: TextStyle(color: Colors.white70, fontSize: 12))]))]),
          ),
          const SizedBox(height: 18),
          const Text('Select Bank', style: TextStyle(color: _navy, fontWeight: FontWeight.w900)),
          const SizedBox(height: 7),
          DropdownButtonFormField<Map<String, dynamic>>(
            value: _bank,
            isExpanded: true,
            decoration: const InputDecoration(prefixIcon: Icon(Icons.account_balance_outlined), border: OutlineInputBorder()),
            hint: Text(_loadingBanks ? 'Loading banks…' : 'Choose bank'),
            items: _banks.map((bank) => DropdownMenuItem(value: bank, child: Text(bank['name'].toString(), overflow: TextOverflow.ellipsis))).toList(),
            onChanged: _loadingBanks ? null : (value) => setState(() { _bank = value; _accountName = ''; }),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: _accountController,
            keyboardType: TextInputType.number,
            maxLength: 10,
            decoration: InputDecoration(labelText: 'Account number', prefixIcon: const Icon(Icons.numbers), suffixIcon: _verifying ? const Padding(padding: EdgeInsets.all(12), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: _gold))) : IconButton(onPressed: _verify, icon: const Icon(Icons.verified_outlined, color: _gold)), counterText: ''),
          ),
          if (_accountName.isNotEmpty) ...[
            const SizedBox(height: 6),
            Container(width: double.infinity, padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: _gold)), child: Row(children: [const Icon(Icons.verified, color: _gold), const SizedBox(width: 9), Expanded(child: Text(_accountName, style: const TextStyle(color: _navy, fontSize: 16, fontWeight: FontWeight.w900)))])),
          ],
          const SizedBox(height: 15),
          TextField(controller: _amountController, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Amount', prefixText: '₦ ', prefixIcon: Icon(Icons.payments_outlined), border: OutlineInputBorder())),
          const SizedBox(height: 8),
          const Text('Minimum transfer: ₦100. Provider fees, if applicable, are handled by the transfer backend.', style: TextStyle(color: Colors.black54, fontSize: 12)),
          const SizedBox(height: 22),
          SizedBox(width: double.infinity, height: 54, child: FilledButton.icon(onPressed: _sending ? null : _send, icon: _sending ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.send), label: Text(_sending ? 'Submitting…' : 'Confirm & Send'))),
          const SizedBox(height: 18),
          const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(Icons.security_outlined, color: _navy, size: 20), SizedBox(width: 8), Expanded(child: Text('Account details are verified on the server before submission. The wallet is reserved atomically, and failed transfers are automatically refunded after provider confirmation.', style: TextStyle(color: _navy, fontSize: 12, height: 1.35)))]),
        ]),
      ),
    );
  }
}
