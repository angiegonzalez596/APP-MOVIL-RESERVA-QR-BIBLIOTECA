import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/reserva_service.dart';
import '../qr/qr_display_screen.dart';

class CrearReservaScreen extends StatefulWidget {
  const CrearReservaScreen({super.key});

  @override
  State<CrearReservaScreen> createState() => _CrearReservaScreenState();
}

class _CrearReservaScreenState extends State<CrearReservaScreen> {
  bool _loading = false;
  String? _mensaje;

  Future<void> _crearReserva() async {
    setState(() {
      _loading = true;
      _mensaje = null;
    });

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');

    if (userId == null) {
      setState(() {
        _loading = false;
        _mensaje = 'Sesión no iniciada';
      });
      return;
    }

    final result = await ReservaService.crearReserva(userId);

    setState(() {
      _loading = false;
    });

    if (result.containsKey('error')) {
      setState(() {
        _mensaje = result['error'];
      });
      return;
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reserva creada correctamente'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const QrDisplayScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear reserva')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 80, color: Color(0xFFC62828)),
            const SizedBox(height: 24),
            const Text(
              'Crear nueva reserva de locker',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'La reserva quedará activa. El locker será asignado por el vigilante cuando presentes tu QR.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (_mensaje != null)
              Text(
                _mensaje!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _loading ? null : _crearReserva,
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Crear reserva'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
