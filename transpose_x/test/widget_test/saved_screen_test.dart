import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transpose_x/screens/saved_screen.dart';

void main() {
  group('SavedScreen Widget Tests', () {
    testWidgets('shows loading indicator when loading', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SavedScreen(),
        ),
      );

      // Initially shows loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Saved'), findsOneWidget);
    });

    testWidgets('displays fallback text if song list is empty', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SavedScreen(),
        ),
      );

      // Simulate API call completion
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text('No saved songs yet 💤'), findsOneWidget);
    });
  });
}