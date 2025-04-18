import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transpose_x/screens/home_screen.dart';

void main() {
  group('HomeScreen Widget Tests', () {
    testWidgets('displays the TransposeX title', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(home: HomeScreen()),
      );

      expect(find.text('TransposeX'), findsOneWidget);
    });

    testWidgets('shows both action buttons', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(home: HomeScreen()),
      );

      expect(find.text('Take a Picture'), findsOneWidget);
      expect(find.text('Upload'), findsOneWidget);
    });

    testWidgets('navigates to SavedScreen when tapping the bookmark icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(home: HomeScreen()),
      );

      // Tap the Saved icon in the BottomNavigationBar
      await tester.tap(find.byIcon(Icons.bookmark));
      await tester.pumpAndSettle();

      // Optionally check for specific content in SavedScreen here
    });

    testWidgets('navigates to ProfileScreen when tapping the person icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(home: HomeScreen()),
      );

      // Tap the Profile icon in the BottomNavigationBar
      await tester.tap(find.byIcon(Icons.person));
      await tester.pumpAndSettle();

      // Optionally check for specific content in ProfileScreen here
    });
  });
}