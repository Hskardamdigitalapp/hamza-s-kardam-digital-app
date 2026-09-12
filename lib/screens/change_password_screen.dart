import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const _navy = Color(0xFF061B49);
const _navy2 = Color(0xFF0A2C68);
const _gold = Color(0xFFFFC83D);
const _bg = Color(0xFFF5F7FB);
const _darkCard = Color(0xFF1B1D22);

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});
  @override State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _current = TextEditingController();
  final _new = TextEditingController();
  final _confirm = TextEditingController();
  bool _hideCurrent = true, _hideNew = true, _hideConfirm = true, _saving = false;

  @override
  void dispose() { _current.dispose(); _new.dispose(); _confirm.dispose(); super.dispose(); }
  bool get _lengthOk => _new.text.length >= 6;
  bool get _different => _current.text.isEmpty || _new.text != _current.text;
  bool get _match => _new.text.isNotEmpty && _new.text == _confirm.text;

  Future<void> _update() async {
    FocusScope.of(context).unfocus();
    final user = Supabase.instance.client.auth.currentUser;
    final email = user?.email;
    if (email == null || email.isEmpty) { _show('Please sign in again.'); return; }
    if (_current.text.isEmpty || !_lengthOk || !_different || !_match) { _show('Please complete all password requirements.'); return; }
    setState(() => _saving = true);
    try {
      final check = await Supabase.instance.client.auth.signInWithPassword(email: email, password: _current.text);
      if (check.user == null) throw const AuthException('Current password is incorrect.');
      await Supabase.instance.client.auth.updateUser(UserAttributes(password: _new.text));
      if (!mounted) return;
      _show('Password updated successfully.');
      await Future<void>.delayed(const Duration(milliseconds: 500));
      if (mounted) Navigator.pop(context);
    } on AuthException catch (e) {
      if (mounted) _show(e.message.isNotEmpty ? e.message : 'Unable to update password.');
    } catch (_) {
      if (mounted) _show('Unable to update password. Please try again.');
    } finally { if (mounted) setState(() => _saving = false); }
  }

  void _show(String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: dark ? const Color(0xFF101216) : _bg,
      appBar: AppBar(backgroundColor: _navy, foregroundColor: Colors.white, title: const Text('Change Password', style: TextStyle(fontWeight: FontWeight.w900))),
      body: SafeArea(child: Column(children: [
        Expanded(child: ListView(padding: const EdgeInsets.fromLTRB(18, 18, 18, 24), children: [
          Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(gradient: const LinearGradient(colors: [_navy, _navy2]), borderRadius: BorderRadius.circular(24), border: Border.all(color: _gold.withOpacity(.45)), boxShadow: [BoxShadow(color: _gold.withOpacity(.10), blurRadius: 22, offset: const Offset(0, 10))]), child: const Row(children: [CircleAvatar(radius: 32, backgroundColor: Color(0x26FFC83D), child: Icon(Icons.shield_outlined, color: _gold, size: 34)), SizedBox(width: 16), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Keep your account secure', style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w900)), SizedBox(height: 5), Text('Choose a strong password you don\'t use anywhere else.', style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.35))]))]),
          const SizedBox(height: 24),
          _label('Current password'),
          _field(_current, 'Enter current password', _hideCurrent, () => setState(() => _hideCurrent = !_hideCurrent), Icons.lock_outline),
          const SizedBox(height: 18),
          _label('New password'),
          _field(_new, 'Enter new password', _hideNew, () => setState(() => _hideNew = !_hideNew), Icons.lock_outline, onChanged: (_) => setState(() {})),
          const SizedBox(height: 12),
          _check('At least 6 characters', _lengthOk),
          _check('Different from current password', _different),
          const SizedBox(height: 18),
          _label('Confirm new password'),
          _field(_confirm, 'Re-enter new password', _hideConfirm, () => setState(() => _hideConfirm = !_hideConfirm), Icons.lock_outline, onChanged: (_) => setState(() {})),
          const SizedBox(height: 12),
          _check('Passwords match', _match),
        ])),
        Container(padding: const EdgeInsets.fromLTRB(18, 12, 18, 18), color: dark ? const Color(0xFF17191E) : Colors.white, child: SizedBox(width: double.infinity, height: 56, child: ElevatedButton(onPressed: _saving ? null : _update, style: ElevatedButton.styleFrom(backgroundColor: _gold, foregroundColor: _navy, disabledBackgroundColor: _gold.withOpacity(.55), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17))), child: _saving ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: _navy)) : const Text('Update password', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900))))),
      ])),
    );
  }

  Widget _label(String text) => Padding(padding: const EdgeInsets.only(bottom: 9), child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)));
  Widget _field(TextEditingController c, String hint, bool hidden, VoidCallback toggle, IconData icon, {ValueChanged<String>? onChanged}) => TextField(controller: c, obscureText: hidden, onChanged: onChanged, decoration: InputDecoration(hintText: hint, prefixIcon: Icon(icon), suffixIcon: IconButton(onPressed: toggle, icon: Icon(hidden ? Icons.visibility_off_outlined : Icons.visibility_outlined)), filled: true, fillColor: Theme.of(context).brightness == Brightness.dark ? _darkCard : Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17)));
  Widget _check(String text, bool ok) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [Icon(ok ? Icons.check_circle : Icons.radio_button_unchecked, color: ok ? _gold : Theme.of(context).hintColor, size: 21), const SizedBox(width: 9), Expanded(child: Text(text, style: TextStyle(color: ok ? Theme.of(context).textTheme.bodyMedium?.color : Theme.of(context).hintColor, fontWeight: FontWeight.w600)))]));
}
