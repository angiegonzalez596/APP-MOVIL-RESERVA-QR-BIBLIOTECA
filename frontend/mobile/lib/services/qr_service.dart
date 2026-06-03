import 'dart:convert';
import 'package:http/http.dart' as http;

class QrService {
  static const String baseUrl = 'http://127.0.0.1:5000';

  Future<Map<String, dynamic>> validarQr(String qrCode, int vigilanteId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/qr/scan'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'qr_code': qrCode, 'vigilante_id': vigilanteId}),
    );

    return jsonDecode(response.body);
  }
}
