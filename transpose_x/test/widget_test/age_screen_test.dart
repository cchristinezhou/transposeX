import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transpose_x/screens/age_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // Set up fake shared preferences
    SharedPreferences.setMockInitialValues({});
  });

  group('AgeScreen Widget Tests', () {
    testWidgets('renders app bar with title "Back"', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(home: AgeScreen()),
      );

      expect(find.text('Back'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('renders "Your Age" label and dropdown', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(home: AgeScreen()),
      );

      expect(find.text('Your Age'), findsOneWidget);
      expect(find.byType(DropdownButton<int>), findsOneWidget);
    });

    testWidgets('dropdown has age 20 selected by default', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(home: AgeScreen()),
      );

      final dropdown = tester.widget<DropdownButton<int>>(find.byType(DropdownButton<int>));
      expect(dropdown.value, 20);
    });

    testWidgets('renders BottomNavigationBar with 3 items', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(home: AgeScreen()),
      );

      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.bookmark), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
    });
  });
}