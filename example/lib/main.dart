import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_device_id/flutter_secure_device_id.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _deviceId = 'Unknown';

  @override
  void initState() {
    super.initState();
    _fetchId();
  }

  Future<void> _fetchId() async {
    try {
      final id = await FlutterSecureDeviceId.getDeviceId();
      if (!mounted) return;
      setState(() {
        _deviceId = id;
      });
    } on PlatformException catch (e) {
      if (!mounted) return;
      setState(() {
        _deviceId = 'Error: ${e.message}';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _deviceId = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Secure Device ID Example'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Device ID:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                SelectableText(
                  _deviceId,
                  style: const TextStyle(fontSize: 14, fontFamily: 'monospace'),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _fetchId,
                  child: const Text('Refresh'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
