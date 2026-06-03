import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'locker_grid_screen.dart'; // 💡 Esta será la pantalla de los casilleros con ✅ y ❌

class ScanQrScreen extends StatefulWidget {
  const ScanQrScreen({Key? key}) : super(key: key);

  @override
  State<ScanQrScreen> createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends State<ScanQrScreen> {
  // Controlador para apagar la cámara al salir de la pantalla
  final MobileScannerController cameraController = MobileScannerController();
  bool _isScanCompleted =
      false; // Evita que se escanee el mismo código mil veces seguidas

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
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
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text(
              "Cerrar Sesión",
              style: TextStyle(
                color: Colors.black,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Image.asset(
              'assets/images/logo_unilibre.png',
              height: 80,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 20),

            const Text(
              "Leer Código QR",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
            ),
            const Text(
              "(Acerque la cámara de su teléfono)",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 30),

            // 📷 CONTENEDOR DE LA CÁMARA (Círculo de tu diseño)
            Center(
              child: ClipOval(
                child: SizedBox(
                  width: 240,
                  height: 240,
                  child: MobileScanner(
                    controller: cameraController,
                    onDetect: (capture) {
                      if (!_isScanCompleted) {
                        final List<Barcode> barcodes = capture.barcodes;

                        for (final barcode in barcodes) {
                          if (barcode.rawValue != null) {
                            setState(() {
                              _isScanCompleted = true; // Pausa detecciones
                            });

                            final String qrData = barcode.rawValue!;
                            print('Código QR detectado: $qrData');

                            // 🚀 Salto automático al mapa de casilleros pasando el dato del QR
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    LockerGridScreen(reservaId: qrData),
                              ),
                            ).then((_) {
                              // Al regresar a esta pantalla, reactiva el escáner
                              setState(() {
                                _isScanCompleted = false;
                              });
                            });
                            break;
                          }
                        }
                      }
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),

            // 🟢 Botón inferior para forzar o simular la carga si la cámara no está lista
            SizedBox(
              width: 200,
              height: 45,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7CFF2B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                onPressed: () {
                  // Botón de contingencia por si se prueba en emulador sin cámara física
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LockerGridScreen(
                        reservaId: "2",
                      ), // "2" es el ID de tus pruebas exitosas
                    ),
                  );
                },
                child: const Text(
                  "Mostrar casilleros\nDisponibles",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black, fontSize: 14),
                ),
              ),
            ),

            const Spacer(),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40.0),
              child: Text(
                "Reducción de filas y tiempos de espera\nControl en tiempo real de casilleros",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
