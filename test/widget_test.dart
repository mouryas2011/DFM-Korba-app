import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dfm_korba_app/config/app_config.dart';

void main() {
  testWidgets('App branding smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              children: [
                Text(AppConfig.appName),
                Text(AppConfig.appFullName),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.text('DFM Korba'), findsOneWidget);
    expect(find.text('Drone Film Making Korba'), findsOneWidget);
  });
}
