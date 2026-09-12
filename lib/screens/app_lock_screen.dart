import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

const _bg = Color(0xFF101010);
const _card = Color(0xFF1B1B1D);
const _gold = Color(0xFFFFC83D);
const _muted = Color(0xFF9B9BA6);
const _danger = Color(0xFFFF4D4D);

class AppLockScreen extends StatefulWidget {
  const AppLockScreen({
    super.key,
    required this.userId,
    required this.displayName,
    required this.onUnlocked,
    required this.onSwitchAccount,
    required this.setupMode,
  });

  final String userId;
  final String displayName;
  final VoidCallback onUnlocked;
  final VoidCallback onSwitchAccount;
  final bool setupMode;

  @override
  State<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends State<AppLockScreen> {
  static const _storage = FlutterSecureStorage();
  final _auth = LocalAuthentication();
  String _pin = '';
  String _firstPin = '';
  bool _confirming = false;
  bool _busy = false;
  String? _error;
  int _failedAttempts = 0;

  String get _key => 'kardam_app_pin_hash_${widget.userId}';

  @override
  void initState() {
    super.initState();
    if (!widget.setupMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _tryBiometric());
    }
  }

  Future<void> _tryBiometric() async {
    if (_busy || !mounted) return;
    try {
      final supported = await _auth.isDeviceSupported();
      final canCheck = await _auth.canCheckBiometrics;
      if (!supported || !canCheck) return;
      final authenticated = await _auth.authenticate(
        localizedReason: 'Verify your identity to open HAMZA S. KARDAM DIGITAL APP',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );
      if (authenticated && mounted) widget.onUnlocked();
    } catch (_) {
      // PIN remains available when biometrics are unavailable or cancelled.
    }
  }

  String _hash(String value) => sha256.convert(utf8.encode(value)).toString();

  Future<void> _submitDigit(String digit) async {
    if (_busy || _pin.length >= 4) return;
    setState(() {
      _pin += digit;
      _error = null;
    });
    if (_pin.length == 4) {
      await Future<void>.delayed(const Duration(milliseconds: 120));
      if (widget.setupMode) {
        if (!_confirming) {
          setState(() {
            _firstPin = _pin;
            _pin = '';
            _confirming = true;
          });
        } else if (_pin == _firstPin) {
          await _savePin();
        } else {
          setState(() {
            _pin = '';
            _firstPin = '';
            _confirming = false;
            _error = 'PINs do not match. Try again.';
          });
        }
      } else {
        await _verifyPin();
      }
    }
  }

  void _deleteDigit() {
    if (_pin.isEmpty || _busy) return;
    setState(() {
      _pin = _pin.substring(0, _pin.length - 1);
      _error = null;
    });
  }

  Future<void> _savePin() async {
    setState(() => _busy = true);
    await _storage.write(key: _key, value: _hash(_pin));
    if (!mounted) return;
    setState(() => _busy = false);
    widget.onUnlocked();
  }

  Future<void> _verifyPin() async {
    setState(() => _busy = true);
    final saved = await _storage.read(key: _key);
    final valid = saved != null && saved == _hash(_pin);
    if (!mounted) return;
    if (valid) {
      setState(() => _busy = false);
      widget.onUnlocked();
      return;
    }
    setState(() {
      _busy = false;
      _pin = '';
      _failedAttempts++;
      _error = _failedAttempts >= 3 ? 'Incorrect PIN. You can use biometrics.' : 'Incorrect PIN. Try again.';
    });
  }

  Widget _pinBox(int index) {
    final filled = index < _pin.length;
    final active = index == _pin.length && !_busy;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: 74,
      height: 74,
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: active ? _gold : Colors.transparent, width: 2),
      ),
      child: Center(
        child: filled
            ? Container(width: 15, height: 15, decoration: const BoxDecoration(color: _gold, shape: BoxShape.circle))
            : null,
      ),
    );
  }

  Widget _keyButton(String value) {
    return SizedBox(
      width: 82,
      height: 82,
      child: TextButton(
        onPressed: _busy ? null : () => _submitDigit(value),
        style: TextButton.styleFrom(shape: const CircleBorder(), foregroundColor: Colors.white),
        child: Text(value, style: const TextStyle(fontSize: 38, fontWeight: FontWeight.w500)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.setupMode
        ? (_confirming ? 'Confirm your PIN' : 'Create your app PIN')
        : 'Welcome Back, ${widget.displayName}!';
    final subtitle = widget.setupMode
        ? 'Use a 4-digit PIN to protect this app'
        : 'Please enter your PIN or use Biometrics';

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 38),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(title, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900)),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: _muted, fontSize: 18, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 44),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 18),
                padding: const EdgeInsets.fromLTRB(20, 38, 20, 20),
                decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(34)),
                child: Column(
                  children: [
                    Text(widget.setupMode && _confirming ? 'Enter PIN again' : 'Enter PIN', style: const TextStyle(color: _muted, fontSize: 20, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 26),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(4, _pinBox).map((e) => Padding(padding: const EdgeInsets.symmetric(horizontal: 5), child: e)).toList()),
                    const SizedBox(height: 18),
                    SizedBox(height: 24, child: _error == null ? null : Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: _danger, fontWeight: FontWeight.w700))),
                    const Spacer(),
                    if (!widget.setupMode)
                      TextButton(
                        onPressed: _busy ? null : widget.onSwitchAccount,
                        child: const Text.rich(TextSpan(children: [TextSpan(text: 'Not You? ', style: TextStyle(color: _muted, fontSize: 18)), TextSpan(text: 'Switch Account', style: TextStyle(color: _gold, fontSize: 18, fontWeight: FontWeight.w900))])),
                      ),
                    const SizedBox(height: 8),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [_keyButton('1'), _keyButton('2'), _keyButton('3')]),
                    const SizedBox(height: 12),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [_keyButton('4'), _keyButton('5'), _keyButton('6')]),
                    const SizedBox(height: 12),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [_keyButton('7'), _keyButton('8'), _keyButton('9')]),
                    const SizedBox(height: 12),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                      SizedBox(width: 82, height: 82, child: widget.setupMode ? null : TextButton(onPressed: _busy ? null : _tryBiometric, style: TextButton.styleFrom(backgroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))), child: const Icon(Icons.fingerprint, color: Colors.black, size: 42))),
                      _keyButton('0'),
                      SizedBox(width: 82, height: 82, child: TextButton(onPressed: _busy ? null : _deleteDigit, style: TextButton.styleFrom(foregroundColor: Colors.white), child: const Icon(Icons.backspace_outlined, size: 32))),
                    ]),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
