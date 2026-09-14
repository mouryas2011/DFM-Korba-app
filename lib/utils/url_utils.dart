import '../config/app_config.dart';

/// Utility methods for URL classification, validation, sanitization,
/// and security verification.
class UrlUtils {
  UrlUtils._();

  /// Determines whether the given URI belongs to the whitelisted domains.
  static bool isInternalAppUri(Uri uri) {
    if (!uri.hasScheme || (!uri.isScheme('http') && !uri.isScheme('https'))) {
      return false;
    }

    final host = uri.host.toLowerCase();
    for (final domain in AppConfig.trustedDomains) {
      if (host == domain || host.endsWith('.$domain')) {
        return true;
      }
    }
    return false;
  }

  /// Checks if the URI is a WhatsApp link or intent.
  static bool isWhatsApp(Uri uri) {
    final scheme = uri.scheme.toLowerCase();
    final host = uri.host.toLowerCase();
    return scheme == 'whatsapp' ||
        host == 'wa.me' ||
        host == 'api.whatsapp.com' ||
        host == 'chat.whatsapp.com';
  }

  /// Checks if the URI is a telephone link (`tel:`).
  static bool isTelephone(Uri uri) {
    return uri.scheme.toLowerCase() == 'tel';
  }

  /// Checks if the URI is an email link (`mailto:`).
  static bool isEmail(Uri uri) {
    return uri.scheme.toLowerCase() == 'mailto';
  }

  /// Checks if the URI is a map or geolocation link.
  static bool isMap(Uri uri) {
    final scheme = uri.scheme.toLowerCase();
    final host = uri.host.toLowerCase();
    return scheme == 'geo' ||
        host.contains('maps.google.') ||
        host == 'maps.apple.com' ||
        (host.contains('google.') && uri.path.startsWith('/maps'));
  }

  /// Checks if the URI points to YouTube.
  static bool isYouTube(Uri uri) {
    final host = uri.host.toLowerCase();
    return host == 'youtube.com' ||
        host.endsWith('.youtube.com') ||
        host == 'youtu.be';
  }

  /// Checks if the URI points directly to a PDF file.
  static bool isPdf(Uri uri) {
    final path = uri.path.toLowerCase();
    return path.endsWith('.pdf') ||
        uri.queryParameters['export'] == 'download' ||
        (uri.host.contains('drive.google.com') && uri.path.contains('/file/d/'));
  }

  /// Determines if an intercepted download should be handled by the DownloadService.
  static bool isDownloadable(String url, String? mimeType, String? contentDisposition) {
    final lowerUrl = url.toLowerCase();
    final lowerMime = (mimeType ?? '').toLowerCase();
    final lowerDisp = (contentDisposition ?? '').toLowerCase();

    if (lowerDisp.contains('attachment')) return true;
    if (lowerMime.contains('application/pdf') ||
        lowerMime.contains('application/zip') ||
        lowerMime.contains('application/octet-stream') ||
        lowerMime.contains('image/png') ||
        lowerMime.contains('image/jpeg')) {
      return true;
    }

    final extensions = ['.pdf', '.zip', '.apk', '.csv', '.xlsx', '.docx', '.jpg', '.jpeg', '.png'];
    for (final ext in extensions) {
      if (lowerUrl.contains(ext)) return true;
    }

    return false;
  }

  /// Sanitizes a URL for secure development logging.
  /// Removes potentially sensitive query parameters (e.g. tokens, credentials).
  static String sanitizeUrlForLogging(String url) {
    try {
      final uri = Uri.parse(url);
      if (uri.queryParameters.isEmpty) return url;

      final safeParams = <String, String>{};
      for (final entry in uri.queryParameters.entries) {
        final key = entry.key.toLowerCase();
        if (key.contains('token') ||
            key.contains('auth') ||
            key.contains('key') ||
            key.contains('pass') ||
            key.contains('secret') ||
            key.contains('session')) {
          safeParams[entry.key] = '[REDACTED]';
        } else {
          safeParams[entry.key] = entry.value;
        }
      }

      return uri.replace(queryParameters: safeParams).toString();
    } catch (_) {
      return '[Invalid URL]';
    }
  }
}
