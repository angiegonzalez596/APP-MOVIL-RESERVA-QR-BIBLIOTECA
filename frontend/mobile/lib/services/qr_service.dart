import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class QrService {
  final String baseUrl = "${ApiConfig.baseUrl}/qr";

  Future<Map<String, dynamic>> generateQr(int userId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/generate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'usuario_id': userId,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {
        'error': 'Error de conexión: $e',
      };
    }
  }

  Future<Map<String, dynamic>> scanQr(
    String qrCode,
    int vigilanteId,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/scan'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'qr_code': qrCode,
          'vigilante_id': vigilanteId,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {
        'error': 'Error de conexión: $e',
      };
    }
  }
}