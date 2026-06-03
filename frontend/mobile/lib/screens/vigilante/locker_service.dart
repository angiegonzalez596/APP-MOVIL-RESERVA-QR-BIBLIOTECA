import 'dart:convert';
import 'package:http/http.dart' as http;

class LockerService {
  // 💡 Recuerda colocar la IP de tu máquina aquí
  static const String baseUrl = 'http://192.168.1.X:5000/api/lockers';

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
