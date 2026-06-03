import 'package:flutter/material.dart';
import '../../services/historial_ia_service.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  final HistorialIaService service = HistorialIaService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historial IA')),
      body: FutureBuilder(
        future: service.obtenerHistorial(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final historial = snapshot.data!;

          return ListView.builder(
            itemCount: historial.length,
            itemBuilder: (context, index) {
              final item = historial[index];

              return Card(
                margin: const EdgeInsets.all(10),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item["pregunta"],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),

                      const SizedBox(height: 8),
                      MarkdownBody(data: item["respuesta"]),
                      const SizedBox(height: 8),

                      Text(
                        item["fecha"],
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
