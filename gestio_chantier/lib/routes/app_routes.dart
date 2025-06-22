import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/home_screen.dart';
import '../screens/chantier_screen.dart';
import '../screens/login_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String chantier = '/chantier';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      splash: (context) => const SplashScreen(),
      login: (context) => const LoginPage(),
      home: (context) => const HomeScreen(),
      chantier: (context) => const ChantierScreen(nomChantier: ''),
    };
  }
}
