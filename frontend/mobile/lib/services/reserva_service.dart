import 'dart:convert';
import 'package:http/http.dart' as http;

class ReservaService {
  // 💡 Base URL unificada para el proyecto
  static const String baseUrl = 'http://10.0.2.2:5000/api';

  // 🟢 MÉTODO 1: Asignar locker al ingresar (QR)
  static Future<bool> registrarIngreso(String reservaId, int lockerId) async {
    try {
      final url = Uri.parse('$baseUrl/reservas/registrar-ingreso');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'reserva_id': reservaId, 'locker_id': lockerId}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        print('Error en el servidor: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error de red al registrar ingreso: $e');
      return false;
    }
  }

  // 🔴 MÉTODO 2: Liberar locker al salir (Digitado) - ¡AHORA DENTRO DE LA CLASE!
  static Future<bool> registrarSalida(int lockerId) async {
    try {
      final url = Uri.parse('$baseUrl/reservas/finalizar-por-locker');

      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'locker_id': lockerId}),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Error del servidor al liberar locker: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error de red al registrar salida: $e');
      return false;
    }
  }
} // 👈 Esta última llave cierra TODA la clase y protege ambos métodos
