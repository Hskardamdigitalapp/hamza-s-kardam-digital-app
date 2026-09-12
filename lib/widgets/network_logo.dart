import 'package:flutter/material.dart';

class NetworkLogo extends StatelessWidget {
  const NetworkLogo({super.key, required this.network, this.size = 48});

  final String network;
  final double size;

  String get _asset {
    switch (network.toLowerCase()) {
      case 'mtn':
        return 'https://mtn.ng/favicon.ico';
      case 'airtel':
        return 'https://www.airtel.com.ng/favicon.ico';
      case 'glo':
        return 'https://www.gloworld.com/favicon.ico';
      case 't2':
        return 'https://www.t2mobile.com.ng/favicon.ico';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final label = network.toLowerCase() == 't2' ? 'T2' : network.substring(0, 1).toUpperCase();
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
                width: size * .74,
                height: size * .74,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Text(label, style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF061B49))),
              ),
            ),
    );
  }
}
