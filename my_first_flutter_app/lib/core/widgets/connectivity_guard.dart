import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'no_connection_banner.dart';

/// Wraps a widget and listens for connectivity changes
/// Shows a fallback UI if there's no internet connection
class ConnectivityGuard extends StatefulWidget {
  final Widget child;

  const ConnectivityGuard({super.key, required this.child});

  @override
  State<ConnectivityGuard> createState() => _ConnectivityGuardState();
}

class _ConnectivityGuardState extends State<ConnectivityGuard> {
  // Stream für gemappte ConnectivityResult-Werte
  late final Stream<ConnectivityResult> _stream;

  // Tracks whether the device currently has a connection
  bool _hasConnection = true;

  @override
  void initState() {
    super.initState();

    // Ursprünglichen Stream<List<ConnectivityResult>> mappen auf ConnectivityResult
    _stream = Connectivity()
        .onConnectivityChanged
        .map((results) =>
    // Nimm ersten Nicht-none-Status, falls keiner vorhanden, dann none
    results.firstWhere(
          (r) => r != ConnectivityResult.none,
      orElse: () => ConnectivityResult.none,
    ));

    // Auf gemappte Statusänderungen hören
    _stream.listen((status) {
      final connected = status != ConnectivityResult.none;

      if (connected != _hasConnection) {
        setState(() => _hasConnection = connected);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Zeige Kind-Widget, wenn verbunden; sonst Fallback
    return _hasConnection ? widget.child : const NoConnectionApp();
  }
}
