import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../screens/customer_care_screen.dart';

const _gold = Color(0xFFB8860B);
const _navy = Color(0xFF061B49);

class CustomerCareButton extends StatefulWidget {
  const CustomerCareButton({super.key});
  @override State<CustomerCareButton> createState() => _CustomerCareButtonState();
}

class _CustomerCareButtonState extends State<CustomerCareButton> {
  Timer? _timer;
  bool _dimmed = false;

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  Future<void> _openCustomerCare() async {
    _timer?.cancel();
    setState(() => _dimmed = true);
    _timer = Timer(const Duration(milliseconds: 900), () { if (mounted) setState(() => _dimmed = false); });
    await Future<void>.delayed(const Duration(milliseconds: 120));
    if (!mounted) return;
    final route = ModalRoute.of(context)?.settings.name;
    if (route == '/login' || route == '/register') {
      await launchUrl(Uri.parse('https://wa.me/2349044444921?text=Hello%20HAMZA%20S.%20KARDAM%20DIGITAL%20APP%2C%20I%20need%20customer%20care%20support.'), mode: LaunchMode.externalApplication);
      return;
    }
    await Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(builder: (_) => const CustomerCareScreen()));
    if (mounted) setState(() => _dimmed = false);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Positioned(
      right: 16, bottom: bottom + 16,
      child: Semantics(
        button: true, label: 'Customer care on WhatsApp',
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 180), opacity: _dimmed ? .35 : 1,
          child: Material(
            color: Colors.transparent, elevation: 10, shadowColor: _gold.withValues(alpha: .45), borderRadius: BorderRadius.circular(18),
            child: InkWell(
              onTap: _openCustomerCare, borderRadius: BorderRadius.circular(18),
              child: Container(
                width: 62, height: 62, padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(color: _gold, borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.white.withValues(alpha: .75), width: 1.2)),
                child: Image.network('https://img.icons8.com/color/96/whatsapp--v1.png', fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.chat_rounded, color: _navy, size: 34)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
