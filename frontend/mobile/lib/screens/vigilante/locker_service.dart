import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../services/api_config.dart';

class LockerService {
  static String get baseUrl => ApiConfig.baseUrl;

  static Future<List<dynamic>> obtenerDisponibles() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/lockers/disponibles'),
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

  static Future<List<dynamic>> obtenerTodos() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/lockers/'),
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
