import 'package:flutter/material.dart';
import 'dart:async';
import '../routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  // const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();

    Timer(const Duration(seconds: 5), () {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center, // centre le contenu verticalement
                children: [
                  Image.asset(
                    'assets/images/logoAelite.jpg',
                    width: 200, // adapte à ton besoin
                    height: 200,
                  ),
                  SizedBox(height: 15), // espace entre image et loader
                  CircularProgressIndicator(), // barre de chargement
                ],
              ),
              // Container(
              //   width: MediaQuery.of(context).size.width,
              //   height: MediaQuery.of(context).size.height,
              //   color: Colors.black,
              //   child: Image.asset(
              //     'assets/images/logoAelite.jpg',
              //     fit: BoxFit.fill,
              //     width: double.infinity,
              //   ),
              // ),
            );
          },
        ),
      ),
    );
  }
}
