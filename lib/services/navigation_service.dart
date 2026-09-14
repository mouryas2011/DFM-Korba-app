import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/url_utils.dart';

/// Service responsible for routing links, handling external schemes
/// (WhatsApp, Phone, Email, Maps), and launching external applications safely.
class NavigationService {
  NavigationService._();

  /// Routes an intercepted URI to the appropriate native application or external handler.
  /// Returns `true` if the navigation was handled natively, or `false` to let WebView process it.
  static Future<bool> handleNavigation(BuildContext context, Uri uri) async {
    final sanitizedLog = UrlUtils.sanitizeUrlForLogging(uri.toString());
    if (kDebugMode) {
      debugPrint('[NavigationService] Handling URI: $sanitizedLog');
    }

    // 1. WhatsApp Integration
    if (UrlUtils.isWhatsApp(uri)) {
      return await launchWhatsApp(context, uri);
    }

    // 2. Phone Dialer
    if (UrlUtils.isTelephone(uri)) {
      return await launchTelephone(context, uri);
    }

    // 3. Email Client
    if (UrlUtils.isEmail(uri)) {
      return await launchEmail(context, uri);
    }

    // 4. Maps / Location
    if (UrlUtils.isMap(uri)) {
      return await launchMap(context, uri);
    }

    // 5. YouTube / External Media
    if (UrlUtils.isYouTube(uri)) {
      return await launchExternalBrowser(context, uri);
    }

    // 6. External Non-Whitelisted Websites
    if (!UrlUtils.isInternalAppUri(uri)) {
      return await launchExternalBrowser(context, uri);
    }

    // Internal app page (stay inside WebView)
    return false;
  }

  /// Launches WhatsApp via native app or browser fallback.
  static Future<bool> launchWhatsApp(BuildContext context, Uri uri) async {
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return true;
      }

      // Fallback: If uri is not wa.me, attempt web fallback
      final webFallback = Uri.parse(
          'https://api.whatsapp.com/send?phone=${uri.path.replaceAll('/', '')}');
      if (await canLaunchUrl(webFallback)) {
        await launchUrl(webFallback, mode: LaunchMode.externalApplication);
        return true;
      }

      _showErrorSnackBar(context, 'WhatsApp could not be opened.');
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('[NavigationService] WhatsApp error: $e');
      _showErrorSnackBar(context, 'Could not open WhatsApp.');
      return true;
    }
  }

  /// Launches native telephone dialer.
  static Future<bool> launchTelephone(BuildContext context, Uri uri) async {
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return true;
      }
      _showErrorSnackBar(context, 'No phone dialer available.');
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('[NavigationService] Tel error: $e');
      _showErrorSnackBar(context, 'Could not launch phone dialer.');
      return true;
    }
  }

  /// Launches default email client.
  static Future<bool> launchEmail(BuildContext context, Uri uri) async {
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return true;
      }
      _showErrorSnackBar(context, 'No email app configured.');
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('[NavigationService] Email error: $e');
      _showErrorSnackBar(context, 'Could not launch email app.');
      return true;
    }
  }

  /// Launches Google Maps or Apple Maps.
  static Future<bool> launchMap(BuildContext context, Uri uri) async {
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return true;
      }
      _showErrorSnackBar(context, 'Could not open maps application.');
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('[NavigationService] Maps error: $e');
      return false;
    }
  }

  /// Opens an external URL using the system's default browser.
  static Future<bool> launchExternalBrowser(BuildContext context, Uri uri) async {
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return true;
      }
      _showErrorSnackBar(context, 'Could not open link in external browser.');
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('[NavigationService] External launch error: $e');
      return false;
    }
  }

  static void _showErrorSnackBar(BuildContext context, String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
