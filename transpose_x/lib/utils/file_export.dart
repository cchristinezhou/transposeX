import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';

const String _baseUrl = 'http://10.0.0.134:3000'; // Local backend address

/// Saves XML content to a temporary file.
///
/// If [directory] is provided, saves the file inside that directory.
/// Otherwise, defaults to the device's temporary directory.
///
/// Returns the saved [File] object.
Future<File> saveXmlFile(String xmlContent, [Directory? directory]) async {
  directory ??= await getTemporaryDirectory();
  final file = File('${directory.path}/transposed_sheet.xml');
  await file.writeAsString(xmlContent);
  return file;
}

/// Shares XML content using the native sharing interface.
///
/// If a [context] is provided, a success [SnackBar] will be displayed
/// after sharing.
///
/// Example:
/// ```dart
/// await shareXmlContent(myXmlString, context: context);
/// ```
Future<void> shareXmlContent(String xmlContent, {BuildContext? context}) async {
  final file = await saveXmlFile(xmlContent);
  await Share.shareXFiles(
    [XFile(file.path)],
    text: 'Check out my transposed sheet music!',
  );

  if (context != null && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.check_circle_outline, color: Colors.white),
            SizedBox(width: 12),
            Text("Share Successful!"),
          ],
        ),
        backgroundColor: Colors.green[600],
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

/// Saves a [File] to the user's Downloads folder.
///
/// - On **Android**, manually copies the file to `/storage/emulated/0/Download/`.
/// - On **iOS**, opens the share sheet instead (since there's no public Downloads folder).
///
/// Requests storage permission on Android if necessary.
///
/// Example:
/// ```dart
/// final file = await saveXmlFile(xmlContent);
/// await saveToDownloads(file);
/// ```
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