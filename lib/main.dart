import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'home_screen.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/airtime_screen.dart';
import 'screens/airtime_to_cash_screen.dart';
import 'screens/app_lock_screen.dart';
import 'screens/data_screen.dart';
import 'screens/fund_crypto_screen.dart';
import 'screens/login_screen.dart';
import 'screens/orders_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/register_screen.dart';
import 'screens/transactions_screen.dart';
import 'screens/transfer_to_bank_screen.dart';
import 'screens/wallet_screen.dart';
import 'widgets/customer_care_button.dart';

const supabaseUrl = 'https://txuiicqlkyndwtizlouz.supabase.co';
const supabasePublishableKey = 'sb_publishable_5FJheQ0P-c-iddbxIPe7Zg_TWnhdBs-';
final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

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
      navigatorKey: _navigatorKey,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: navy),
        scaffoldBackgroundColor: const Color(0xFFF5F7FB),
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(backgroundColor: navy, foregroundColor: Colors.white),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(14)),
            borderSide: BorderSide.none,
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(14)),
            borderSide: BorderSide(color: gold, width: 1.5),
          ),
        ),
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
        '/transfer-to-bank': (_) => const TransferToBankScreen(),
        '/admin': (_) => const AdminDashboardScreen(),
      },
      home: const AuthGate(),
      builder: (context, child) => AppShell(child: child ?? const SizedBox.shrink()),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.child});
  final Widget child;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> with WidgetsBindingObserver {
  final _storage = const FlutterSecureStorage();
  StreamSubscription<AuthState>? _authSubscription;
  bool _locked = false;
  bool _setupPin = false;
  String? _userId;
  String _displayName = 'User';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((_) {
      _syncSession(forceLock: false);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncSession(forceLock: true));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _authSubscription?.cancel();
    super.dispose();
  }

  String _pinKey(String userId) => 'kardam_app_pin_hash_$userId';

  String _nameFor(User user) {
    final metadataName = user.userMetadata?['full_name']?.toString().trim();
    if (metadataName != null && metadataName.isNotEmpty) return metadataName;
    final email = user.email?.trim();
    if (email != null && email.contains('@')) return email.split('@').first;
    return 'User';
  }

  Future<void> _syncSession({required bool forceLock}) async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) {
      if (!mounted) return;
      setState(() {
        _locked = false;
        _setupPin = false;
        _userId = null;
      });
      return;
    }

    final user = session.user;
    final savedPin = await _storage.read(key: _pinKey(user.id));
    if (!mounted) return;
    setState(() {
      _userId = user.id;
      _displayName = _nameFor(user);
      _setupPin = savedPin == null;
      _locked = forceLock && savedPin != null;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.paused) return;
    final userId = Supabase.instance.client.auth.currentSession?.user.id;
    if (userId == null) return;
    _storage.read(key: _pinKey(userId)).then((pin) {
      if (pin != null && mounted) setState(() => _locked = true);
    });
  }

  void _unlock() {
    if (!mounted) return;
    setState(() {
      _locked = false;
      _setupPin = false;
    });
  }

  Future<void> _switchAccount() async {
    await Supabase.instance.client.auth.signOut();
    if (!mounted) return;
    _navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (_) => false);
  }

  Future<bool> _confirmExit() async {
    if (!mounted) return false;
    final exit = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1B1B1D),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
        contentPadding: const EdgeInsets.fromLTRB(26, 28, 26, 18),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning_amber_rounded, color: Color(0xFFFF4D4D), size: 62),
            const SizedBox(height: 16),
            const Text('Exit App', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900)),
            const SizedBox(height: 12),
            const Text('Are you sure you want to exit?', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF9B9BA6), fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(dialogContext, false),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2196F3), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                      child: const Text('Cancel', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(dialogContext, true),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF44336), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                      child: const Text('Exit', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    return exit == true;
  }

  Future<void> _handleBack() async {
    final navigator = _navigatorKey.currentState;
    if (navigator != null && navigator.canPop()) {
      navigator.pop();
      return;
    }
    if (await _confirmExit()) {
      await Future<void>.delayed(const Duration(milliseconds: 80));
      await SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<void>(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handleBack();
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          widget.child,
          if (_locked && _userId != null)
            Positioned.fill(
              child: AppLockScreen(
                userId: _userId!,
                displayName: _displayName,
                setupMode: false,
                onUnlocked: _unlock,
                onSwitchAccount: _switchAccount,
              ),
            ),
          if (_setupPin && _userId != null)
            Positioned.fill(
              child: AppLockScreen(
                userId: _userId!,
                displayName: _displayName,
                setupMode: true,
                onUnlocked: _unlock,
                onSwitchAccount: _switchAccount,
              ),
            ),
          const CustomerCareButton(),
        ],
      ),
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
