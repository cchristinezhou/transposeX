import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transpose_x/screens/profile_screen.dart';

void main() {
  group('ProfileScreen Widget Tests', () {
    testWidgets('renders app bar and title', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(home: ProfileScreen()),
      );

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('My Profile'), findsOneWidget);
    });

    testWidgets('renders all profile options', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(home: ProfileScreen()),
      );

      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Age'), findsOneWidget);
      expect(find.text('Instrument'), findsOneWidget);
    });

    testWidgets('renders About Us and Privacy Policy links', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(home: ProfileScreen()),
      );

      expect(find.text('About Us'), findsOneWidget);
      expect(find.text('Privacy Policy'), findsOneWidget);
    });

    testWidgets('renders trailing icons for ListTiles', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(home: ProfileScreen()),
      );

      expect(find.byIcon(Icons.arrow_forward_ios), findsNWidgets(3));
    });
  });
}