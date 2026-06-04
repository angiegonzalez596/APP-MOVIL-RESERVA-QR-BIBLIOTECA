import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/auth_service.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authService = AuthService();

  String _nombre = '';
  String _email = '';
  String _rol = '';
  String _userId = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _userId = prefs.getInt('user_id')?.toString() ?? 'N/A';
      _nombre = prefs.getString('user_name') ?? 'N/A';
      _email = prefs.getString('user_email') ?? 'N/A';
      _rol = prefs.getString('user_rol') ?? 'N/A';
    });
  }

  Future<void> _logout() async {
    await _authService.logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  Future<void> _editarPerfil() async {
    final nombreController = TextEditingController(text: _nombre);
    final emailController = TextEditingController(text: _email);

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Editar perfil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Correo',
                prefixIcon: Icon(Icons.email),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final userId = int.tryParse(_userId);

              if (userId == null) {
                Navigator.pop(context);
                return;
              }

              final result = await _authService.actualizarPerfil(
                userId: userId,
                nombre: nombreController.text.trim(),
                email: emailController.text.trim(),
              );

              if (!mounted) return;

              Navigator.pop(context);

              if (result.containsKey('error')) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(result['error']),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              await _loadUserData();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Perfil actualizado'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    nombreController.dispose();
    emailController.dispose();
  }

  String _rolTexto(String rol) {
    switch (rol.toUpperCase()) {
      case 'ESTUDIANTE':
        return 'Estudiante';
      case 'VIGILANTE':
        return 'Vigilante';
      case 'ADMIN':
        return 'Administrador';
      default:
        return rol;
    }
  }

  IconData _rolIcono(String rol) {
    switch (rol.toUpperCase()) {
      case 'ESTUDIANTE':
        return Icons.school;
      case 'VIGILANTE':
        return Icons.security;
      case 'ADMIN':
        return Icons.admin_panel_settings;
      default:
        return Icons.person;
    }
  }

  Widget _infoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFC62828), size: 30),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String text,
    required VoidCallback onPressed,
    bool danger = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: danger
          ? OutlinedButton.icon(
              onPressed: onPressed,
              icon: Icon(icon),
              label: Text(text),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFC62828),
                side: const BorderSide(color: Color(0xFFC62828)),
              ),
            )
          : ElevatedButton.icon(
              onPressed: onPressed,
              icon: Icon(icon),
              label: Text(text),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rolLegible = _rolTexto(_rol);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        actions: [
          IconButton(
            tooltip: 'Editar perfil',
            onPressed: _editarPerfil,
            icon: const Icon(Icons.edit),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFC62828), width: 3),
              ),
              child: CircleAvatar(
                radius: 58,
                backgroundColor: const Color(0xFFF5F5F5),
                child: Icon(
                  _rolIcono(_rol),
                  size: 70,
                  color: const Color(0xFFC62828),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _nombre,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Chip(
              label: Text(rolLegible),
              backgroundColor: const Color(0xFFC62828).withOpacity(0.12),
              labelStyle: const TextStyle(color: Color(0xFFC62828)),
            ),
            const SizedBox(height: 28),

            _infoTile(
              icon: Icons.badge,
              label: 'ID de usuario',
              value: _userId,
            ),
            _infoTile(
              icon: Icons.person,
              label: 'Nombre completo',
              value: _nombre,
            ),
            _infoTile(
              icon: Icons.email,
              label: 'Correo electrónico',
              value: _email,
            ),
            _infoTile(icon: _rolIcono(_rol), label: 'Rol', value: rolLegible),

            const SizedBox(height: 20),

            _actionButton(
              icon: Icons.edit,
              text: 'Editar perfil',
              onPressed: _editarPerfil,
            ),
            const SizedBox(height: 12),
            _actionButton(
              icon: Icons.logout,
              text: 'Cerrar sesión',
              onPressed: _logout,
              danger: true,
            ),
          ],
        ),
      ),
    );
  }
}
