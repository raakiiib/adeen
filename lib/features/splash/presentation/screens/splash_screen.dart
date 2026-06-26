import 'dart:async';
import 'package:flutter/material.dart';
import 'package:adeen/core/theme/app_theme.dart';
import 'package:adeen/core/theme/islamic_painters.dart';
import 'package:adeen/core/localization/app_localizations.dart';
import 'package:adeen/main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    // Premium entrance animation config
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.75, curve: Curves.elasticOut),
      ),
    );

    _animationController.forward();

    // Smooth navigation after 2.6 seconds
    _navigationTimer = Timer(const Duration(milliseconds: 2600), _navigateToHome);
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _navigateToHome() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const MainNavigationHub(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0C2417), // Deep emerald green
              Color(0xFF05110B), // Near black emerald
            ],
          ),
        ),
        child: Stack(
          children: [
            // Elegant background geometric lines / border framework
            Positioned.fill(
              child: Opacity(
                opacity: 0.08,
                child: CustomPaint(
                  painter: IslamicArchPainter(
                    outlineColor: AppTheme.warmGold,
                    strokeWidth: 1.2,
                  ),
                ),
              ),
            ),

            // Central logo & branding layout
            Center(
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnimation.value,
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Gold calligraphic crescent logo
                          Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.warmGold.withOpacity(0.12),
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: CustomPaint(
                              painter: CrescentMoonPainter(color: AppTheme.warmGold),
                            ),
                          ),
                          const SizedBox(height: 36),

                          // App Latin Brand Name
                          const Text(
                            'ADEEN',
                            style: TextStyle(
                              fontFamily: 'Playfair Display',
                              fontSize: 34,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 6,
                              color: AppTheme.warmGold,
                            ),
                          ),
                          const SizedBox(height: 6),

                          // App Arabic Calligraphy Text
                          const Text(
                            'عَدِين',
                            style: TextStyle(
                              fontFamily: 'Amiri',
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                              color: AppTheme.premiumGold,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Tiny premium divider line
                          Container(
                            width: 60,
                            height: 1.5,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.warmGold.withOpacity(0.0),
                                  AppTheme.warmGold,
                                  AppTheme.warmGold.withOpacity(0.0),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Footer Bismillah text or loading indicator
            Positioned(
              bottom: 40,
              left: 20,
              right: 20,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    Text(
                      localizations.translate('bismillah'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 13,
                        color: AppTheme.warmGold.withOpacity(0.6),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Minimal loading indicator matching branding colors
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.warmGold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
