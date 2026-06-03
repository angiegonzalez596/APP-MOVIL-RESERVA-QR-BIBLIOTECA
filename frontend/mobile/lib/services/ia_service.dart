import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';

class IaService {
  final String baseUrl = ApiConfig.baseUrl;

  Future<Map<String, dynamic>> consultarIA(String pregunta) async {
    final prefs = await SharedPreferences.getInstance();
    final int? userId = prefs.getInt('user_id');

    final response = await http.post(
      Uri.parse('$baseUrl/ia/recomendacion'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'usuario_id': userId ?? 0,
        'pregunta': pregunta,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception('Error consultando IA');
  }
}
