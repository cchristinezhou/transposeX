// file_export.dart

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

Future<File> saveXmlFile(String xmlContent, [Directory? directory]) async {
  directory ??= await getTemporaryDirectory();
  final file = File('${directory.path}/transposed_sheet.xml');
  await file.writeAsString(xmlContent);
  return file;
}

Future<void> shareXmlContent(String xmlContent) async {
  final file = await saveXmlFile(xmlContent);
  Share.shareXFiles(
    [XFile(file.path)],
    text: 'Check out my transposed sheet music!',
  );
}

Future<File> convertWebViewToPdf(
  WebViewController controller,
  Directory directory,
) async {
  final pdf = pw.Document();
  pdf.addPage(
    pw.Page(
      build: (pw.Context context) => pw.Center(
        child: pw.Text("Transposed Sheet Music (PDF preview only)"),
      ),
    ),
  );

  final output = File('${directory.path}/transposed_sheet.pdf');
  await output.writeAsBytes(await pdf.save());
  return output;
}

Future<File> captureWebViewToImage(
  GlobalKey previewKey,
  Directory directory,
) async {
  try {
    final boundary =
        previewKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = byteData!.buffer.asUint8List();

    final file = File('${directory.path}/transposed_sheet.jpg');
    await file.writeAsBytes(pngBytes);
    return file;
  } catch (e) {
    print("JPEG capture failed: $e");
    return File('');
  }
}

Future<void> saveToDownloads(File file) async {
  if (Platform.isAndroid) {
    final status = await Permission.storage.request();
    if (status.isGranted) {
      final downloads = Directory('/storage/emulated/0/Download');
      final fileName = file.path.split('/').last;
      final newFile = await file.copy('${downloads.path}/$fileName');
      print('Saved to: ${newFile.path}');
    } else {
      print('Storage permission denied');
    }
  } else if (Platform.isIOS) {
    // iOS has no public Downloads folder — fallback to share sheet
    await Share.shareXFiles([XFile(file.path)],
        text: 'Here is your exported file!');
  }
}