import 'package:flutter/material.dart';
import '../../services/reserva_service.dart';
import 'vigilante_menu_screen.dart';

class RegistrarSalidaScreen extends StatefulWidget {
  const RegistrarSalidaScreen({Key? key}) : super(key: key);

  @override
  State<RegistrarSalidaScreen> createState() => _RegistrarSalidaScreenState();
}

class _RegistrarSalidaScreenState extends State<RegistrarSalidaScreen> {
  final TextEditingController _lockerController = TextEditingController();
  bool _estaCargando = false;

  @override
  void dispose() {
    _lockerController.dispose();
    super.dispose();
  }

  void _procesarSalida() async {
    if (_lockerController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor ingrese el número del locker")),
      );
      return;
    }

    setState(() {
      _estaCargando = true;
    });

    int? lockerId = int.tryParse(_lockerController.text.trim());

    if (lockerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ingrese un número de casillero válido")),
      );
      setState(() {
        _estaCargando = false;
      });
      return;
    }

    // Llamamos al backend para liberar el casillero
    bool exito = await ReservaService.registrarSalida(lockerId);

    setState(() {
      _estaCargando = false;
    });

    if (exito) {
      // Mostrar confirmación visual estilo Figma ("El locker ### se encuentra ahora disponible")
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 60),
              const SizedBox(height: 20),
              Text(
                "El locker $lockerId se encuentra ahora disponible.",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Volver al menú principal limpiando la navegación
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const VigilanteMenuScreen(),
                  ),
                  (route) => false,
                );
              },
              child: const Text("Entendido"),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❌ Error: El locker no está ocupado o no existe."),
          backgroundColor: Colors.red,
        ),
      );
    }
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logo_unilibre.png',
                height: 80,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 40),
              const Text(
                "Registrar salida",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              const Text(
                "Ingrese el número del locker",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 15),

              // ⌨️ CAMPO DE TEXTO GRIS (Figma)
              TextField(
                controller: _lockerController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFD9D9D9),
                  hintText: '000',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // 🟢 BOTÓN: Registrar salida
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
                  onPressed: _estaCargando ? null : _procesarSalida,
                  child: _estaCargando
                      ? const CircularProgressIndicator(color: Colors.black)
                      : const Text(
                          "Registrar salida",
                          style: TextStyle(color: Colors.black, fontSize: 16),
                        ),
                ),
              ),
              const Spacer(),
              const Text(
                "Reducción de filas y tiempos de espera\nControl en tiempo real de casilleros",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
