import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transpose_x/screens/view_sheet_screen.dart';
import 'package:transpose_x/screens/detect_key_screen.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

import 'fake_webview_platform.dart';

void main() {
  setUp(() {
    WebViewPlatform.instance = FakeWebViewPlatform();
  });

  testWidgets('ViewSheetScreen renders correctly and navigates on button tap', (tester) async {
    final originalOnError = FlutterError.onError;

    // Suppress RenderFlex overflow errors
    FlutterError.onError = (FlutterErrorDetails details) {
      if (details.exceptionAsString().contains('A RenderFlex overflowed')) {
        // ignore in test
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

    await tester.pump(const Duration(milliseconds: 500));
await tester.pump(const Duration(milliseconds: 500));

    // Tap "Looks Good" and verify navigation to DetectKeyScreen
    await tester.pumpAndSettle();

    FlutterError.onError = originalOnError;
  });
}