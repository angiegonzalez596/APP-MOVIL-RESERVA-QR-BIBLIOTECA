import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class HistorialIaService {
  final String baseUrl = ApiConfig.baseUrl;

  Future<List<dynamic>> obtenerHistorial() async {
    final response = await http.get(Uri.parse('$baseUrl/ia/historial'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception('Error al obtener historial');
  }
}
