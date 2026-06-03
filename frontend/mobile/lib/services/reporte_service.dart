import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class ReporteService {
  final String baseUrl = ApiConfig.baseUrl;


  Future<Map<String, dynamic>> obtenerResumen() async {
    final response = await http.get(Uri.parse('$baseUrl/reportes/resumen'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception('Error al obtener reportes');
  }
}
