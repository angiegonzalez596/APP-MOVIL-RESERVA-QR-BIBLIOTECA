import 'dart:convert';
import 'package:http/http.dart' as http;

class IaService {
  static const String baseUrl = 'http://127.0.0.1:5000';

  Future<Map<String, dynamic>> consultarIA(String pregunta) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/ia/recomendacion'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'usuario_id': 1, 'pregunta': pregunta}),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    }

    throw Exception('Error consultando IA');
  }
}
