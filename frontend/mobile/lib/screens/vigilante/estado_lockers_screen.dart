import 'package:flutter/material.dart';
import 'locker_service.dart';

class EstadoLockersScreen extends StatefulWidget {
  const EstadoLockersScreen({super.key});

  @override
  State<EstadoLockersScreen> createState() => _EstadoLockersScreenState();
}

class _EstadoLockersScreenState extends State<EstadoLockersScreen> {
  late Future<List<dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = LockerService.obtenerTodos();
  }

  Color _colorEstado(String estado) {
    final e = estado.toLowerCase();
    if (e == 'disponible') return Colors.green;
    if (e == 'ocupado') return Colors.red;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Estado de lockers')),
      body: FutureBuilder<List<dynamic>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final lockers = snapshot.data ?? [];

          if (lockers.isEmpty) {
            return const Center(child: Text('No hay lockers registrados'));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: lockers.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemBuilder: (context, index) {
              final locker = lockers[index];
              final numero = locker['numero'];
              final estado = locker['estado'] ?? 'desconocido';

              return Container(
                decoration: BoxDecoration(
                  color: _colorEstado(estado).withOpacity(0.12),
                  border: Border.all(color: _colorEstado(estado), width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '#$numero',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Icon(
                      estado.toString().toLowerCase() == 'disponible'
                          ? Icons.check_circle
                          : Icons.cancel,
                      color: _colorEstado(estado),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      estado.toString(),
                      style: TextStyle(color: _colorEstado(estado)),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
