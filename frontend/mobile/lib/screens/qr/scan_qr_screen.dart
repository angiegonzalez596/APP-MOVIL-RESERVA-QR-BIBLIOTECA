import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/qr_service.dart';
import '../vigilante/locker_grid_screen.dart';

class ScanQrScreen extends StatefulWidget {
  const ScanQrScreen({super.key});

  @override
  State<ScanQrScreen> createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends State<ScanQrScreen> {
  final QrService _qrService = QrService();
  final MobileScannerController _cameraController = MobileScannerController();

  bool _procesando = false;

  Future<void> _validarQr(String codigoQr) async {
    if (_procesando) return;

    setState(() {
      _procesando = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final vigilanteId = prefs.getInt('user_id');

    if (vigilanteId == null) {
      setState(() => _procesando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se encontró sesión del vigilante'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final response = await _qrService.scanQr(codigoQr, vigilanteId);

    if (!mounted) return;

    if (response['acceso'] != true) {
      setState(() {
        _procesando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['error'] ?? 'QR inválido'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final reservaId =
        response['reserva_id']?.toString() ??
        response['reserva']?['id']?.toString();

    if (reservaId == null) {
      setState(() {
        _procesando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo obtener la reserva del QR'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final estudiante = response['usuario']?['nombre'] ?? 'Estudiante';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('QR validado'),
        content: Text(
          'Estudiante: $estudiante\nReserva: #$reservaId',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _procesando = false);
            },
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => LockerGridScreen(reservaId: reservaId),
                ),
              );
            },
            child: const Text('Seleccionar locker'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Escanear QR')),
      body: Stack(
        children: [
          MobileScanner(
            controller: _cameraController,
            onDetect: (capture) {
              for (final barcode in capture.barcodes) {
                final value = barcode.rawValue;
                if (value != null && !_procesando) {
                  _validarQr(value);
                  break;
                }
              }
            },
          ),
          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 3),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          if (_procesando) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
