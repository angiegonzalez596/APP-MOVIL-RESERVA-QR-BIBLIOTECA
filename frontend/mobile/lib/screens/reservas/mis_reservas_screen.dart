import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/reserva_service.dart';

class MisReservasScreen extends StatefulWidget {
  const MisReservasScreen({super.key});

  @override
  State<MisReservasScreen> createState() => _MisReservasScreenState();
}

class _MisReservasScreenState extends State<MisReservasScreen> {
  late Future<List<dynamic>> _reservasFuture;

  @override
  void initState() {
    super.initState();
    _reservasFuture = _cargarReservas();
  }

  Future<List<dynamic>> _cargarReservas() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');

    if (userId == null) {
      throw Exception('Sesión no iniciada');
    }

    return ReservaService.obtenerReservasUsuario(userId);
  }

  String _textoLocker(dynamic reserva) {
    if (reserva['locker'] != null) {
      return 'Locker #${reserva['locker']}';
    }
    return 'Pendiente de asignación por vigilante';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis Reservas')),
      body: FutureBuilder<List<dynamic>>(
        future: _reservasFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text('No se pudieron cargar las reservas'),
            );
          }

          final reservas = snapshot.data ?? [];

          if (reservas.isEmpty) {
            return const Center(child: Text('Aún no tienes reservas'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: reservas.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final reserva = reservas[index];

              return Card(
                elevation: 3,
                child: ListTile(
                  leading: Icon(
                    reserva['estado'] == 'activa'
                        ? Icons.event_available
                        : Icons.history,
                    color: const Color(0xFFC62828),
                  ),
                  title: Text('Reserva #${reserva['id']}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Estado: ${reserva['estado']}'),
                      Text(_textoLocker(reserva)),
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
