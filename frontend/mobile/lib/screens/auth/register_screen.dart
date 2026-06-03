import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _documentoController = TextEditingController();
  final _codigoEstudianteController = TextEditingController();
  String _rol = 'ESTUDIANTE';
  final _authService = AuthService();
  bool _isLoading = false;

  void _register() async {
    setState(() => _isLoading = true);
    final result = await _authService.register({
      'nombre': _nombreController.text.trim(),
      'email': _emailController.text.trim(),
      'password': _passwordController.text.trim(),
      'documento': _documentoController.text.trim(),
      'codigo_estudiante': _rol == 'ESTUDIANTE' ? _codigoEstudianteController.text.trim() : null,
      'rol': _rol,
    });
    setState(() => _isLoading = false);

    if (result.containsKey('message')) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'])),
        );
        Navigator.pop(context);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['error'] ?? 'Error al registrarse')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nombreController,
              decoration: const InputDecoration(labelText: 'Nombre Completo'),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            TextField(
              controller: _documentoController,
              decoration: const InputDecoration(labelText: 'Documento'),
            ),
            DropdownButtonFormField<String>(
              value: _rol,
              items: ['ESTUDIANTE', 'VIGILANTE']
                  .map((rol) => DropdownMenuItem(value: rol, child: Text(rol)))
                  .toList(),
              onChanged: (val) => setState(() => _rol = val!),
              decoration: const InputDecoration(labelText: 'Rol'),
            ),
            if (_rol == 'ESTUDIANTE')
              TextField(
                controller: _codigoEstudianteController,
                decoration: const InputDecoration(labelText: 'Código Estudiante'),
              ),
            const SizedBox(height: 24),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _register,
                    child: const Text('Registrarse'),
                  ),
          ],
        ),
      ),
    );
  }
}
