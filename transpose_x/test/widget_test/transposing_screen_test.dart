import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transpose_x/screens/transposing_screen.dart';

void main() {
  testWidgets('TransposingScreen shows progress UI correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: TransposingScreen(
          xmlContent: '<score-partwise version="3.1"><part><measure number="1"/></part></score-partwise>',
          originalKey: 'C major',
          transposedKey: 'D major',
          songName: 'Test Song',
        ),
      ),
    );

    // Check for transposing text
    expect(find.text('Transposing...'), findsOneWidget);

    // Check for progress bar
    expect(find.byType(LinearProgressIndicator), findsOneWidget);

    // Check for cancel button
    expect(find.text('Cancel'), findsOneWidget);
  });
}