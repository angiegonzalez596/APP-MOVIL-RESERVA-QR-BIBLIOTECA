import 'package:flutter/material.dart';
import '../../services/reserva_service.dart';

class HistorialIngresosScreen extends StatefulWidget {
  const HistorialIngresosScreen({super.key});

  @override
  State<HistorialIngresosScreen> createState() =>
      _HistorialIngresosScreenState();
}

class _HistorialIngresosScreenState extends State<HistorialIngresosScreen> {
  late Future<List<dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = ReservaService.obtenerReservas();
  }

  String _locker(dynamic reserva) {
    if (reserva['locker'] != null) return '#${reserva['locker']}';
    if (reserva['locker_id'] != null) return 'ID ${reserva['locker_id']}';
    return 'Sin asignar';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historial de reservas')),
      body: FutureBuilder<List<dynamic>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final reservas = snapshot.data ?? [];

          if (reservas.isEmpty) {
            return const Center(child: Text('No hay registros'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: reservas.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final reserva = reservas[index];

              return Card(
                child: ListTile(
                  leading: const Icon(Icons.history, color: Color(0xFFC62828)),
                  title: Text(
                    'Reserva #${reserva['id']} - ${reserva['estado']}',
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Estudiante: ${reserva['usuario'] ?? reserva['usuario_id']}',
                      ),
                      Text('Locker: ${_locker(reserva)}'),
                      Text('Inicio: ${reserva['fecha_inicio'] ?? 'Sin fecha'}'),
                      if (reserva['fecha_fin'] != null)
                        Text('Fin: ${reserva['fecha_fin']}'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
