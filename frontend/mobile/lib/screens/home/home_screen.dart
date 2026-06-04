import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../ia/ia_screen.dart';
import '../qr/qr_display_screen.dart';
import '../reportes/reportes_screen.dart';
import 'profile_screen.dart';
import '../reservas/mis_reservas_screen.dart';
import '../reservas/crear_reserva_screen.dart';
import '../qr/scan_qr_screen.dart';
import '../vigilante/registrar_salida_screen.dart';
import '../vigilante/estado_lockers_screen.dart';
import '../vigilante/historial_ingresos_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _rol;

  @override
  void initState() {
    super.initState();
    _loadUserRol();
  }

  void _loadUserRol() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _rol = prefs.getString('user_rol');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Unilibre Reserva QR'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [const Color(0xFFC62828).withOpacity(0.05), Colors.white],
          ),
        ),
        child: Stack(
          children: [
            // Logo de fondo con opacidad muy baja
            Center(
              child: Opacity(
                opacity: 0.05,
                child: Image.asset(
                  'assets/images/logo_unilibre.png',
                  width: MediaQuery.of(context).size.width * 0.8,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo de marca en la parte superior
                  Center(
                    child: Image.asset(
                      'assets/images/logo_unilibre.png',
                      height: 60,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Servicios Disponibles',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFC62828),
                    ),
                  ),
                  const SizedBox(height: 20),

                  if (_rol == 'ESTUDIANTE') ...[
                    _menuCard(
                      context,
                      icon: Icons.add_circle,
                      titulo: 'Crear Nueva Reserva',
                      subtitulo: 'Solicitar una reserva de locker',
                      pantalla: const CrearReservaScreen(),
                    ),
                    const SizedBox(height: 16),
                    _menuCard(
                      context,
                      icon: Icons.qr_code,
                      titulo: 'Mi Código QR de Reserva',
                      subtitulo: 'Generar reserva',
                      pantalla: const QrDisplayScreen(),
                    ),
                    const SizedBox(height: 16),
                    _menuCard(
                      context,
                      icon: Icons.assignment,
                      titulo: 'Mis Reservas',
                      subtitulo: 'Ver reserva activa e historial',
                      pantalla: const MisReservasScreen(),
                    ),
                  ],

                  if (_rol == 'VIGILANTE') ...[
                    _menuCard(
                      context,
                      icon: Icons.qr_code_scanner,
                      titulo: 'Registrar ingreso',
                      subtitulo: 'Escanear QR y asignar locker',
                      pantalla: const ScanQrScreen(),
                    ),

                    _menuCard(
                      context,
                      icon: Icons.logout,
                      titulo: 'Registrar salida',
                      subtitulo: 'Liberar locker',
                      pantalla: const RegistrarSalidaScreen(),
                    ),

                    _menuCard(
                      context,
                      icon: Icons.lock,
                      titulo: 'Estado de lockers',
                      subtitulo: 'Disponibles y ocupados',
                      pantalla: const EstadoLockersScreen(),
                    ),

                    _menuCard(
                      context,
                      icon: Icons.history,
                      titulo: 'Historial',
                      subtitulo: 'Reservas e ingresos',
                      pantalla: const HistorialIngresosScreen(),
                    ),
                  ],

                  if (_rol == 'ADMIN') ...[
                    _menuCard(
                      context,
                      icon: Icons.bar_chart,
                      titulo: 'Panel de Administración',
                      subtitulo: 'Reportes y estadísticas',
                      pantalla: const ReportesScreen(),
                    ),
                  ],

                  const Spacer(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.large(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const IaScreen()),
          );
        },
        backgroundColor: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/panda_rojo.png',
              height: 60,
              fit: BoxFit.contain,
            ),
            const Text(
              'IA Panda',
              style: TextStyle(
                fontSize: 10,
                color: Color(0xFFC62828),
                fontWeight: FontWeight.bold,
              ),
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
    required String subtitulo,
    required Widget pantalla,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFC62828).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 30, color: const Color(0xFFC62828)),
        ),
        title: Text(
          titulo,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitulo),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Color(0xFFC62828),
        ),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => pantalla));
        },
      ),
    );
  }
}
