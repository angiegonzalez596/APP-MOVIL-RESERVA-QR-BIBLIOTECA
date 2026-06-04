import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class ReservaService {
  static String get baseUrl => ApiConfig.baseUrl;

  static Future<Map<String, dynamic>> crearReserva(int usuarioId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reservas/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'usuario_id': usuarioId}),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'error': 'Error de conexión: $e'};
    }
  }

  static Future<bool> registrarIngreso(String reservaId, int lockerId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reservas/registrar-ingreso'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'reserva_id': reservaId, 'locker_id': lockerId}),
      );

      print('STATUS REGISTRAR INGRESO: ${response.statusCode}');
      print('BODY REGISTRAR INGRESO: ${response.body}');

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('ERROR REGISTRAR INGRESO: $e');
      return false;
    }
  }

  static Future<bool> registrarSalida(int lockerId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/reservas/finalizar-por-locker'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'locker_id': lockerId}),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<Map<String, dynamic>> finalizarPorLocker(
    String codigoLocker,
    int usuarioId,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reservas/finalizar-por-codigo-locker'),
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

  static Future<List<dynamic>> obtenerReservasUsuario(int usuarioId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reservas/usuario/$usuarioId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<List<dynamic>> obtenerReservas() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reservas/'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return [];
    } catch (_) {
      return [];
    }
  }
}
