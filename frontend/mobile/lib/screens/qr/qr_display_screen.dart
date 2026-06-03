import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/qr_service.dart';

class QrDisplayScreen extends StatefulWidget {
  const QrDisplayScreen({super.key});

  @override
  State<QrDisplayScreen> createState() => _QrDisplayScreenState();
}

class _QrDisplayScreenState extends State<QrDisplayScreen> {
  final _qrService = QrService();
  String? _qrData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchQr();
  }

  void _fetchQr() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');

    if (userId == null) {
      setState(() {
        _error = "Sesión no iniciada";
        _isLoading = false;
      });
      return;
    }

    final result = await _qrService.generateQr(userId);

    if (result.containsKey('qr_code')) {
      setState(() {
        _qrData = result['qr_code'];
        _isLoading = false;
      });
    } else {
      setState(() {
        _error = result['error'] ?? "No tienes una reserva activa";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi Código QR')),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : _error != null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(onPressed: _fetchQr, child: const Text('Reintentar')),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Presenta este código al vigilante',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 24),
                      QrImageView(
                        data: _qrData!,
                        version: QrVersions.auto,
                        size: 250.0,
                      ),
                      const SizedBox(height: 24),
                      Text('Código: $_qrData'),
                    ],
                  ),
      ),
    );
  }
}
