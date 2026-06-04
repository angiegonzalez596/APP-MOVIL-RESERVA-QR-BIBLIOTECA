import 'dart:convert';
import 'package:http/http.dart' as http;

import 'api_config.dart';

class HistorialIaService {
  Future<List<dynamic>> obtenerHistorial() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/ia/historial'),
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
