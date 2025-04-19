import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:archive/archive.dart';
import 'package:xml/xml.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mockito/mockito.dart';

import 'package:transpose_x/utils/xml_merge_helper.dart';
import 'package:transpose_x/services/api_service.dart';

class MockXFile extends Mock implements XFile {
  @override
  final String path;
  @override
  final String name;

  MockXFile(this.path, this.name);
}

void main() {
  group('XmlMergeHelper', () {
    test('mergeXmlDocuments merges parts and renumbers', () {
      final doc1 = XmlDocument.parse('''
        <score-partwise>
          <part-list>
            <score-part id="P1"/>
          </part-list>
          <part id="P1">
            <measure number="1"/>
            <measure number="2"/>
          </part>
        </score-partwise>
      ''');

      final doc2 = XmlDocument.parse('''
        <score-partwise>
          <part-list>
            <score-part id="P1"/>
          </part-list>
          <part id="P1">
            <measure number="10"/>
            <measure number="20"/>
          </part>
        </score-partwise>
      ''');

      final merged = XmlMergeHelper.mergeXmlDocuments([doc1, doc2]);
      expect(merged.contains('P2'), isTrue);
      expect(merged.contains('measure number="1"'), isTrue);
      expect(merged.contains('measure number="2"'), isTrue);
    });
  });
}