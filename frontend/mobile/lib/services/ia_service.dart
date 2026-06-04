import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'api_config.dart';

class IaService {
  Future<Map<String, dynamic>> consultarIA(String pregunta) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/ia/recomendacion'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'usuario_id': userId, 'pregunta': pregunta}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return data;
      }

      return {
        'error': data['error'] ?? 'Error consultando IA',
        'detalle': data['detalle'],
      };
    } catch (e) {
      return {'error': 'Error de conexión: $e'};
    }
  }
}
