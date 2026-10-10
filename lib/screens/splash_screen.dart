import 'dart:async';

import 'package:flutter/material.dart';

import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController animationController;
  late AnimationController fadeOutController;

  late Animation<double> logoScale;
  late Animation<double> logoOpacity;
  late Animation<double> textOpacity;
  late Animation<double> fadeOutOpacity;

  Timer? splashTimer;
  Timer? loginTimer;

  @override
  void initState() {
    super.initState();

    // Intro animation
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    // Outro fade animation
    fadeOutController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    logoScale = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.easeOutBack,
      ),
    );

    logoOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: animationController,
        curve: const Interval(
          0.0,
          0.65,
          curve: Curves.easeIn,
        ),
      ),
    );

    textOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: animationController,
        curve: const Interval(
          0.45,
          1.0,
          curve: Curves.easeIn,
        ),
      ),
    );

    fadeOutOpacity = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: fadeOutController,
        curve: Curves.easeInOut,
      ),
    );

    animationController.forward();

    // Wait before starting the outro
    splashTimer = Timer(
      const Duration(milliseconds: 2600),
      startFadeOut,
    );
  }

  void startFadeOut() {
    if (!mounted) return;

    fadeOutController.forward();

    // Wait for the fade-out to finish
    loginTimer = Timer(
      const Duration(milliseconds: 900),
      goToLogin,
    );
  }

  void goToLogin() {
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        reverseTransitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (
          context,
          animation,
          secondaryAnimation,
        ) =>
            const LoginScreen(),
        transitionsBuilder: (
          context,
          animation,
          secondaryAnimation,
          child,
        ) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    splashTimer?.cancel();
    loginTimer?.cancel();

    animationController.dispose();
    fadeOutController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color maroon = Color(0xFF800000);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: fadeOutOpacity,
          child: AnimatedBuilder(
            animation: animationController,
            builder: (context, child) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FadeTransition(
                    opacity: logoOpacity,
                    child: ScaleTransition(
                      scale: logoScale,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: maroon.withValues(alpha: 0.15),
                              blurRadius: 25,
                              spreadRadius: 3,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Image.asset(
                          'assets/studycircle_icon.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  FadeTransition(
                    opacity: textOpacity,
                    child: const Text(
                      'StudyCircle',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: maroon,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  FadeTransition(
                    opacity: textOpacity,
                    child: const Text(
                      'Study together. Learn together.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}