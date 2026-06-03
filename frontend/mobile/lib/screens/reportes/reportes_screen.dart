import 'package:flutter/material.dart';
import '../../services/reporte_service.dart';

class ReportesScreen extends StatefulWidget {
  const ReportesScreen({super.key});

  @override
  State<ReportesScreen> createState() => _ReportesScreenState();
}

class _ReportesScreenState extends State<ReportesScreen> {
  final ReporteService service = ReporteService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Administración'),
        backgroundColor: const Color(0xFFC62828),
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder(
        future: service.obtenerResumen(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final data = snapshot.data!;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _sectionTitle('Resumen General'),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 1.5,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                children: [
                  _infoCard('Usuarios', data["usuarios"]["total"].toString(), Icons.people, Colors.blue),
                  _infoCard('Ingresos', data["ingresos"]["total"].toString(), Icons.login, Colors.green),
                  _infoCard('Reservas', data["reservas"]["total"].toString(), Icons.bookmark, Colors.orange),
                  _infoCard('Consultas IA', data["ia"]["total_consultas"].toString(), Icons.smart_toy, Colors.purple),
                ],
              ),
              
              const SizedBox(height: 24),
              _sectionTitle('Estado de Lockers'),
              Row(
                children: [
                  Expanded(child: _infoCard('Disponibles', data["lockers"]["disponibles"].toString(), Icons.lock_open, Colors.green)),
                  const SizedBox(width: 10),
                  Expanded(child: _infoCard('Ocupados', data["lockers"]["ocupados"].toString(), Icons.lock, Colors.red)),
                ],
              ),

              const SizedBox(height: 24),
              _sectionTitle('Últimos Ingresos a Biblioteca'),
              ...((data["ingresos"]["recientes"] as List).map((ing) => ListTile(
                leading: const Icon(Icons.person_outline),
                title: Text(ing["estudiante"]),
                subtitle: Text(ing["fecha"].split('T')[0] + ' ' + ing["fecha"].split('T')[1].substring(0, 5)),
                trailing: Text('Vig: ${ing["vigilante"]}', style: const TextStyle(fontSize: 10)),
              ))),

              const SizedBox(height: 24),
              _sectionTitle('Tendencias en IA Panda'),
              ...((data["ia"]["busquedas_recientes"] as List).map((ia) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(ia["pregunta"], style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(ia["respuesta_corta"], style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
              ))),
            ],
          );
        },
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFC62828)),
      ),
    );
  }

  Widget _infoCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
