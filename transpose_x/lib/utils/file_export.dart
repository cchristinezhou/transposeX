import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';

const String _baseUrl = "http://10.0.0.246:3000"; // Local backend address

/// Save XML to file
Future<File> saveXmlFile(String xmlContent, [Directory? directory]) async {
  directory ??= await getTemporaryDirectory();
  final file = File('${directory.path}/transposed_sheet.xml');
  await file.writeAsString(xmlContent);
  return file;
}

/// Share XML
Future<void> shareXmlContent(String xmlContent) async {
  final file = await saveXmlFile(xmlContent);
  Share.shareXFiles(
    [XFile(file.path)],
    text: 'Check out my transposed sheet music!',
  );
}

/// Save to Downloads folder
Future<void> saveToDownloads(File file) async {
  if (Platform.isAndroid) {
    final status = await Permission.storage.request();
    if (status.isGranted) {
      final downloads = Directory('/storage/emulated/0/Download');
      final fileName = file.path.split('/').last;
      await file.copy('${downloads.path}/$fileName');
      print('✅ Saved to Downloads');
    } else {
      print('❌ Storage permission denied');
    }
  } else if (Platform.isIOS) {
    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Here is your exported file!',
    );
  }
}