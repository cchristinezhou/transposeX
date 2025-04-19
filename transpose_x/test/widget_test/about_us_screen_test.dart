import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transpose_x/screens/about_us_screen.dart';

void main() {
  group('AboutUsScreen Widget Tests', () {
    testWidgets('renders AppBar with correct title', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: AboutUsScreen()),
      );

      expect(find.text('About Us'), findsOneWidget);
      expect(find.byType(BackButton), findsOneWidget);
    });

    testWidgets('displays all key text sections', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: AboutUsScreen()),
      );

      expect(find.text('Empowering Music Learners'), findsOneWidget);
      expect(
        find.textContaining('Transpose X was created to make sheet music more accessible'),
        findsOneWidget,
      );
      expect(
        find.textContaining('Whether you\'re a music teacher preparing materials'),
        findsOneWidget,
      );
      expect(
        find.textContaining('We\'re a small team of music lovers'),
        findsOneWidget,
      );
      expect(
        find.textContaining('Thank you for being part of our journey'),
        findsOneWidget,
      );
    });
  });
}