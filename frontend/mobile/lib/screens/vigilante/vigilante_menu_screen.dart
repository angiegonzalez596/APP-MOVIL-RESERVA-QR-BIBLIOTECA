import 'package:flutter/material.dart';
import 'scan_qr_screen.dart';
import 'registrar_salida_screen.dart';

class VigilanteMenuScreen extends StatelessWidget {
  const VigilanteMenuScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo de AccessBook
                Image.asset(
                  'assets/logo.png',
                  height: 80,
                  errorBuilder: (context, error, stackTrace) {
                    return const Text(
                      "AccessBook",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 60),

                // 🟢 Botón 1: Registrar Usuario (Ingreso)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(
                        0xFF7CFF2B,
                      ), // El verde brillante de tu Figma
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ScanQrScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      "Registrar Usuario",
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // 🟢 Botón 2: Registrar Salida (Liberación) - ¡ACTUALIZADO!
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
                    onPressed: () {
                      // 🚀 Aquí ya se conecta directamente a la pantalla del formulario
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegistrarSalidaScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      "Registrar salida",
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 80),

                // Labels inferiores simulando tu diseño
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        "Label",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        "Label",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
