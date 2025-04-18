import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transpose_x/screens/view_sheet_screen.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

import 'fake_webview_platform.dart';

void main() {
  setUpAll(() {
    WebViewPlatform.instance = FakeWebViewPlatform();
  });

  testWidgets('ViewSheetScreen opens rename dialog from menu (suppress overflow)', (tester) async {
    final originalOnError = FlutterError.onError;

    FlutterError.onError = (FlutterErrorDetails details) {
      if (details.exceptionAsString().contains('A RenderFlex overflowed')) {
        // suppress
      } else {
        originalOnError?.call(details);
      }
    };

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(size: Size(1200, 800)),
        child: MaterialApp(
          home: ViewSheetScreen(
            xmlContent: '<score-partwise version="3.1"></score-partwise>',
            keySignature: 'C',
            fileName: 'test_file.xml',
            initialTitle: 'Test Title',
          ),
        ),
      ),
    );

    // Give time for WebView to fake-load
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));

    // Tap the menu button
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    // Tap "Rename"
    await tester.tap(find.text('Rename'));
    await tester.pumpAndSettle();

    // Check that the rename dialog shows up
    expect(find.text("Rename Your Sheet"), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text("Cancel"), findsOneWidget);
    expect(find.text("Save"), findsOneWidget);

    FlutterError.onError = originalOnError;
  });
}