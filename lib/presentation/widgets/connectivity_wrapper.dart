import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/services/connectivity_service.dart';
import 'no_internet_screen.dart';

class ConnectivityWrapper extends StatefulWidget {
  final Widget child;
  final ConnectivityService connectivityService;

  const ConnectivityWrapper({
    super.key,
    required this.child,
    required this.connectivityService,
  });

  @override
  State<ConnectivityWrapper> createState() => _ConnectivityWrapperState();
}

class _ConnectivityWrapperState extends State<ConnectivityWrapper> {
  late StreamSubscription<bool> _connectivitySubscription;
  bool _isConnected = true;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initConnectivity();
  }

  Future<void> _initConnectivity() async {
    // Boshlang'ich holatni tekshirish
    final isConnected = await widget.connectivityService.checkConnectivity();

    if (mounted) {
      setState(() {
        _isConnected = isConnected;
        _isInitialized = true;
      });
    }

    // Connectivity o'zgarishlarini kuzatish
    _connectivitySubscription = widget.connectivityService.connectivityStream.listen(
      (isConnected) {
        if (mounted && _isConnected != isConnected) {
          setState(() {
            _isConnected = isConnected;
          });
        }
      },
    );
  }

  Future<void> _onRetry() async {
    final isConnected = await widget.connectivityService.checkConnectivity();
    if (mounted) {
      setState(() {
        _isConnected = isConnected;
      });
    }
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Initialization davomida loading ko'rsatmaymiz - child ni ko'rsatamiz
    if (!_isInitialized) {
      return widget.child;
    }

    // Internet yo'q bo'lsa NoInternetScreen ko'rsatamiz
    if (!_isConnected) {
      return NoInternetScreen(onRetry: _onRetry);
    }

    return widget.child;
  }
}