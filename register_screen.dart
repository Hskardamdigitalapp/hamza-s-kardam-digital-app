import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final name = TextEditingController();
  final phone = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  bool loading = false;
  bool obscure = true;

  Future<void> register() async {
    if (name.text.trim().isEmpty ||
        phone.text.trim().isEmpty ||
        email.text.trim().isEmpty ||
        password.text.length < 6) {
      _message('Fill all fields. Password must be at least 6 characters.');
      return;
    }

    setState(() => loading = true);
    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: email.text.trim(),
        password: password.text,
        data: {
          'full_name': name.text.trim(),
          'phone': phone.text.trim(),
        },
      );

      if (!mounted) return;

      if (response.session != null && response.user != null) {
        await _createProfile(response.user!);
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        _message('Account created. Check your email to confirm your account, then login.');
        Navigator.pop(context);
      }
    } on AuthException catch (e) {
      _message(e.message);
    } catch (_) {
      _message('Registration failed. Please try again.');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _createProfile(User user) async {
    await Supabase.instance.client.from('profiles').upsert({
      'id': user.id,
      'full_name': name.text.trim(),
      'phone': phone.text.trim(),
      'email': email.text.trim(),
      'role': 'customer',
    });
  }

  void _message(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  @override
  void dispose() {
    name.dispose();
    phone.dispose();
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Join HAMZA S. KARDAM DIGITAL APP',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: name,
                  decoration: const InputDecoration(
                    labelText: 'Full name',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: phone,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone number',
                    prefixIcon: Icon(Icons.phone_outlined),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: password,
                  obscureText: obscure,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => obscure = !obscure),
                      icon: Icon(obscure ? Icons.visibility : Icons.visibility_off),
                    ),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  height: 52,
                  child: FilledButton(
                    onPressed: loading ? null : register,
                    child: loading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('CREATE ACCOUNT',
                            style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
