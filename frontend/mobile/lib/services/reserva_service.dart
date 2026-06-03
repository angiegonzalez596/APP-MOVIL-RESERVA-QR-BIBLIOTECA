import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class ReservaService {
  static String get baseUrl => ApiConfig.baseUrl;

  // Registrar ingreso
  static Future<bool> registrarIngreso(
    String reservaId,
    int lockerId,
  ) async {
    try {
      final url = Uri.parse(
        '$baseUrl/reservas/registrar-ingreso',
      );

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'reserva_id': reservaId,
          'locker_id': lockerId,
        }),
      );

      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        return true;
      }

      print('Error servidor: ${response.body}');
      return false;
    } catch (e) {
      print('Error de red: $e');
      return false;
    }
  }

  // Registrar salida por QR de Locker
  static Future<Map<String, dynamic>> finalizarPorLocker(
    String codigoLocker,
    int usuarioId,
  ) async {
    try {
      final url = Uri.parse('$baseUrl/reservas/finalizar-por-codigo-locker');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'codigo_locker': codigoLocker,
          'usuario_id': usuarioId,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'error': 'Error de conexión: $e'};
    }
  }

  // Registrar salida
  static Future<bool> registrarSalida(
    int lockerId,
  ) async {
    try {
      final url = Uri.parse(
        '$baseUrl/reservas/finalizar-por-locker',
      );

      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'locker_id': lockerId,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      }

      print('Error servidor: ${response.body}');
      return false;
    } catch (e) {
      print('Error de red: $e');
      return false;
    }
  }
}