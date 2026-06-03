import 'dart:convert';
import 'package:http/http.dart' as http;

class ReporteService {
  static const String baseUrl = 'http://127.0.0.1:5000';

  Future<Map<String, dynamic>> obtenerResumen() async {
    final response = await http.get(Uri.parse('$baseUrl/api/reportes/resumen'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception('Error al obtener reportes');
  }
}
