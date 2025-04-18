import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transpose_x/screens/transpose_options_screen.dart';

void main() {
  group('TransposeOptionsScreen Widget Tests', () {
    const fakeXml = '<xml></xml>';

    testWidgets('renders detection result and key info', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: TransposeOptionsScreen(
            originalKey: 'C major',
            xmlContent: fakeXml,
          ),
        ),
      );

      expect(find.text('Detection Successful!'), findsOneWidget);
      expect(find.textContaining('It looks like your sheet is in C major'), findsOneWidget);
      expect(find.text('Transpose Options'), findsOneWidget);
      expect(find.byType(ChoiceChip), findsNWidgets(2));
      expect(find.byIcon(Icons.add_circle_outline), findsOneWidget);
      expect(find.byIcon(Icons.remove_circle_outline), findsOneWidget);
      expect(find.text('Transpose'), findsOneWidget);
    });

    testWidgets('shows snackbar if same key is selected', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: TransposeOptionsScreen(
            originalKey: 'C major',
            xmlContent: fakeXml,
          ),
        ),
      );

      await tester.tap(find.text('Transpose'));
      await tester.pump(); // Trigger snack bar

      expect(find.textContaining('same key'), findsOneWidget);
    });
  });
}