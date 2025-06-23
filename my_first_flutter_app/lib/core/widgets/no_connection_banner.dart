import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Shows a fallback UI when there's no internet connection
class NoConnectionApp extends StatefulWidget {
  const NoConnectionApp({super.key});

  @override
  State<NoConnectionApp> createState() => _NoConnectionAppState();
}

class _NoConnectionAppState extends State<NoConnectionApp> {
  // Indicates if a retry is in progress
  bool _checking = false;

  // Stores error message if retry fails
  String? _error;

  // Attempts to check the connection again
  Future<void> _retry() async {
    setState(() {
      _checking = true;
      _error = null;
    });

    final result = await Connectivity().checkConnectivity();

    // If reconnected, force reassemble the app (like hot reload)
    if (result.contains(ConnectivityResult.none)) {
      WidgetsBinding.instance.performReassemble();
    } else {
      // Still no connection, show error
      setState(() {
        _checking = false;
        _error = 'Noch keine Verbindung vorhanden.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.wifi_off, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'Keine Internetverbindung\nBitte überprüfe dein Netzwerk.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 24),
                // Show loader or retry button
                if (_checking)
                  const CircularProgressIndicator()
                else
                  ElevatedButton.icon(
                    onPressed: _retry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Erneut versuchen'),
                  ),
                // Show error if retry failed
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}
