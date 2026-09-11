import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'home_screen.dart';
import 'screens/wallet_screen.dart';
import 'screens/transactions_screen.dart';

const supabaseUrl = 'https://txuiicqlkyndwtizlouz.supabase.co';
const supabasePublishableKey = 'sb_publishable_5FJheQ0P-c-iddbxIPe7Zg_TWnhdBs-';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabasePublishableKey,
  );

  runApp(const KardamDigitalApp());
}

class KardamDigitalApp extends StatelessWidget {
  const KardamDigitalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HAMZA S. KARDAM DIGITAL APP',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0A8F55)),
        scaffoldBackgroundColor: const Color(0xFFF6F8F7),
        fontFamily: 'Roboto',
      ),
      routes: {
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/home': (_) => const HomeScreen(),
        '/wallet': (_) => const WalletScreen(),
        '/transactions': (_) => const TransactionsScreen(),
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
