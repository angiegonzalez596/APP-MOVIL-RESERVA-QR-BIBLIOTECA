import 'package:flutter/material.dart';
import '../../services/reporte_service.dart';

class ReportesScreen extends StatefulWidget {
  const ReportesScreen({super.key});

  @override
  State<ReportesScreen> createState() => _ReportesScreenState();
}

class _ReportesScreenState extends State<ReportesScreen> {
  final ReporteService service = ReporteService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reportes')),
      body: FutureBuilder(
        future: service.obtenerResumen(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Usuarios: ${data["usuarios"]["total"]}',
                style: const TextStyle(fontSize: 18),
              ),

              Text(
                'Lockers: ${data["lockers"]["total"]}',
                style: const TextStyle(fontSize: 18),
              ),

              Text(
                'Disponibles: ${data["lockers"]["disponibles"]}',
                style: const TextStyle(fontSize: 18),
              ),

              Text(
                'Ocupados: ${data["lockers"]["ocupados"]}',
                style: const TextStyle(fontSize: 18),
              ),

              Text(
                'Reservas activas: ${data["reservas"]["activas"]}',
                style: const TextStyle(fontSize: 18),
              ),

              Text(
                'Ingresos: ${data["ingresos"]["total"]}',
                style: const TextStyle(fontSize: 18),
              ),
            ],
          );
        },
      ),
    );
  }
}
