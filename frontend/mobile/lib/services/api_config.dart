import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConfig {
  // 1. Cambia esta IP por la que muestra el backend al iniciar (en la consola)
  static const String _pcIp = "192.168.1.7"; 

  static String get baseUrl {
    // Si es Android Emulator, usa 10.0.2.2 automáticamente
    if (!kIsWeb && Platform.isAndroid) {
      // Nota: Esta lógica solo detecta si es Android, no si es específicamente el emulador.
      // Pero para desarrollo físico se prefiere usar la IP del PC.
      // return "http://10.0.2.2:5000/api"; 
    }
    
    // Por defecto usa la IP configurada
    return "http://$_pcIp:5000/api";
  }
}
