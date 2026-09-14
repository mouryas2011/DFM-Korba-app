import 'package:flutter_test/flutter_test.dart';
import 'package:dfm_korba_app/app.dart';
import 'package:dfm_korba_app/config/app_config.dart';

void main() {
  testWidgets('DFM Korba app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const DfmKorbaApp());

    // Verify that the splash screen displays the application name
    expect(find.text('DFM KORBA'), findsOneWidget);
    expect(find.text('Drone Film Making Korba'), findsOneWidget);
  });
}
