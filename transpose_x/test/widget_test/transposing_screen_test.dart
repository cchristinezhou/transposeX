import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transpose_x/screens/transposing_screen.dart';
import 'package:transpose_x/screens/transpose_result_screen.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';
import 'package:transpose_x/services/api_service.dart';

import 'fake_webview_platform.dart';

void main() {
  setUpAll(() {
    WebViewPlatform.instance = FakeWebViewPlatform();
  });

  testWidgets('TransposingScreen loads UI without mocking ApiService', (tester) async {
  await tester.pumpWidget(
    MediaQuery(
      data: const MediaQueryData(size: Size(1200, 800)),
      child: MaterialApp(
        home: TransposingScreen(
          xmlContent: '<xml />',
          originalKey: 'C',
          transposedKey: 'D',
          songName: 'Test Song',
        ),
      ),
    ),
  );

  // Only test what you CAN see before navigation happens
  expect(find.text('Transposing...'), findsOneWidget);
  expect(find.byType(LinearProgressIndicator), findsOneWidget);
});
}