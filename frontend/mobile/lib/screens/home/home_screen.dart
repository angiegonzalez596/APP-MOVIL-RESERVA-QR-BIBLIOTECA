import 'package:flutter/material.dart';

import '../ia/ia_screen.dart';
import '../qr/scan_qr_screen.dart';
import '../reportes/reportes_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reserva QR'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            _menuCard(
              context,
              icon: Icons.qr_code_scanner,
              titulo: 'Escanear QR',
              pantalla: const ScanQrScreen(),
            ),

            const SizedBox(height: 16),

            _menuCard(
              context,
              icon: Icons.smart_toy,
              titulo: 'Asistente IA',
              pantalla: const IaScreen(),
            ),

            const SizedBox(height: 16),

            _menuCard(
              context,
              icon: Icons.bar_chart,
              titulo: 'Reportes',
              pantalla: const ReportesScreen(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuCard(
    BuildContext context, {
    required IconData icon,
    required String titulo,
    required Widget pantalla,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon, size: 35),
        title: Text(titulo),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => pantalla));
        },
      ),
    );
  }
}
