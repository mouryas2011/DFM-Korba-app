import 'package:flutter/material.dart';

/// Centralized configuration for DFM Korba Mobile Application.
///
/// Contains application metadata, web URLs, domain security whitelists,
/// and the official DFM Korba color palette.
class AppConfig {
  AppConfig._(); // Private constructor to prevent instantiation

  // ===========================================================================
  // APPLICATION IDENTITY
  // ===========================================================================
  static const String appName = 'DFM Korba';
  static const String appFullName = 'Drone Film Making Korba';
  static const String appTagline = 'Center of Excellence in Drone Technology & Aerial Cinematography';
  static const String appVersion = '1.0.1';
  static const int appBuildNumber = 2;
  static const String appPackageName = 'com.dfmkorba.app';

  // ===========================================================================
  // PRIMARY WEB APPLICATION URL
  // ===========================================================================
  /// Official Primary Website URL for DFM Korba.
  /// Centralized single source of truth (BASE_URL).
  static const String baseUrl = 'https://www.dfmkorba.online/';

  /// Backward-compatible alias for the primary URL.
  static const String webAppUrl = baseUrl;

  // ===========================================================================
  // DOMAIN SECURITY WHITELIST
  // ===========================================================================
  /// Only pages hosted under these trusted domains are loaded inside the WebView.
  /// All other external links will be routed through external handlers.
  static const List<String> trustedDomains = [
    // Primary Website Domains
    'dfmkorba.online',
    'www.dfmkorba.online',

    // Google Sites & Google Cloud Infrastructure
    'sites.google.com',
    'google.com',
    'ssl.gstatic.com',
    'gstatic.com',
    'lh3.googleusercontent.com',
    'commondatastorage.googleapis.com',
    'apis.google.com',

    // Google Apps Script & Embedded Web Apps
    'script.google.com',
    'script.googleusercontent.com',
    'googleusercontent.com',

    // Google Workspace Integrations (Drive, Docs, Forms, Sheets)
    'drive.google.com',
    'docs.google.com',
    'accounts.google.com',

    // CDN & Media Services
    'api.qrserver.com',
    'fonts.googleapis.com',
    'fonts.gstatic.com',
    'images.unsplash.com',
  ];

  // ===========================================================================
  // CONTACT & SOCIAL INFORMATION
  // ===========================================================================
  static const String contactPhone = '+916307076206';
  static const String contactEmail = 'info@dfmkorba.in';
  static const String whatsappNumber = '916307076206';
  static const String defaultWhatsAppMessage =
      'Hi DFM Korba, I would like to know more about the drone course enrollment.';
  static const String mapsQuery = 'Livelihood+College+Korba';

  // ===========================================================================
  // TIMEOUTS & THRESHOLDS
  // ===========================================================================
  static const Duration splashDisplayDuration = Duration(milliseconds: 1800);
  static const Duration connectionTimeout = Duration(seconds: 25);
  static const Duration retryCooldown = Duration(seconds: 2);

  // ===========================================================================
  // BRAND COLOR PALETTE (Extracted from DFM Korba Web App Architecture)
  // ===========================================================================
  // Dark Navy & Slate Chassis
  static const Color chassisBlack = Color(0xFF06090E);
  static const Color chassisObsidian = Color(0xFF0A0E16);
  static const Color chassisSlate = Color(0xFF131926);
  static const Color chassisHover = Color(0xFF1B2334);
  static const Color chassisBorder = Color(0xFF212C40);
  static const Color chassisBorderBright = Color(0xFF314260);

  // Brand Blues
  static const Color primaryBlue = Color(0xFF0284C7);
  static const Color blueHover = Color(0xFF0369A1);
  static const Color blueDark = Color(0xFF075985);
  static const Color blueSoft = Color(0xFFF0F9FF);
  static const Color blueAccent = Color(0xFF38BDF8);

  // Brand Accents (Amber/Gold & Red)
  static const Color accentAmber = Color(0xFFF59E0B);
  static const Color amberHover = Color(0xFFD97706);
  static const Color amberDark = Color(0xFFB45309);
  static const Color amberSoft = Color(0xFFFFFBEB);
  static const Color accentGold = Color(0xFFFACC15);
  static const Color accentRed = Color(0xFFEF4444);
  static const Color successGreen = Color(0xFF10B981);

  // Typography Colors
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textInverse = Color(0xFF0A0E16);
}
