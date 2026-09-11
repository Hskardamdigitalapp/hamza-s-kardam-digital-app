import 'package:supabase_flutter/supabase_flutter.dart';

class WalletService {
  static final _client = Supabase.instance.client;

  static User? get currentUser => _client.auth.currentUser;

  static Future<void> logout() => _client.auth.signOut();

  static Future<double> getBalance() async {
    final user = currentUser;
    if (user == null) return 0;
    final row = await _client.from('wallets').select('balance').eq('user_id', user.id).maybeSingle();
    if (row == null) return 0;
    return double.tryParse(row['balance'].toString()) ?? 0;
  }

  static Future<Map<String, dynamic>?> getProfile() async {
    final user = currentUser;
    if (user == null) return null;
    final row = await _client.from('profiles').select().eq('id', user.id).maybeSingle();
    return row;
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

  static Future<void> createAirtimeOrder({required String network, required String phone, required double amount}) async {
    if (currentUser == null) throw Exception('Please sign in again.');
    if (amount < 50) throw Exception('Minimum airtime amount is ₦50.');
    final reference = 'AIR-${DateTime.now().microsecondsSinceEpoch}';
    await _client.rpc('create_airtime_order', params: {
      'p_network': network,
      'p_phone': phone,
      'p_amount': amount,
      'p_reference': reference,
    });
  }

  static Future<void> createDataOrder({required String network, required String phone, required String plan, required double amount}) async {
    if (currentUser == null) throw Exception('Please sign in again.');
    if (amount <= 0) throw Exception('Enter a valid amount.');
    final reference = 'DATA-${DateTime.now().microsecondsSinceEpoch}';
    await _client.rpc('create_data_order', params: {
      'p_network': network,
      'p_phone': phone,
      'p_plan': plan,
      'p_amount': amount,
      'p_reference': reference,
    });
  }
}
