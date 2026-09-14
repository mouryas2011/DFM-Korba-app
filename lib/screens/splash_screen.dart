import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../services/connectivity_service.dart';
import 'webview_screen.dart';

/// Native-style splash screen for DFM Korba.
/// Loads quickly, performs initial connectivity check, and smoothly transitions
/// to the production WebView shell.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _controller.forward();
    _initializeAppAndNavigate();
  }

  Future<void> _initializeAppAndNavigate() async {
    // Perform startup initializations; proceed as soon as ready without fake delays
    await Future.wait([
      ConnectivityService().initialize(),
      Future.delayed(const Duration(milliseconds: 900)),
    ]);

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const WebViewScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConfig.chassisObsidian,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),

                  // App Logo / Tech Drone Emblem
                  Container(
                    width: 108,
                    height: 108,
                    decoration: BoxDecoration(
                      color: AppConfig.chassisSlate,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: AppConfig.chassisBorderBright,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppConfig.primaryBlue.withOpacity(0.25),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Image.asset(
                      'assets/images/dfm_korba_logo.png',
                      errorBuilder: (context, error, stackTrace) {
                        // Resilient branded fallback if image asset is loading
                        return const Center(
                          child: Icon(
                            Icons.flight_takeoff_rounded,
                            size: 54,
                            color: AppConfig.accentAmber,
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Brand Title
                  const Text(
                    'DFM KORBA',
                    style: TextStyle(
                      color: AppConfig.textPrimary,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2.0,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Subtitle
                  const Text(
                    'Drone Film Making Korba',
                    style: TextStyle(
                      color: AppConfig.accentAmber,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Institutional Tagline
                  const Text(
                    'Center of Excellence in Drone Technology',
                    style: TextStyle(
                      color: AppConfig.textMuted,
                      fontSize: 12,
                      letterSpacing: 0.2,
                    ),
                  ),

                  const Spacer(),

                  // Subtle initialization indicator
                  const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppConfig.primaryBlue),
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Center of Excellence in Drone Education',
                    style: TextStyle(
                      color: AppConfig.textMuted,
                      fontSize: 11,
                      letterSpacing: 0.3,
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
