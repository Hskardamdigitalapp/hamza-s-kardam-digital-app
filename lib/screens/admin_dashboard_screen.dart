import 'package:flutter/material.dart';
import '../services/wallet_service.dart';

const _navy = Color(0xFF061B49);
const _gold = Color(0xFFC89B3C);
const _goldLight = Color(0xFFE7C66A);

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});
  @override State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  late Future<List<Map<String, dynamic>>> _statsFuture;
  @override void initState() { super.initState(); _statsFuture = WalletService.getAdminStats(); }
  Future<void> _refresh() async { setState(() => _statsFuture = WalletService.getAdminStats()); await _statsFuture; }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Admin Dashboard'), backgroundColor: _navy, foregroundColor: Colors.white, actions: [IconButton(onPressed: _refresh, icon: const Icon(Icons.refresh))]),
    body: FutureBuilder<List<Map<String, dynamic>>>(future: _statsFuture, builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: _gold));
      if (snapshot.hasError) return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.lock_outline, size: 48, color: _navy), const SizedBox(height: 12), Text(snapshot.error.toString().replaceFirst('Exception: ', '')), const SizedBox(height: 12), ElevatedButton(onPressed: _refresh, child: const Text('Retry'))]));
      final data = snapshot.data ?? [];
      final profiles = _find(data, 'profiles');
      final transactions = _find(data, 'transactions');
      final dataOrders = _find(data, 'data_orders');
      final airtimeOrders = _find(data, 'airtime_orders');
      final wallets = _find(data, 'wallets');
      final cashRequests = _find(data, 'airtime_cash_requests');
      final pending = [...transactions, ...dataOrders, ...airtimeOrders, ...cashRequests].where((r) => r['status']?.toString().toLowerCase() == 'pending').length;
      final pendingKyc = profiles.where((p) => p['kyc_status']?.toString() == 'pending').toList();
      return RefreshIndicator(color: _gold, onRefresh: _refresh, child: ListView(padding: const EdgeInsets.all(16), children: [
        const Text('Overview', style: TextStyle(color: _navy, fontSize: 22, fontWeight: FontWeight.w900)), const SizedBox(height: 14),
        GridView.count(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.55, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), children: [_card('Users', profiles.length.toString(), Icons.people_outline), _card('Wallets', wallets.length.toString(), Icons.account_balance_wallet_outlined), _card('Transactions', transactions.length.toString(), Icons.receipt_long_outlined), _card('Pending', pending.toString(), Icons.pending_actions_outlined)]),
        const SizedBox(height: 24), const Text('KYC Verification Queue', style: TextStyle(color: _navy, fontSize: 20, fontWeight: FontWeight.w900)), const SizedBox(height: 8),
        if (pendingKyc.isEmpty) const Card(child: Padding(padding: EdgeInsets.all(18), child: Text('No KYC verification requests pending.'))) else ...pendingKyc.map(_kycCard),
        const SizedBox(height: 24), const Text('Airtime to Cash Queue', style: TextStyle(color: _navy, fontSize: 20, fontWeight: FontWeight.w900)), const SizedBox(height: 8),
        if (cashRequests.isEmpty) const Card(child: Padding(padding: EdgeInsets.all(18), child: Text('No airtime-to-cash requests yet.'))) else ...cashRequests.map(_cashRequestCard),
        const SizedBox(height: 24), const Text('Recent Activity', style: TextStyle(color: _navy, fontSize: 20, fontWeight: FontWeight.w900)), const SizedBox(height: 8),
        if (transactions.isEmpty) const Card(child: Padding(padding: EdgeInsets.all(18), child: Text('No transactions yet.'))) else ...transactions.take(20).map((row) => Card(child: ListTile(leading: const CircleAvatar(backgroundColor: _goldLight, child: Icon(Icons.receipt_long, color: _navy)), title: Text(row['service']?.toString() ?? row['type']?.toString() ?? 'Transaction'), subtitle: Text('${row['status'] ?? 'pending'} • ${row['created_at'] ?? ''}'), trailing: Text('₦${row['amount'] ?? 0}', style: const TextStyle(color: _navy, fontWeight: FontWeight.bold))))),
      ]));
    }),
  );

  Widget _kycCard(Map<String,dynamic> row) {
    final method = row['kyc_method']?.toString().toUpperCase() ?? 'N/A';
    return Card(margin: const EdgeInsets.only(bottom: 10), child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(row['full_name']?.toString().isNotEmpty == true ? row['full_name'].toString() : 'Customer', style: const TextStyle(color: _navy, fontWeight: FontWeight.w900, fontSize: 16)),
      Text('${row['email'] ?? ''} • ${row['phone'] ?? ''}'),
      Text('Verification method: $method • Requested Tier ${row['kyc_tier'] ?? 1}'),
      const Text('Identity number hidden for security.', style: TextStyle(color: Colors.black54, fontSize: 12)),
      const SizedBox(height: 10),
      Wrap(spacing: 8, runSpacing: 8, children: [OutlinedButton.icon(onPressed: () => _reviewKyc(row, 'verified', 2), icon: const Icon(Icons.verified), label: const Text('Approve Tier 2')), OutlinedButton.icon(onPressed: () => _reviewKyc(row, 'verified', 3), icon: const Icon(Icons.workspace_premium), label: const Text('Approve Tier 3')), OutlinedButton.icon(onPressed: () => _reviewKyc(row, 'rejected', 1), icon: const Icon(Icons.close), label: const Text('Reject'))]),
    ])));
  }

  Future<void> _reviewKyc(Map<String,dynamic> row, String status, int tier) async {
    try { await WalletService.reviewKyc(userId: row['id'].toString(), status: status, tier: tier); if (!mounted) return; ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(status == 'verified' ? 'KYC approved: Tier $tier.' : 'KYC rejected.'))); await _refresh(); }
    catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')))); }
  }

  Widget _cashRequestCard(Map<String,dynamic> row) {
    final status = row['status']?.toString() ?? 'pending';
    return Card(margin: const EdgeInsets.only(bottom: 10), child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Expanded(child: Text('${row['network'] ?? ''} • ₦${row['amount'] ?? 0}', style: const TextStyle(color: _navy, fontWeight: FontWeight.w900, fontSize: 16))), _statusChip(status)]), const SizedBox(height: 8),
      Text('Phone: ${row['phone'] ?? ''}'), Text('Bank: ${row['payout_bank'] ?? ''}'), Text('Account: ${row['account_number'] ?? ''} • ${row['account_name'] ?? ''}'), Text('Ref: ${row['reference'] ?? ''}', style: const TextStyle(fontSize: 12, color: Colors.black54)), const SizedBox(height: 10),
      Wrap(spacing: 8, runSpacing: 8, children: [_statusButton(row, 'processing', Icons.play_arrow, 'Process'), _statusButton(row, 'completed', Icons.check, 'Complete'), _statusButton(row, 'rejected', Icons.close, 'Reject'), if (status != 'pending') _statusButton(row, 'pending', Icons.undo, 'Pending')]),
    ])));
  }
  Widget _statusButton(Map<String,dynamic> row,String status,IconData icon,String label) => OutlinedButton.icon(onPressed: row['status']?.toString()==status ? null : () => _changeStatus(row,status), icon: Icon(icon,size:16), label: Text(label));
  Widget _statusChip(String status) => Container(padding: const EdgeInsets.symmetric(horizontal:9,vertical:5), decoration: BoxDecoration(color:_goldLight.withOpacity(.55),borderRadius:BorderRadius.circular(12)), child: Text(status.toUpperCase(),style:const TextStyle(color:_navy,fontWeight:FontWeight.w900,fontSize:11)));
  Future<void> _changeStatus(Map<String,dynamic> row,String status) async { try { await WalletService.updateAirtimeCashRequestStatus(id:row['id'].toString(),status:status); if(!mounted)return; ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('Request moved to $status.'))); await _refresh(); } catch(e) { if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(e.toString().replaceFirst('Exception: ','')))); } }
  List<Map<String,dynamic>> _find(List<Map<String,dynamic>> data,String key){ for(final item in data){final value=item[key];if(value is List)return List<Map<String,dynamic>>.from(value);}return []; }
  Widget _card(String title,String value,IconData icon)=>Card(child:Padding(padding:const EdgeInsets.all(14),child:Row(children:[Icon(icon,size:30,color:_gold),const SizedBox(width:10),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,mainAxisAlignment:MainAxisAlignment.center,children:[Text(value,style:const TextStyle(color:_navy,fontSize:22,fontWeight:FontWeight.w900)),Text(title)]))])));
}
