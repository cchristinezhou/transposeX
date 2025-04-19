import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:image_picker/image_picker.dart';

import 'package:transpose_x/screens/camera_screen.dart';
import 'package:transpose_x/services/api_service.dart'; // Adjust the path

import '../mocks/mock_services.mocks.dart'; // Generated via build_runner

void main() {
  late MockImagePicker mockImagePicker;

  setUp(() {
    mockImagePicker = MockImagePicker();
  });

  group('CameraScreen Widget Tests', () {
    testWidgets('renders UI and responds to basic buttons', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: CameraScreen()));

      // Spinner before camera is initialized
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pump(const Duration(seconds: 2));

      // Check buttons
      expect(find.byIcon(Icons.photo), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('Back button triggers Navigator.pop', (WidgetTester tester) async {
      final navKey = GlobalKey<NavigatorState>();

      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navKey,
          home: const CameraScreen(),
        ),
      );

      await tester.tap(find.byTooltip('Back to previous screen'));
      await tester.pumpAndSettle();
    });

  
  });
}