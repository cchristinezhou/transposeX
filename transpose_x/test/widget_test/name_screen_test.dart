import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transpose_x/screens/name_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('NameScreen Widget Tests', () {
    testWidgets('renders all text fields and labels', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(home: NameScreen()),
      );

      // Check field labels
      expect(find.text('First Name *'), findsOneWidget);
      expect(find.text('Middle Name'), findsOneWidget);
      expect(find.text('Last Name'), findsOneWidget);

      // There should be 3 TextFields
      expect(find.byType(TextField), findsNWidgets(3));
    });

    testWidgets('can enter names into all fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(home: NameScreen()),
      );

      final textFields = find.byType(TextField);

      await tester.enterText(textFields.at(0), 'Alice');
      await tester.enterText(textFields.at(1), 'B.');
      await tester.enterText(textFields.at(2), 'Chen');

      await tester.pump();

      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('B.'), findsOneWidget);
      expect(find.text('Chen'), findsOneWidget);
    });

    testWidgets('renders AppBar and BottomNavigationBar', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(home: NameScreen()),
      );

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });
  });
}