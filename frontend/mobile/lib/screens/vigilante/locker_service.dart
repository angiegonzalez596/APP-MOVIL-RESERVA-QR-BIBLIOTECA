import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../services/api_config.dart';

class LockerService {
  static final String baseUrl = '${ApiConfig.baseUrl}/lockers';

  // Función para traer únicamente los casilleros libres de la base de datos
  static Future<List<dynamic>> obtenerDisponibles() async {
    final url = Uri.parse('$baseUrl/disponibles');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return jsonDecode(response.body); // Devuelve la lista de lockers libres
      } else {
        print("Error al obtener lockers: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Error de conexión en LockerService: $e");
      return [];
    }
  }
}
