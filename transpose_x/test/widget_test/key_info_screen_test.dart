import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transpose_x/screens/key_info_screen.dart';

void main() {
  group('KeyInfoScreen Widget Tests', () {
    testWidgets('renders title and key paragraphs', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: KeyInfoScreen()),
      );

      // Check title and major sections of text
      expect(find.text('How We Detect\nYour Key'), findsOneWidget);
      expect(find.textContaining('Transpose X simplifies key detection'), findsOneWidget);
      expect(find.text('Why Do We Detect Only One Key?'), findsOneWidget);
      expect(find.textContaining('Many sheet music pieces modulate'), findsOneWidget);
      expect(find.textContaining('If you need more flexibility'), findsOneWidget);
    });

    testWidgets('contains AppBar and scrollable layout', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: KeyInfoScreen()),
      );

      // Check AppBar and scrollable widgets
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(Scrollbar), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  });
}