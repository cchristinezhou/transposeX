import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transpose_x/screens/camera_screen.dart';

void main() {
  group('CameraScreen Widget Tests', () {
    testWidgets('renders AppBar with back button and title', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(home: CameraScreen()),
      );

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      expect(find.text('Back'), findsOneWidget);
    });

    testWidgets('renders gallery, capture, and upload buttons', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(home: CameraScreen()),
      );

      // Gallery button
      expect(find.byIcon(Icons.photo), findsOneWidget);

      // Capture button: look for circular container with a border
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Container &&
              widget.decoration is BoxDecoration &&
              (widget.decoration as BoxDecoration).shape == BoxShape.circle &&
              (widget.decoration as BoxDecoration).border != null,
        ),
        findsOneWidget,
      );

      // Upload button: check_circle icon
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('shows loading indicator before camera initializes', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(home: CameraScreen()),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}