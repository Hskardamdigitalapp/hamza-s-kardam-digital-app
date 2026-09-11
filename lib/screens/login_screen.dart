import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const _navy = Color(0xFF061B49);
const _navy2 = Color(0xFF0A2C68);
const _gold = Color(0xFFC89B3C);
const _goldLight = Color(0xFFE7C66A);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool loading = false, obscurePassword = true;

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter your email and password.')));
      return;
    }
    setState(() => loading = true);
    try {
      await Supabase.instance.client.auth.signInWithPassword(email: email, password: password);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } on AuthException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Login failed: $e')));
    } finally { if (mounted) setState(() => loading = false); }
  }

  @override void dispose() { emailController.dispose(); passwordController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF5F7FB),
    body: SafeArea(child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: Column(children: [
      const SizedBox(height: 42),
      Container(width: 88, height: 88, decoration: BoxDecoration(gradient: const LinearGradient(colors: [_navy2, _navy]), borderRadius: BorderRadius.circular(24), border: Border.all(color: _gold, width: 1.5)), child: const Center(child: Text('HK', style: TextStyle(color: _goldLight, fontSize: 25, fontWeight: FontWeight.w900)))),
      const SizedBox(height: 20),
      const Text('HAMZA S. KARDAM', style: TextStyle(color: _navy, fontSize: 25, fontWeight: FontWeight.w900)),
      const Text('DIGITAL APP', style: TextStyle(color: _gold, fontSize: 18, fontWeight: FontWeight.w900)),
      const SizedBox(height: 7),
      const Text('Data • Airtime • Payments • Digital Services', textAlign: TextAlign.center, style: TextStyle(color: Colors.black54)),
      const SizedBox(height: 36),
      TextField(controller: emailController, keyboardType: TextInputType.emailAddress, decoration: _decoration('Email', Icons.email_outlined)),
      const SizedBox(height: 16),
      TextField(controller: passwordController, obscureText: obscurePassword, decoration: _decoration('Password', Icons.lock_outline, suffix: IconButton(onPressed: () => setState(() => obscurePassword = !obscurePassword), icon: Icon(obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined)))),
      const SizedBox(height: 24),
      SizedBox(width: double.infinity, height: 54, child: ElevatedButton(onPressed: loading ? null : login, style: ElevatedButton.styleFrom(backgroundColor: _navy, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))), child: loading ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: _goldLight)) : const Text('LOGIN', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)))),
      const SizedBox(height: 12),
      TextButton(onPressed: () => Navigator.pushNamed(context, '/register'), child: const Text('Create New Account', style: TextStyle(color: _gold, fontWeight: FontWeight.w900))),
    ]))),
  );

  InputDecoration _decoration(String label, IconData icon, {Widget? suffix}) => InputDecoration(labelText: label, prefixIcon: Icon(icon, color: _navy), suffixIcon: suffix, filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: _gold, width: 1.5)));
}
