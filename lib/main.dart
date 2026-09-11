import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'home_screen.dart';
import 'screens/wallet_screen.dart';
import 'screens/transactions_screen.dart';
import 'screens/data_screen.dart';
import 'screens/airtime_screen.dart';
import 'screens/airtime_to_cash_screen.dart';
import 'screens/orders_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/fund_crypto_screen.dart';

const supabaseUrl = 'https://txuiicqlkyndwtizlouz.supabase.co';
const supabasePublishableKey = 'sb_publishable_5FJheQ0P-c-iddbxIPe7Zg_TWnhdBs-';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: supabaseUrl, anonKey: supabasePublishableKey);
  runApp(const KardamDigitalApp());
}

class KardamDigitalApp extends StatelessWidget {
  const KardamDigitalApp({super.key});

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF061B49);
    const gold = Color(0xFFC89B3C);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HAMZA S. KARDAM DIGITAL APP',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: navy),
        scaffoldBackgroundColor: const Color(0xFFF5F7FB),
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(backgroundColor: navy, foregroundColor: Colors.white),
        inputDecorationTheme: InputDecorationTheme(filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(14)), borderSide: BorderSide.none), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(14)), borderSide: BorderSide(color: gold, width: 1.5))),
      ),
      routes: {
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/home': (_) => const HomeScreen(),
        '/wallet': (_) => const WalletScreen(),
        '/transactions': (_) => const TransactionsScreen(),
        '/orders': (_) => const OrdersScreen(),
        '/profile': (_) => const ProfileScreen(),
        '/data': (_) => const DataScreen(),
        '/airtime': (_) => const AirtimeScreen(),
        '/airtime-to-cash': (_) => const AirtimeToCashScreen(),
        '/fund-crypto': (_) => const FundCryptoScreen(),
        '/admin': (_) => const AdminDashboardScreen(),
      },
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;
    return session == null ? const LoginScreen() : const HomeScreen();
  }
}
