import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

const _gold = Color(0xFFFFC83D);
const _navy = Color(0xFF061B49);
const _whatsappNumber = '2347084646468';

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

    final uri = Uri.parse(
      'https://wa.me/$_whatsappNumber?text=${Uri.encodeComponent('Hello H.salah Communication, I need customer care support.')} ',
    );
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Customer care could not be opened.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Positioned(
      right: 16,
      bottom: bottom + 16,
      child: Semantics(
        button: true,
        label: 'Customer care',
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 220),
          opacity: _dimmed ? .38 : 1,
          child: Material(
            color: Colors.transparent,
            elevation: 10,
            shadowColor: _gold.withOpacity(.45),
            borderRadius: BorderRadius.circular(18),
            child: InkWell(
              onTap: _openCustomerCare,
              borderRadius: BorderRadius.circular(18),
              child: Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: _gold,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white.withOpacity(.75), width: 1.2),
                ),
                child: const Icon(Icons.support_agent_rounded, color: _navy, size: 34),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
