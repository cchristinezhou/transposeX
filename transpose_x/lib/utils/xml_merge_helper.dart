import 'package:xml/xml.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';

class XmlMergeHelper {
  static bool _isZip(Uint8List bytes) {
    return bytes.length >= 4 &&
        bytes[0] == 0x50 &&
        bytes[1] == 0x4B &&
        (bytes[2] == 0x03 || bytes[2] == 0x05 || bytes[2] == 0x07) &&
        (bytes[3] == 0x04 || bytes[3] == 0x06 || bytes[3] == 0x08);
  }

  static Future<String?> processAndMergeFiles(List<XFile> files) async {
    List<XmlDocument> parsedDocs = [];

    for (XFile file in files) {
      final bytes = await ApiService.uploadFileReturningBytes(
        file.path,
        file.name,
      );
      if (bytes == null) continue;

      if (file.name.toLowerCase().endsWith('.mxl') || _isZip(bytes)) {
        try {
          final archive = ZipDecoder().decodeBytes(bytes);
          for (final archived in archive) {
            if (archived.name.endsWith('.xml')) {
              final xmlStr = utf8.decode(archived.content as List<int>);
              parsedDocs.add(XmlDocument.parse(xmlStr));
              break;
            }
          }
        } catch (e) {
          print("❌ Failed to unzip MXL: $e");
        }
      } else {
        final xmlStr = utf8.decode(bytes);
        parsedDocs.add(XmlDocument.parse(xmlStr));
      }
    }

    if (parsedDocs.isEmpty) return null;

    final baseDoc = parsedDocs.first;
    final score = baseDoc.rootElement;
    final basePartList = score.getElement('part-list')!;
    int nextPartId = 2;

    for (int i = 1; i < parsedDocs.length; i++) {
      final doc = parsedDocs[i];
      final incomingScore = doc.rootElement;

      final incomingPartList = incomingScore.getElement('part-list');
      if (incomingPartList != null) {
        for (final partDef in incomingPartList.findElements('score-part')) {
          final newId = 'P$nextPartId';
          final copied = partDef.copy();
          copied.getAttributeNode('id')?.value = newId;
          basePartList.children.add(copied);
        }
      }

      for (final part in incomingScore.findAllElements('part')) {
        final newId = 'P$nextPartId';
        final updatedPart = part.copy();
        updatedPart.getAttributeNode('id')?.value = newId;

        int measureNum = 1;
        for (final measure in updatedPart.findElements('measure')) {
          final attr = measure.getAttributeNode('number');
          if (attr != null) {
            attr.value = measureNum.toString();
          }
          measureNum++;
        }

        score.children.add(updatedPart);
        nextPartId++;
      }
    }

    return baseDoc.toXmlString(pretty: true);
  }

  static String mergeXmlDocuments(List<XmlDocument> docs) {
    if (docs.isEmpty) return '';

    final baseDoc = docs.first;
    final score = baseDoc.rootElement;
    final basePartList = score.getElement('part-list');
    if (basePartList == null)
      throw Exception("Missing part-list in base document");

    int nextPartId = 2; // Start from P2

    for (int i = 1; i < docs.length; i++) {
      final doc = docs[i];
      final incomingScore = doc.rootElement;

      // Merge part-list
      final incomingPartList = incomingScore.getElement('part-list');
      if (incomingPartList != null) {
        for (final partDef in incomingPartList.findElements('score-part')) {
          final newId = 'P$nextPartId';
          final copied = partDef.copy();
          copied.getAttributeNode('id')?.value = newId;
          basePartList.children.add(copied);
        }
      }

      // Merge parts
      for (final part in incomingScore.findAllElements('part')) {
        final newId = 'P$nextPartId';
        final updatedPart = part.copy();
        updatedPart.getAttributeNode('id')?.value = newId;

        // Optional: re-number measures
        int measureNum = 1;
        for (final measure in updatedPart.findElements('measure')) {
          final attr = measure.getAttributeNode('number');
          if (attr != null) {
            attr.value = measureNum.toString();
          }
          measureNum++;
        }

        score.children.add(updatedPart);
        nextPartId++;
      }
    }

    return baseDoc.toXmlString(pretty: true);
  }
}
