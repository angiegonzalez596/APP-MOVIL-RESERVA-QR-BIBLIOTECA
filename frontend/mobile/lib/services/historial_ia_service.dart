import 'dart:convert';
import 'package:http/http.dart' as http;

class HistorialIaService {
  static const String baseUrl = 'http://127.0.0.1:5000';

  Future<List<dynamic>> obtenerHistorial() async {
    final response = await http.get(Uri.parse('$baseUrl/api/ia/historial'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception('Error al obtener historial');
  }
}
