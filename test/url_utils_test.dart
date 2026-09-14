import 'package:flutter_test/flutter_test.dart';
import 'package:dfm_korba_app/utils/url_utils.dart';

void main() {
  group('UrlUtils Tests', () {
    test('Identifies trusted Google Apps Script and Google domains', () {
      expect(
        UrlUtils.isInternalAppUri(
          Uri.parse('https://script.google.com/macros/s/AKfycbxqbAmKxvfbTnv313FFoSafospHlNpbx0oY9J9gCPypU3srpSILcYJgGUyD29S1wS1h/exec'),
        ),
        isTrue,
      );

      expect(
        UrlUtils.isInternalAppUri(
          Uri.parse('https://n-okf253ml3zbwlftllmhs44rm54s7vml6bfl5ohy-0lu-script.googleusercontent.com/userCodeAppPanel'),
        ),
        isTrue,
      );

      expect(
        UrlUtils.isInternalAppUri(
          Uri.parse('https://drive.google.com/file/d/123/view'),
        ),
        isTrue,
      );

      expect(
        UrlUtils.isInternalAppUri(
          Uri.parse('https://unauthorized-domain.com/hack'),
        ),
        isFalse,
      );
    });

    test('Identifies WhatsApp links and numbers', () {
      expect(UrlUtils.isWhatsApp(Uri.parse('https://wa.me/916307076206')), isTrue);
      expect(UrlUtils.isWhatsApp(Uri.parse('https://api.whatsapp.com/send?phone=916307076206')), isTrue);
      expect(UrlUtils.isWhatsApp(Uri.parse('whatsapp://send?phone=916307076206')), isTrue);
      expect(UrlUtils.isWhatsApp(Uri.parse('https://google.com')), isFalse);
    });

    test('Identifies Phone and Email links', () {
      expect(UrlUtils.isTelephone(Uri.parse('tel:+916307076206')), isTrue);
      expect(UrlUtils.isTelephone(Uri.parse('https://google.com')), isFalse);

      expect(UrlUtils.isEmail(Uri.parse('mailto:info@dfmkorba.in')), isTrue);
      expect(UrlUtils.isEmail(Uri.parse('https://google.com')), isFalse);
    });

    test('Identifies Maps and YouTube links', () {
      expect(UrlUtils.isMap(Uri.parse('https://maps.google.com/?q=Livelihood+College+Korba')), isTrue);
      expect(UrlUtils.isMap(Uri.parse('geo:22.35,82.71')), isTrue);

      expect(UrlUtils.isYouTube(Uri.parse('https://youtube.com/watch?v=dQw4w9WgXcQ')), isTrue);
      expect(UrlUtils.isYouTube(Uri.parse('https://youtu.be/dQw4w9WgXcQ')), isTrue);
    });

    test('Sanitizes sensitive tokens in debug logs', () {
      const sensitiveUrl =
          'https://script.google.com/exec?token=SECRET123&action=load&auth_session=XYZ999';
      final sanitized = UrlUtils.sanitizeUrlForLogging(sensitiveUrl);

      expect(sanitized.contains('SECRET123'), isFalse);
      expect(sanitized.contains('XYZ999'), isFalse);
      expect(sanitized.contains('[REDACTED]'), isTrue);
      expect(sanitized.contains('action=load'), isTrue);
    });
  });
}
