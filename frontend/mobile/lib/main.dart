import 'package:flutter/material.dart';

import 'screens/home/home_screen.dart';

void main() {
  runApp(const ReservaQrApp());
}

class ReservaQrApp extends StatelessWidget {
  const ReservaQrApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Reserva QR',
      theme: ThemeData(useMaterial3: true),
      home: const HomeScreen(),
    );
  }
}
