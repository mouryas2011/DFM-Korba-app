import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'config/app_config.dart';
import 'screens/splash_screen.dart';

/// Root application widget for DFM Korba.
class DfmKorbaApp extends StatelessWidget {
  const DfmKorbaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppConfig.chassisObsidian,
        primaryColor: AppConfig.primaryBlue,
        colorScheme: const ColorScheme.dark(
          primary: AppConfig.primaryBlue,
          secondary: AppConfig.accentAmber,
          surface: AppConfig.chassisSlate,
          error: AppConfig.accentRed,
          onPrimary: Colors.white,
          onSecondary: AppConfig.textInverse,
          onSurface: AppConfig.textPrimary,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppConfig.chassisObsidian,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
            systemNavigationBarColor: AppConfig.chassisBlack,
            systemNavigationBarIconBrightness: Brightness.light,
          ),
        ),
        fontFamily: 'Roboto', // Clean default modern sans-serif
      ),
      home: const SplashScreen(),
    );
  }
}
