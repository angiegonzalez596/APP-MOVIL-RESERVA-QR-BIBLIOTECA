import 'package:flutter/material.dart';

import '../../services/reserva_service.dart';

class RegistrarSalidaScreen extends StatefulWidget {
  const RegistrarSalidaScreen({super.key});

  @override
  State<RegistrarSalidaScreen> createState() => _RegistrarSalidaScreenState();
}

class _RegistrarSalidaScreenState extends State<RegistrarSalidaScreen> {
  final TextEditingController _lockerController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _lockerController.dispose();
    super.dispose();
  }

  Future<void> _registrarSalida() async {
    final numeroLocker = int.tryParse(_lockerController.text.trim());

    if (numeroLocker == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingrese un número de locker válido'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _loading = true);

    final exito = await ReservaService.registrarSalida(numeroLocker);

    if (!mounted) return;

    setState(() => _loading = false);

    if (!exito) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo registrar la salida. Verifique el locker.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Salida registrada'),
        content: Text(
          'El locker #$numeroLocker quedó disponible nuevamente.',
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
      appBar: AppBar(title: const Text('Registrar salida')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Image.asset(
              'assets/images/logo_unilibre.png',
              height: 80,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 40),
            const Text(
              'Ingrese el número del locker asignado',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _lockerController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                labelText: 'Número de locker',
                hintText: 'Ej: 105',
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _loading ? null : _registrarSalida,
                icon: const Icon(Icons.logout),
                label: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Registrar salida'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
