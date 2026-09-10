import 'package:flutter/material.dart';
import 'home_screen.dart';

void main() {
  runApp(const HamzaDigitalApp());
}

class HamzaDigitalApp extends StatelessWidget {
  const HamzaDigitalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HAMZA S. KARDAM DIGITAL APP',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
