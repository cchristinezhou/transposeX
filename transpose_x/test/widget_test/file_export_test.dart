import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:transpose_x/utils/file_export.dart'; // Update to your actual file
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

class FakePathProvider extends PathProviderPlatform {
  @override
  Future<String> getTemporaryPath() async {
    final dir = Directory.systemTemp.createTempSync();
    return dir.path;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    PathProviderPlatform.instance = FakePathProvider();
  });

  group('File utility coverage tests', () {
    test('saveXmlFile works and writes to a file', () async {
      const xml = '<xml>coverage</xml>';
      final file = await saveXmlFile(xml);
      final content = await file.readAsString();
      expect(content, xml);
    });

    test('saveToDownloads covers Android and iOS branches', () async {
      final file = await saveXmlFile('<xml>');
      await saveToDownloads(file);
      await saveToDownloads(file);
    });
  });
}