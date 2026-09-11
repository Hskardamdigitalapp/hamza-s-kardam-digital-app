import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

class WalletService {
  static final _client = Supabase.instance.client;
  static User? get currentUser => _client.auth.currentUser;
  static Future<void> logout() => _client.auth.signOut();

  static Future<bool> isAdmin() async {
    if (currentUser == null) return false;
    try { return await _client.rpc('is_admin') == true; } catch (_) { return false; }
  }

  static Future<double> getBalance() async {
    final user = currentUser;
    if (user == null) return 0;
    final row = await _client.from('wallets').select('balance').eq('user_id', user.id).maybeSingle();
    return row == null ? 0 : (double.tryParse(row['balance'].toString()) ?? 0);
  }

  static Future<Map<String, dynamic>?> getProfile() async {
    final user = currentUser;
    if (user == null) return null;
    return await _client.from('profiles').select().eq('id', user.id).maybeSingle();
  }

  static String? get avatarUrl => currentUser?.userMetadata?['avatar_url']?.toString();

  static Future<String> uploadAvatar(Uint8List bytes) async {
    final user = currentUser;
    if (user == null) throw Exception('Please sign in again.');
    final path = '${user.id}/avatar.jpg';
    await _client.storage.from('avatars').uploadBinary(path, bytes, fileOptions: const FileOptions(contentType: 'image/jpeg', upsert: true));
    final url = _client.storage.from('avatars').getPublicUrl(path);
    await _client.auth.updateUser(UserAttributes(data: {'avatar_url': url}));
    return url;
  }

  static Future<List<Map<String, dynamic>>> getFundingAccounts() async {
    if (currentUser == null) return [];
    final rows = await _client
        .from('wallet_funding_accounts')
        .select('id,label,provider,bank_name,account_number,account_name,charges,currency,is_active,metadata,provider_reference,expires_at')
        .eq('is_active', true)
        .or('user_id.is.null,user_id.eq.${currentUser!.id}')
        .order('created_at');
    return List<Map<String, dynamic>>.from(rows);
  }

  static Future<Map<String, dynamic>> createDynamicFunding(double amount) async {
    final user = currentUser;
    if (user == null) throw Exception('Please sign in again.');
    if (amount < 100) throw Exception('Minimum funding amount is ₦100.');
    final response = await _client.functions.invoke('create-dynamic-funding', body: {'amount': amount});
    final data = response.data;
    if (data is Map && data['error'] != null) throw Exception(data['error'].toString());
    if (data is! Map || data['account'] is! Map) throw Exception('Unable to generate a funding account.');
    return Map<String, dynamic>.from(data['account'] as Map);
  }

  static Future<List<Map<String, dynamic>>> getDeposits({int limit = 50}) async {
    final user = currentUser;
    if (user == null) return [];
    final rows = await _client.from('wallet_deposits').select().eq('user_id', user.id).order('created_at', ascending: false).limit(limit);
    return List<Map<String, dynamic>>.from(rows);
  }

  static Future<List<Map<String, dynamic>>> getTransactions({int limit = 50}) async {
    final user = currentUser;
    if (user == null) return [];
    final rows = await _client.from('transactions').select().eq('user_id', user.id).order('created_at', ascending: false).limit(limit);
    return List<Map<String, dynamic>>.from(rows);
  }

  static Future<List<Map<String, dynamic>>> getDataOrders({int limit = 50}) async {
    final user = currentUser;
    if (user == null) return [];
    final rows = await _client.from('data_orders').select().eq('user_id', user.id).order('created_at', ascending: false).limit(limit);
    return List<Map<String, dynamic>>.from(rows);
  }

  static Future<List<Map<String, dynamic>>> getAirtimeOrders({int limit = 50}) async {
    final user = currentUser;
    if (user == null) return [];
    final rows = await _client.from('airtime_orders').select().eq('user_id', user.id).order('created_at', ascending: false).limit(limit);
    return List<Map<String, dynamic>>.from(rows);
  }

  static Future<List<Map<String, dynamic>>> getAdminStats() async {
    if (!await isAdmin()) throw Exception('Admin access required.');
    final profiles = await _client.from('profiles').select('id,role');
    final transactions = await _client.from('transactions').select('id,status,amount,service,created_at').order('created_at', ascending: false).limit(100);
    final dataOrders = await _client.from('data_orders').select('id,status,amount,network,phone,plan,created_at').order('created_at', ascending: false).limit(100);
    final airtimeOrders = await _client.from('airtime_orders').select('id,status,amount,network,phone,created_at').order('created_at', ascending: false).limit(100);
    final wallets = await _client.from('wallets').select('id,balance');
    return [{'profiles': List<Map<String, dynamic>>.from(profiles)}, {'transactions': List<Map<String, dynamic>>.from(transactions)}, {'data_orders': List<Map<String, dynamic>>.from(dataOrders)}, {'airtime_orders': List<Map<String, dynamic>>.from(airtimeOrders)}, {'wallets': List<Map<String, dynamic>>.from(wallets)}];
  }

  static Future<void> createAirtimeOrder({required String network, required String phone, required double amount}) async {
    if (currentUser == null) throw Exception('Please sign in again.');
    if (amount < 50) throw Exception('Minimum airtime amount is ₦50.');
    await _client.rpc('create_airtime_order', params: {'p_network': network, 'p_phone': phone, 'p_amount': amount, 'p_reference': 'AIR-${DateTime.now().microsecondsSinceEpoch}'});
  }

  static Future<void> createDataOrder({required String network, required String phone, required String plan, required double amount}) async {
    if (currentUser == null) throw Exception('Please sign in again.');
    if (amount <= 0) throw Exception('Enter a valid amount.');
    await _client.rpc('create_data_order', params: {'p_network': network, 'p_phone': phone, 'p_plan': plan, 'p_amount': amount, 'p_reference': 'DATA-${DateTime.now().microsecondsSinceEpoch}'});
  }

  static Future<void> createAirtimeCashRequest({required String network, required String phone, required double amount, required String payoutBank, required String accountNumber, required String accountName}) async {
    if (currentUser == null) throw Exception('Please sign in again.');
    if (amount < 100) throw Exception('Minimum airtime to cash amount is ₦100.');
    await _client.rpc('create_airtime_cash_request', params: {'p_network': network, 'p_phone': phone, 'p_amount': amount, 'p_payout_bank': payoutBank, 'p_account_number': accountNumber, 'p_account_name': accountName, 'p_reference': 'ATC-${DateTime.now().microsecondsSinceEpoch}'});
  }
}
