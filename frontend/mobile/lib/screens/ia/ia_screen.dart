import 'package:flutter/material.dart';
import '../../services/ia_service.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'historial_screen.dart';

class IaScreen extends StatefulWidget {
  const IaScreen({super.key});

  @override
  State<IaScreen> createState() => _IaScreenState();
}

class _IaScreenState extends State<IaScreen> {
  final TextEditingController controller = TextEditingController();

  String respuesta = '';

  bool loading = false;

  final IaService service = IaService();

  Future<void> consultar() async {
    if (controller.text.isEmpty) return;

    setState(() {
      loading = true;
    });

    try {
      final result = await service.consultarIA(controller.text);

      setState(() {
        respuesta = result['respuesta'];
      });
    } catch (e) {
      setState(() {
        respuesta = 'Error consultando IA';
      });
    }

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asistente IA'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistorialScreen()),
              );
            },
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Pregunta',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: consultar,
              child: const Text('Consultar'),
            ),

            const SizedBox(height: 24),

            if (loading) const CircularProgressIndicator(),

            if (!loading)
              Expanded(
                child: SingleChildScrollView(
                  child: MarkdownBody(data: respuesta),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
