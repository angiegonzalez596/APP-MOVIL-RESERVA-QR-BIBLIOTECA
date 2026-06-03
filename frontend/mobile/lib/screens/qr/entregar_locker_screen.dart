import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../services/reserva_service.dart';

class EntregarLockerScreen extends StatefulWidget {
  const EntregarLockerScreen({super.key});

  @override
  State<EntregarLockerScreen> createState() => _EntregarLockerScreenState();
}

class _EntregarLockerScreenState extends State<EntregarLockerScreen> {
  final AudioPlayer audioPlayer = AudioPlayer();
  bool loading = false;
  int? _userId;
  bool _isScanCompleted = false;
  MobileScannerController cameraController = MobileScannerController();

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('user_id');
    });
  }

  Future<void> _playBeep() async {
    try {
      await audioPlayer.play(UrlSource('https://www.soundjay.com/buttons/beep-07.mp3'));
    } catch (e) {
      debugPrint("Error al reproducir sonido: $e");
    }
  }

  Future<void> procesarEntrega(String codigoLocker) async {
    if (_userId == null || _isScanCompleted) return;

    // Validar que el código sea de un locker
    if (!codigoLocker.startsWith("LOCKER-")) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Este no es un código de locker válido")),
      );
      return;
    }

    await _playBeep();

    setState(() {
      _isScanCompleted = true;
      loading = true;
    });

    try {
      final response = await ReservaService.finalizarPorLocker(codigoLocker, _userId!);

      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text(response.containsKey("error") ? "❌ Error" : "✅ Locker Entregado"),
          content: Text(response["message"] ?? response["error"]),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Cerrar diálogo
                if (!response.containsKey("error")) {
                  Navigator.pop(context); // Volver al inicio
                } else {
                  setState(() {
                    _isScanCompleted = false;
                    loading = false;
                  });
                }
              },
              child: const Text("Aceptar"),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Error de conexión")),
      );
      setState(() {
        _isScanCompleted = false;
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Abrir y Entregar Locker'),
        backgroundColor: const Color(0xFFC62828),
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null && !_isScanCompleted) {
                  procesarEntrega(barcode.rawValue!);
                }
              }
            },
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Escanea el QR del Locker para ABRIRLO',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFC62828), width: 4),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                const SizedBox(height: 20),
                const Icon(Icons.lock_open, color: Colors.white, size: 50),
              ],
            ),
          ),
          if (loading)
            const Center(
              child: CircularProgressIndicator(color: Color(0xFFC62828)),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    audioPlayer.dispose();
    super.dispose();
  }
}
