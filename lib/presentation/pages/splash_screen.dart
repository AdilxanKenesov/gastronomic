import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/services/connectivity_service.dart';
import 'intro_screen.dart';
import 'main_screen.dart';

class SplashScreen extends StatelessWidget {
  final SharedPreferences prefs;
  final ConnectivityService connectivityService;

  const SplashScreen({
    super.key,
    required this.prefs,
    required this.connectivityService,
  });

  Future<Widget> _decideStartScreen() async {
    final hasSeenIntro = prefs.getBool('has_seen_intro') ?? false;

    if (hasSeenIntro) {
      return const MainScreen();
    } else {
      return IntroScreen(prefs: prefs);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _decideStartScreen(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: SizedBox.shrink(),
          );
        }

        return snapshot.data!;
      },
    );
  }
}