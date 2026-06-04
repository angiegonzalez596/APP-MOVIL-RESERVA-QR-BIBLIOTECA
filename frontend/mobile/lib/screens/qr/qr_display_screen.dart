import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/qr_service.dart';
import '../reservas/crear_reserva_screen.dart';

class QrDisplayScreen extends StatefulWidget {
  const QrDisplayScreen({super.key});

  @override
  State<QrDisplayScreen> createState() => _QrDisplayScreenState();
}

class _QrDisplayScreenState extends State<QrDisplayScreen> {
  final QrService _qrService = QrService();

  bool _loading = true;
  String? _error;
  String? _qrBase64;
  String? _qrCode;
  int? _reservaId;

  @override
  void initState() {
    super.initState();
    _cargarQr();
  }

  Future<void> _cargarQr() async {
    setState(() {
      _loading = true;
      _error = null;
      _qrBase64 = null;
      _qrCode = null;
      _reservaId = null;
    });

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');

    if (userId == null) {
      setState(() {
        _loading = false;
        _error = 'Sesión no iniciada';
      });
      return;
    }

    final result = await _qrService.generateQr(userId);

    if (result.containsKey('error')) {
      setState(() {
        _loading = false;
        _error = result['error'];
      });
      return;
    }

    setState(() {
      _loading = false;
      _qrBase64 = result['qr_code_base64'];
      _qrCode = result['qr_code'];
      _reservaId = result['reserva_id'];
    });
  }

  void _irCrearReserva() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const CrearReservaScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi Código QR')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: _loading
              ? const CircularProgressIndicator()
              : _qrBase64 == null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 70,
                      color: Color(0xFFC62828),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _error ?? 'No tienes una reserva activa',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _irCrearReserva,
                        icon: const Icon(Icons.add),
                        label: const Text('Crear reserva'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _cargarQr,
                      child: const Text('Reintentar'),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Presenta este QR al vigilante',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_reservaId != null)
                      Text(
                        'Reserva #$_reservaId',
                        style: const TextStyle(
                          color: Color(0xFFC62828),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: const Color(0xFFC62828),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Image.memory(
                        base64Decode(_qrBase64!),
                        width: 240,
                        height: 240,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'El locker será asignado por el vigilante al momento del ingreso.',
                      textAlign: TextAlign.center,
                    ),
                    if (_qrCode != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _qrCode!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    TextButton.icon(
                      onPressed: _cargarQr,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Actualizar QR'),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
