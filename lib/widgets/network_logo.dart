import 'package:flutter/material.dart';

class NetworkLogo extends StatelessWidget {
  const NetworkLogo({super.key, required this.network, this.size = 48});

  final String network;
  final double size;

  String get _asset {
    switch (network.toLowerCase()) {
      case 'mtn':
        return 'https://cdn.simpleicons.org/mtn';
      case 'airtel':
        return 'https://cdn.simpleicons.org/airtel';
      case 'glo':
        return 'https://cdn.simpleicons.org/globus';
      case '9mobile':
        return 'https://cdn.simpleicons.org/9mobile';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final label = network == '9mobile' ? '9' : network.substring(0, 1).toUpperCase();
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F7),
        borderRadius: BorderRadius.circular(size * .25),
        border: Border.all(color: const Color(0xFFE5E5EA)),
      ),
      alignment: Alignment.center,
      child: _asset.isEmpty
          ? Text(label, style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF061B49)))
          : ClipRRect(
              borderRadius: BorderRadius.circular(size * .2),
              child: Image.network(
                _asset,
                width: size * .72,
                height: size * .72,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Text(label, style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF061B49))),
              ),
            ),
    );
  }
}
