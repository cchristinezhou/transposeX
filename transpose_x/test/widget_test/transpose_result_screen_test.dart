import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transpose_x/screens/transpose_result_screen.dart';

void main() {
   setUpAll(() {
    WebViewPlatform.instance = FakeWebViewPlatform();
  });
  testWidgets('TransposeResultScreen shows all main action buttons',
      (WidgetTester tester) async {
    // Build the widget
    await tester.pumpWidget(
      MaterialApp(
        home: TransposeResultScreen(
          transposedXml: '<score-partwise version="3.1"></score-partwise>',
          originalKey: 'C',
          transposedKey: 'D',
          songName: 'Test Song',
        ),
      ),
    );

    // Allow time for initState and WebView-related async code
    await tester.pumpAndSettle();

    // Check for key action buttons
    expect(find.text('View'), findsOneWidget);
    expect(find.text('Save to Library'), findsOneWidget);
    expect(find.text('Download'), findsOneWidget);
    expect(find.text('Share'), findsOneWidget);
    expect(find.text('Transpose Another One?'), findsOneWidget);
  });

  testWidgets('Tapping Save to Library shows input dialog',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: TransposeResultScreen(
          transposedXml: '<score-partwise version="3.1"></score-partwise>',
          originalKey: 'C',
          transposedKey: 'D',
          songName: 'Test Song',
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Tap on Save to Library button
    await tester.tap(find.text('Save to Library'));
    await tester.pumpAndSettle();

    // Verify dialog is shown
    expect(find.text('Name your sheet'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);
  });
}