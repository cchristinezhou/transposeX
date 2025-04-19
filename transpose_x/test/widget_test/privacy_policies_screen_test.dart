import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transpose_x/screens/privacy_policies_screen.dart';

void main() {
  group('PrivacyPolicyScreen Widget Tests', () {
    testWidgets('renders AppBar with correct title', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: PrivacyPolicyScreen()),
      );

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Privacy Policy'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('displays key privacy policy sections', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: PrivacyPolicyScreen()),
      );

      expect(find.text('Your Privacy Matters'), findsOneWidget);
      expect(find.textContaining("We respect your privacy"), findsOneWidget);
      expect(find.textContaining("We do not collect or store any personal"), findsOneWidget);
      expect(find.textContaining("We may collect anonymous usage data"), findsOneWidget);
      expect(find.textContaining("If you have any questions"), findsOneWidget);
    });

    testWidgets('uses a scrollable layout', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: PrivacyPolicyScreen()),
      );

      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  });
}