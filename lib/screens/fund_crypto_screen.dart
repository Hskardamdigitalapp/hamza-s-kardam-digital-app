import 'package:flutter/material.dart';

const _navy = Color(0xFF061B49);
const _gold = Color(0xFFC89B3C);
const _bg = Color(0xFFF5F7FB);

class FundCryptoScreen extends StatelessWidget {
  const FundCryptoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final coins = const [
      _Coin('USDT', 'USDT (ERC-20)', 'U', Color(0xFF26A17B)),
      _Coin('USDT', 'USDT (BEP-20)', 'U', Color(0xFF26A17B)),
      _Coin('USDT', 'USDT (TRC-20)', 'U', Color(0xFF26A17B)),
      _Coin('BTC', 'Bitcoin', 'B', Color(0xFFF7931A)),
      _Coin('ETH', 'Ethereum', 'E', Color(0xFF627EEA)),
      _Coin('BNB', 'BNB (BSC)', 'B', Color(0xFFF3BA2F)),
      _Coin('SOL', 'SOL (Solana)', 'S', Color(0xFF9945FF)),
      _Coin('POL', 'Polygon', 'P', Color(0xFF8247E5)),
    ];

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _navy,
        foregroundColor: Colors.white,
        title: const Text('Fund with Crypto', style: TextStyle(fontWeight: FontWeight.w900)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: _gold.withOpacity(.35)),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(backgroundColor: Color(0xFFFFF3D0), child: Icon(Icons.bolt, color: _gold)),
                SizedBox(width: 14),
                Expanded(child: Text('Pick a coin, send it to the displayed address, and the crypto amount will be converted to Naira and added to your wallet after confirmation.', style: TextStyle(color: Colors.black87, height: 1.35, fontWeight: FontWeight.w600))),
              ],
            ),
          ),
          const SizedBox(height: 26),
          const Text('Choose a coin', style: TextStyle(color: _navy, fontSize: 21, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          ...coins.map((coin) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              child: InkWell(
                borderRadius: BorderRadius.circular(22),
                onTap: () => _notConfigured(context, coin),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                  child: Row(children: [
                    CircleAvatar(backgroundColor: coin.color, child: Text(coin.symbol, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900))),
                    const SizedBox(width: 16),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(coin.name, style: const TextStyle(color: _navy, fontSize: 17, fontWeight: FontWeight.w900)), const SizedBox(height: 3), Text(coin.network, style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w600))])),
                    const Icon(Icons.chevron_right, color: _navy),
                  ]),
                ),
              ),
            ),
          )),
          const SizedBox(height: 6),
          const Text('Crypto deposits will be enabled after a supported crypto/payment provider is connected. No wallet address is shown until a real provider address exists.', style: TextStyle(color: Colors.black54, fontSize: 12, height: 1.35)),
        ],
      ),
    );
  }

  void _notConfigured(BuildContext context, _Coin coin) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${coin.network} wallet address is not configured yet.')));
  }
}

class _Coin {
  final String name;
  final String network;
  final String symbol;
  final Color color;
  const _Coin(this.name, this.network, this.symbol, this.color);
}
