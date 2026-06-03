import 'package:flutter/material.dart';
import 'locker_service.dart';
import '../../services/reserva_service.dart';
import 'vigilante_menu_screen.dart';

class LockerGridScreen extends StatefulWidget {
  final String reservaId; // Recibe el ID que escaneó del QR

  const LockerGridScreen({Key? key, required this.reservaId}) : super(key: key);

  @override
  State<LockerGridScreen> createState() => _LockerGridScreenState();
}

class _LockerGridScreenState extends State<LockerGridScreen> {
  late Future<List<dynamic>> _lockersFuture;
  int? _lockerSeleccionadoId; // Guarda cuál tocó el vigilante

  @override
  void initState() {
    super.initState();
    // Llamamos a tu API de Flask nada más cargar la pantalla
    _lockersFuture = LockerService.obtenerDisponibles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Casilleros Disponibles",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: FutureBuilder<List<dynamic>>(
          future: _lockersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text("Error al cargar casilleros"));
            }

            // Simulamos un mapa estático de 25 casilleros (como tu Figma de 5x5)
            // Pero cruzamos los datos reales de tu base de datos
            final libres = snapshot.data ?? [];
            final List<int> idsLibres = libres
                .map<int>((l) => l['id'] as int)
                .toList();

            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Expanded(
                    child: GridView.builder(
                      itemCount: 25, // Matriz de 5x5
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                      itemBuilder: (context, index) {
                        final int mockLockerId = index + 1; // IDs del 1 al 25
                        final bool isDisponible = idsLibres.contains(
                          mockLockerId,
                        );
                        final bool esElSeleccionado =
                            _lockerSeleccionadoId == mockLockerId;

                        return GestureDetector(
                          onTap: isDisponible
                              ? () {
                                  setState(() {
                                    _lockerSeleccionadoId = mockLockerId;
                                  });
                                }
                              : null, // Si está ocupado, no deja hacerle click
                          child: Container(
                            decoration: BoxDecoration(
                              color: esElSeleccionado
                                  ? Colors.blue.withOpacity(0.3)
                                  : Colors.transparent,
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Center(
                              child: Icon(
                                isDisponible
                                    ? Icons.check_circle
                                    : Icons.cancel,
                                color: isDisponible ? Colors.green : Colors.red,
                                size: 30,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // 🟢 BOTÓN: Registrar Ingreso
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7CFF2B),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      onPressed: _lockerSeleccionadoId == null
                          ? null // Sigue deshabilitado si no hay selección
                          : () async {
                              // 1. Mostrar un indicador de carga circular (ProgressDialog)
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );

                              // 2. Llamar al servicio HTTP de Flask
                              bool exito =
                                  await ReservaService.registrarIngreso(
                                    widget.reservaId,
                                    _lockerSeleccionadoId!,
                                  );

                              // 3. Quitar el círculo de carga
                              Navigator.pop(context);

                              if (exito) {
                                // 🎉 Todo salió perfecto en Flask y Neon
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "✅ Ingreso registrado y casillero asignado con éxito",
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                );

                                // Limpiamos el historial de pantallas y lo mandamos de vuelta al Menú del Vigilante
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const VigilanteMenuScreen(),
                                  ),
                                  (route) => false,
                                );
                              } else {
                                // ❌ Algo falló (ej. la reserva no existe o el casillero se ocupó en ese instante)
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "❌ No se pudo registrar el ingreso. Intente de nuevo.",
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                      child: const Text(
                        "Registrar ingreso",
                        style: TextStyle(color: Colors.black, fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
