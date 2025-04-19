import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transpose_x/screens/instrument_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('InstrumentScreen Widget Tests', () {
    testWidgets('renders basic UI elements', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(home: InstrumentScreen()),
      );

      expect(find.text('Instrument'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Add an Instrument'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });

    testWidgets('adds and deletes an instrument item', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(home: InstrumentScreen()),
      );

      // Enter text in the text field
      await tester.enterText(find.byType(TextField), 'Clarinet');
      await tester.tap(find.text('Add an Instrument'));
      await tester.pump(); // Trigger UI update

      // Instrument should appear in the list
      expect(find.text('Clarinet'), findsOneWidget);

      // Tap delete icon
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pump();

      // Item should be removed
      expect(find.text('Clarinet'), findsNothing);
    });
  });
}