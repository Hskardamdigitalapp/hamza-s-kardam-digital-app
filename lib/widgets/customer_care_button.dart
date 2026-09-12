import 'dart:async';
import 'package:flutter/material.dart';
import '../screens/customer_care_screen.dart';

const _gold = Color(0xFFB8860B);
const _navy = Color(0xFF061B49);

class CustomerCareButton extends StatefulWidget {
  const CustomerCareButton({super.key});

  @override
  State<CustomerCareButton> createState() => _CustomerCareButtonState();
}

class _CustomerCareButtonState extends State<CustomerCareButton> {
  Timer? _timer;
  bool _dimmed = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _openCustomerCare() async {
    _timer?.cancel();
    setState(() => _dimmed = true);
    _timer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _dimmed = false);
    });
    await Future<void>.delayed(const Duration(milliseconds: 180));
    if (!mounted) return;
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CustomerCareScreen()));
    if (mounted) setState(() => _dimmed = false);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Positioned(
      right: 16,
      bottom: bottom + 16,
      child: Semantics(
        button: true,
        label: 'Customer care on WhatsApp',
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 220),
          opacity: _dimmed ? .38 : 1,
          child: Material(
            color: Colors.transparent,
            elevation: 10,
            shadowColor: _gold.withValues(alpha: .45),
            borderRadius: BorderRadius.circular(18),
            child: InkWell(
              onTap: _openCustomerCare,
              borderRadius: BorderRadius.circular(18),
              child: Container(
                width: 62,
                height: 62,
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: _gold,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white.withValues(alpha: .75), width: 1.2),
                ),
                child: Image.network(
                  'https://img.icons8.com/color/96/whatsapp--v1.png',
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(Icons.chat_rounded, color: _navy, size: 34),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
