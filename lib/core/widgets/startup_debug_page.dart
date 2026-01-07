import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class StartupDebugPage extends StatelessWidget {
  final String? error;
  final VoidCallback onRetry;

  const StartupDebugPage({
    super.key,
    this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Startup Debug'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (error != null) ...[
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text(
                    'Database Initialization Failed',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Text(
                      error!,
                      style: const TextStyle(color: Colors.red, fontFamily: 'monospace'),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry Initialization'),
                  ),
                  const SizedBox(height: 32),
                  if (kIsWeb) ...[
                    const Divider(),
                    const SizedBox(height: 16),
                    const Text(
                      'Web Platform Troubleshooting:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '1. Open browser DevTools (F12)\n'
                      '2. Check Console for errors\n'
                      '3. Check Application > IndexedDB\n'
                      '4. Try clearing browser cache\n'
                      '5. Try a different browser',
                      textAlign: TextAlign.left,
                    ),
                  ],
                ] else ...[
                  const CircularProgressIndicator(),
                  const SizedBox(height: 24),
                  const Text(
                    'Initializing database...',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'This may take a few moments',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
