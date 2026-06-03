import 'package:flutter/material.dart';
import '../../services/qr_service.dart';

class ScanQrScreen extends StatefulWidget {
  const ScanQrScreen({super.key});

  @override
  State<ScanQrScreen> createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends State<ScanQrScreen> {
  final TextEditingController qrController = TextEditingController();

  final QrService service = QrService();

  String resultado = '';

  bool loading = false;

  Future<void> validarQr() async {
    if (qrController.text.isEmpty) return;

    setState(() {
      loading = true;
    });

    try {
      final response = await service.validarQr(
        qrController.text,
        3, // vigilante creado anteriormente
      );

      setState(() {
        if (response["acceso"] == true) {
          resultado =
              "Acceso permitido\n\nUsuario: ${response["usuario"]["nombre"]}";
        } else {
          resultado = "Acceso denegado\n\n${response["error"]}";
        }
      });
    } catch (e) {
      setState(() {
        resultado = "Error validando QR";
      });
    }

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Validación QR')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: qrController,
              decoration: const InputDecoration(
                labelText: 'Código QR',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            ElevatedButton(onPressed: validarQr, child: const Text('Validar')),

            const SizedBox(height: 24),

            if (loading) const CircularProgressIndicator(),

            if (!loading)
              Expanded(
                child: SingleChildScrollView(
                  child: Text(resultado, style: const TextStyle(fontSize: 18)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
