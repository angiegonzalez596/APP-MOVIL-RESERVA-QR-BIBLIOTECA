import 'package:flutter/material.dart';

import '../../services/reserva_service.dart';
import 'locker_service.dart';

class LockerGridScreen extends StatefulWidget {
  final String reservaId;

  const LockerGridScreen({super.key, required this.reservaId});

  @override
  State<LockerGridScreen> createState() => _LockerGridScreenState();
}

class _LockerGridScreenState extends State<LockerGridScreen> {
  late Future<List<dynamic>> _lockersFuture;
  int? _lockerId;
  int? _lockerNumero;

  @override
  void initState() {
    super.initState();
    _lockersFuture = LockerService.obtenerDisponibles();
  }

  Future<void> _registrarIngreso() async {
    if (_lockerId == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final exito = await ReservaService.registrarIngreso(
      widget.reservaId,
      _lockerId!,
    );

    if (!mounted) return;

    Navigator.pop(context);

    if (!exito) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo registrar el ingreso'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Ingreso registrado'),
        content: Text(
          'Locker #$_lockerNumero asignado correctamente.',
          textAlign: TextAlign.center,
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            child: const Text('Volver al menú'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Seleccionar locker')),
      body: FutureBuilder<List<dynamic>>(
        future: _lockersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final lockers = snapshot.data ?? [];

          if (lockers.isEmpty) {
            return const Center(child: Text('No hay lockers disponibles'));
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Expanded(
                  child: GridView.builder(
                    itemCount: lockers.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    itemBuilder: (context, index) {
                      final locker = lockers[index];
                      final id = locker['id'];
                      final numero = locker['numero'];
                      final seleccionado = _lockerId == id;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _lockerId = id;
                            _lockerNumero = numero;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: seleccionado
                                ? Colors.blue.withOpacity(0.25)
                                : Colors.green.withOpacity(0.12),
                            border: Border.all(
                              color: seleccionado ? Colors.blue : Colors.green,
                              width: 2,
                            ),
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
                              const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (_lockerNumero != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      'Locker seleccionado: #$_lockerNumero',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _lockerId == null ? null : _registrarIngreso,
                    child: const Text('Registrar ingreso'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
