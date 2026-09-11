import 'package:supabase_flutter/supabase_flutter.dart';

class WalletService {
  static final _client = Supabase.instance.client;

  static User? get currentUser => _client.auth.currentUser;

  static Future<void> logout() => _client.auth.signOut();

  static Future<double> getBalance() async {
    final user = currentUser;
    if (user == null) return 0;

    final row = await _client
        .from('wallets')
        .select('balance')
        .eq('user_id', user.id)
        .maybeSingle();

    if (row == null) return 0;
    return double.tryParse(row['balance'].toString()) ?? 0;
  }

  static Future<List<Map<String, dynamic>>> getTransactions({int limit = 50}) async {
    final user = currentUser;
    if (user == null) return [];

    final rows = await _client
        .from('transactions')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false)
        .limit(limit);

    return List<Map<String, dynamic>>.from(rows);
  }
}
