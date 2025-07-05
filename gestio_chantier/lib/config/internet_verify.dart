import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectionOverlayWatcher extends StatefulWidget {
  final Widget child;

  const ConnectionOverlayWatcher({super.key, required this.child});

  @override
  State<ConnectionOverlayWatcher> createState() =>
      _ConnectionOverlayWatcherState();
}

class _ConnectionOverlayWatcherState extends State<ConnectionOverlayWatcher> {
  late final StreamSubscription<List<ConnectivityResult>> _subscription;
  bool _isDisconnected = false;

  @override
  void initState() {
    super.initState();

    _subscription = Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      setState(() {
        _isDisconnected =
            results.isEmpty || results.contains(ConnectivityResult.none);
      });
    });

    // Vérifie immédiatement à l'ouverture
    _initialCheck();
  }

  Future<void> _initialCheck() async {
    final result = await Connectivity().checkConnectivity();
    setState(() {
      // ignore: unrelated_type_equality_checks
      _isDisconnected = result == ConnectivityResult.none;
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child, // ta page actuelle
        // Overlay affiché si pas de connexion
        if (_isDisconnected)
          Positioned.fill(
            child: Container(
              color: Colors.black.withAlpha((0.6 * 255).toInt()),
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.wifi_off, color: Colors.white, size: 60),
                  SizedBox(height: 16),
                  Text(
                    "Pas de connexion Internet",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
