import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transpose_x/screens/detect_key_screen.dart';

void main() {
  group('DetectKeyScreen Widget Tests', () {
    const fakeXml = '''
      <score-partwise>
        <part>
          <measure>
            <attributes>
              <key>
                <fifths>0</fifths>
                <mode>major</mode>
              </key>
            </attributes>
          </measure>
        </part>
      </score-partwise>
    ''';

    testWidgets('displays loading text and progress indicator', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DetectKeyScreen(xmlContent: fakeXml),
        ),
      );

      // Let the 2-second timer complete (avoid pending timer error)
      await tester.pump(const Duration(seconds: 3));

      expect(find.text('Detecting the Key...'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('renders a Cancel button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DetectKeyScreen(xmlContent: fakeXml),
        ),
      );

      await tester.pump(const Duration(seconds: 3)); // Wait for timer to complete

      expect(find.text('Cancel'), findsOneWidget);
      expect(find.byType(OutlinedButton), findsOneWidget);
    });
  });
}