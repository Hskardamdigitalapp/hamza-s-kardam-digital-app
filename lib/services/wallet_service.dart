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
    final user = currentUser; if (user == null) return 0;
    final row = await _client.from('wallets').select('balance').eq('user_id', user.id).maybeSingle();
    return row == null ? 0 : (double.tryParse(row['balance'].toString()) ?? 0);
  }

  static Future<Map<String, dynamic>?> getProfile() async {
    final user = currentUser; if (user == null) return null;
    return await _client.from('profiles').select().eq('id', user.id).maybeSingle();
  }

  static String? get avatarUrl => currentUser?.userMetadata?['avatar_url']?.toString();

  static Future<String> uploadAvatar(Uint8List bytes) async {
    final user = currentUser; if (user == null) throw Exception('Please sign in again.');
    final path = '${user.id}/avatar.jpg';
    await _client.storage.from('avatars').uploadBinary(path, bytes, fileOptions: const FileOptions(contentType: 'image/jpeg', upsert: true));
    final url = _client.storage.from('avatars').getPublicUrl(path);
    await _client.auth.updateUser(UserAttributes(data: {'avatar_url': url}));
    return url;
  }

  static Future<Map<String, dynamic>> getMyKycStatus() async {
    final user = currentUser; if (user == null) throw Exception('Please sign in again.');
    final result = await _client.rpc('get_my_kyc_status');
    if (result is Map) return Map<String, dynamic>.from(result);
    return {'tier': 1, 'status': 'unverified'};
  }

  static Future<Map<String, dynamic>> requestKycUpgrade({required String method, required String reference, required int targetTier}) async {
    if (currentUser == null) throw Exception('Please sign in again.');
    if (method != 'NIN' && method != 'BVN') throw Exception('Choose NIN or BVN.');
    if (!RegExp(r'^\d{11}$').hasMatch(reference.trim())) throw Exception('$method must be 11 digits.');
    final result = await _client.rpc('request_kyc_upgrade', params: {
      'p_method': method.toLowerCase(), 'p_reference': reference.trim(), 'p_target_tier': targetTier,
    });
    return result is Map ? Map<String, dynamic>.from(result) : {};
  }

  static Future<List<Map<String, dynamic>>> getFundingAccounts() async {
    if (currentUser == null) return [];
    final rows = await _client.from('wallet_funding_accounts').select('id,label,provider,bank_name,account_number,account_name,charges,currency,is_active,metadata,provider_reference,expires_at').eq('is_active', true).or('user_id.is.null,user_id.eq.${currentUser!.id}').order('created_at');
    return List<Map<String, dynamic>>.from(rows);
  }

  static Future<Map<String, dynamic>> createDynamicFunding(double amount) async {
    if (currentUser == null) throw Exception('Please sign in again.');
    if (amount < 100) throw Exception('Minimum funding amount is ₦100.');
    final response = await _client.functions.invoke('create-dynamic-funding', body: {'amount': amount});
    final data = response.data;
    if (data is Map && data['error'] != null) throw Exception(data['error'].toString());
    if (data is! Map || data['account'] is! Map) throw Exception('Unable to generate a funding account.');
    return Map<String, dynamic>.from(data['account'] as Map);
  }

  static Future<List<Map<String, dynamic>>> getDeposits({int limit = 50}) async {
    final user = currentUser; if (user == null) return [];
    final rows = await _client.from('wallet_deposits').select().eq('user_id', user.id).order('created_at', ascending: false).limit(limit);
    return List<Map<String, dynamic>>.from(rows);
  }

  static Future<List<Map<String, dynamic>>> getTransactions({int limit = 50}) async {
    final user = currentUser; if (user == null) return [];
    final rows = await _client.from('transactions').select().eq('user_id', user.id).order('created_at', ascending: false).limit(limit);
    return List<Map<String, dynamic>>.from(rows);
  }

  static Future<List<Map<String, dynamic>>> getDataOrders({int limit = 50}) async {
    final user = currentUser; if (user == null) return [];
    final rows = await _client.from('data_orders').select().eq('user_id', user.id).order('created_at', ascending: false).limit(limit);
    return List<Map<String, dynamic>>.from(rows);
  }

  static Future<List<Map<String, dynamic>>> getAirtimeOrders({int limit = 50}) async {
    final user = currentUser; if (user == null) return [];
    final rows = await _client.from('airtime_orders').select().eq('user_id', user.id).order('created_at', ascending: false).limit(limit);
    return List<Map<String, dynamic>>.from(rows);
  }

  static Future<List<Map<String, dynamic>>> getAirtimeCashRequests({int limit = 100}) async {
    if (!await isAdmin()) throw Exception('Admin access required.');
    final rows = await _client.from('airtime_cash_requests').select().order('created_at', ascending: false).limit(limit);
    return List<Map<String, dynamic>>.from(rows);
  }

  static Future<void> updateAirtimeCashRequestStatus({required String id, required String status}) async {
    if (!await isAdmin()) throw Exception('Admin access required.');
    await _client.rpc('admin_update_airtime_cash_request', params: {'p_request_id': id, 'p_status': status});
  }

  static Future<void> reviewKyc({required String userId, required String status, required int tier}) async {
    if (!await isAdmin()) throw Exception('Admin access required.');
    await _client.rpc('admin_review_kyc', params: {'p_user_id': userId, 'p_status': status, 'p_tier': tier});
  }

  static Future<List<Map<String, dynamic>>> getAdminStats() async {
    if (!await isAdmin()) throw Exception('Admin access required.');
    final profiles = await _client.from('profiles').select('id,full_name,email,phone,role,kyc_tier,kyc_status,kyc_method,kyc_reference_last4');
    final transactions = await _client.from('transactions').select('id,status,amount,service,created_at').order('created_at', ascending: false).limit(100);
    final dataOrders = await _client.from('data_orders').select('id,status,amount,network,phone,plan,created_at').order('created_at', ascending: false).limit(100);
    final airtimeOrders = await _client.from('airtime_orders').select('id,status,amount,network,phone,created_at').order('created_at', ascending: false).limit(100);
    final wallets = await _client.from('wallets').select('id,balance');
    final cashRequests = await _client.from('airtime_cash_requests').select('id,status,amount,network,phone,payout_bank,account_number,account_name,reference,created_at').order('created_at', ascending: false).limit(100);
    return [
      {'profiles': List<Map<String, dynamic>>.from(profiles)}, {'transactions': List<Map<String, dynamic>>.from(transactions)},
      {'data_orders': List<Map<String, dynamic>>.from(dataOrders)}, {'airtime_orders': List<Map<String, dynamic>>.from(airtimeOrders)},
      {'wallets': List<Map<String, dynamic>>.from(wallets)}, {'airtime_cash_requests': List<Map<String, dynamic>>.from(cashRequests)},
    ];
  }

  static Future<List<Map<String, dynamic>>> getBanks() async {
    final response = await _client.functions.invoke('bank-transfer', body: {'action': 'banks'});
    final data = response.data;
    if (data is Map && data['error'] != null) throw Exception(data['error'].toString());
    final banks = data is Map && data['banks'] is List ? data['banks'] as List : const [];
    return banks.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  static Future<Map<String, dynamic>> resolveBankAccount({required String bankCode, required String accountNumber}) async {
    final response = await _client.functions.invoke('bank-transfer', body: {'action': 'resolve', 'bank_code': bankCode, 'account_number': accountNumber});
    final data = response.data;
    if (data is Map && data['error'] != null) throw Exception(data['error'].toString());
    if (data is! Map || data['verified'] != true) throw Exception('Unable to verify bank account.');
    return Map<String, dynamic>.from(data);
  }

  static Future<Map<String, dynamic>> transferToBank({required String bankCode, required String bankName, required String accountNumber, required String accountName, required double amount}) async {
    if (currentUser == null) throw Exception('Please sign in again.');
    if (amount < 100) throw Exception('Minimum bank transfer is ₦100.');
    final response = await _client.functions.invoke('bank-transfer', body: {
      'action': 'transfer', 'bank_code': bankCode, 'bank_name': bankName, 'account_number': accountNumber, 'account_name': accountName, 'amount': amount,
    });
    final data = response.data;
    if (data is Map && data['error'] != null) throw Exception(data['error'].toString());
    return data is Map ? Map<String, dynamic>.from(data) : {};
  }

  static Future<void> createAirtimeOrder({required String network, required String phone, required double amount}) async {
    await buyAirtime(network: network, phone: phone, amount: amount);
  }

  static Future<Map<String, dynamic>> buyAirtime({required String network, required String phone, required double amount}) async {
    if (currentUser == null) throw Exception('Please sign in again.');
    if (amount < 50) throw Exception('Minimum airtime amount is ₦50.');
    final response = await _client.functions.invoke('vtpass-purchase', body: {'type': 'airtime', 'network': network, 'phone': phone, 'amount': amount});
    final data = response.data;
    if (data is Map && data['error'] != null) throw Exception(data['error'].toString());
    return data is Map ? Map<String, dynamic>.from(data) : {};
  }

  static Future<List<Map<String, dynamic>>> getDataPlans(String network) async {
    if (currentUser == null) throw Exception('Please sign in again.');
    final response = await _client.functions.invoke('vtpass-catalog', body: {'network': network});
    final data = response.data;
    if (data is Map && data['error'] != null) throw Exception(data['error'].toString());
    final plans = data is Map && data['plans'] is List ? data['plans'] as List : const [];
    return plans.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  static Future<Map<String, dynamic>> buyData({required String network, required String phone, required String plan, required String variationCode, required double amount}) async {
    if (currentUser == null) throw Exception('Please sign in again.');
    if (amount <= 0) throw Exception('Enter a valid amount.');
    final response = await _client.functions.invoke('vtpass-purchase', body: {'type': 'data', 'network': network, 'phone': phone, 'plan': plan, 'variation_code': variationCode, 'amount': amount});
    final data = response.data;
    if (data is Map && data['error'] != null) throw Exception(data['error'].toString());
    return data is Map ? Map<String, dynamic>.from(data) : {};
  }

  static Future<void> createDataOrder({required String network, required String phone, required String plan, required double amount}) async {
    throw Exception('Please choose a data plan from the live provider catalogue.');
  }

  static Future<void> createAirtimeCashRequest({required String network, required String phone, required double amount, required String payoutBank, required String accountNumber, required String accountName}) async {
    if (currentUser == null) throw Exception('Please sign in again.'); if (amount < 100) throw Exception('Minimum airtime to cash amount is ₦100.');
    await _client.rpc('create_airtime_cash_request', params: {'p_network': network, 'p_phone': phone, 'p_amount': amount, 'p_payout_bank': payoutBank, 'p_account_number': accountNumber, 'p_account_name': accountName, 'p_reference': 'ATC-${DateTime.now().microsecondsSinceEpoch}'});
  }
}
