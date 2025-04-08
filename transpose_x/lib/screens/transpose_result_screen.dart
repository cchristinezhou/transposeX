import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'home_screen.dart';
import 'view_sheet_screen.dart';
import '../utils/file_export.dart';

class TransposeResultScreen extends StatefulWidget {
  final String transposedXml;

  const TransposeResultScreen({Key? key, required this.transposedXml})
    : super(key: key);

  @override
  State<TransposeResultScreen> createState() => _TransposeResultScreenState();
}

class _TransposeResultScreenState extends State<TransposeResultScreen> {
  late final WebViewController _controller;
  final GlobalKey previewContainer = GlobalKey();

  File? _pdfFile;
  File? _jpegFile;
  int? _xmlSize;
  int? _pdfSize;
  int? _jpegSize;

  bool _showPreview = false;

  @override
  void initState() {
    super.initState();
    _initializeViewer();
    _generateExportFiles();
  }

  void _initializeViewer() {
    _controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(onPageFinished: (_) => _loadXml()),
          );
    _loadViewerHtml();
  }

  Future<void> _loadViewerHtml() async {
    final html = await rootBundle.loadString('assets/viewer.html');
    final encodedHtml =
        Uri.dataFromString(
          html,
          mimeType: 'text/html',
          encoding: Encoding.getByName('utf-8'),
        ).toString();
    _controller.loadRequest(Uri.parse(encodedHtml));
  }

  Future<void> _loadXml() async {
    final encoded = base64Encode(utf8.encode(widget.transposedXml));
    final script = """
      const xmlStr = atob('$encoded');
      window.postMessage({ type: 'loadXml', xml: xmlStr });
    """;
    _controller.runJavaScript(script);
  }

  Future<void> _generateExportFiles() async {
    final directory = await getTemporaryDirectory();

    final xmlFile = await saveXmlFile(widget.transposedXml, directory);
    final xmlSize = await xmlFile.length();

    final pdfFile = await convertWebViewToPdf(_controller, directory);

    setState(() => _showPreview = true);
    await Future.delayed(Duration(milliseconds: 500));

    final jpegFile = await captureWebViewToImage(previewContainer, directory);

    await Future.delayed(Duration(seconds: 3));
    setState(() => _showPreview = false);

    final pdfSize = await pdfFile.length();
    final jpegSize = await jpegFile.length();

    setState(() {
      _xmlSize = xmlSize;
      _pdfSize = pdfSize;
      _jpegSize = jpegSize;
      _pdfFile = pdfFile;
      _jpegFile = jpegFile;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  WebViewWidget(controller: _controller),
                  AnimatedOpacity(
                    opacity: _showPreview ? 1.0 : 0.0,
                    duration: Duration(milliseconds: 300),
                    child: Visibility(
                      visible: _showPreview,
                      maintainSize: true,
                      maintainAnimation: true,
                      maintainState: true,
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 40),
                          child: RepaintBoundary(
                            key: previewContainer,
                            child: _buildSheetPreview(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Column(
              children: [
                _buildButton(Icons.remove_red_eye_outlined, "View", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => ViewSheetScreen(
                            keySignature: "Unknown Key", // TODO: ADD REAL KEY
                            xmlContent: widget.transposedXml,
                          ),
                    ),
                  );
                }),
                const SizedBox(height: 10),
                _buildButton(Icons.download, "Download", _showDownloadOptions),
                const SizedBox(height: 10),
                _buildButton(Icons.share, "Share", () {
                  shareXmlContent(widget.transposedXml);
                }),
                const SizedBox(height: 10),
                _buildButton(Icons.music_note, "Transpose Another One?", () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => HomeScreen()),
                    (route) => false,
                  );
                }),
                const SizedBox(height: 32),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSheetPreview() {
    return Container(
      padding: const EdgeInsets.all(24),
      width: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 1),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(
            Icons.music_note,
            size: 48,
            color: Color.fromARGB(255, 98, 85, 139),
          ),
          SizedBox(height: 24),
          Text(
            "Tranposition successful! You can now download or share your sheet.",
            style: TextStyle(fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildButton(IconData icon, String label, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: SizedBox(
        width: 300,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 98, 85, 139),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 10),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDownloadOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (context) => Container(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDownloadOption(
                  "PDF",
                  _pdfSize,
                  Icons.picture_as_pdf,
                  () async {
                    if (_pdfFile != null) {
                      await saveToDownloads(_pdfFile!);
                      _showSuccessSnackBar();
                    }
                  },
                ),
                _buildDownloadOption("XML", _xmlSize, Icons.code, () async {
                  final file = await saveXmlFile(widget.transposedXml);
                  await saveToDownloads(file);
                  _showSuccessSnackBar();
                }),
                _buildDownloadOption("JPEG", _jpegSize, Icons.image, () async {
                  if (_jpegFile != null) {
                    await saveToDownloads(_jpegFile!);
                    _showSuccessSnackBar();
                  }
                }),
              ],
            ),
          ),
    );
  }

  void _showSuccessSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.check_circle_outline, color: Colors.white),
            SizedBox(width: 12),
            Text("Download successful!"),
          ],
        ),
        backgroundColor: Colors.green[600],
        duration: Duration(seconds: 2),
      ),
    );
  }

  Widget _buildDownloadOption(
    String label,
    int? size,
    IconData icon,
    VoidCallback onTap,
  ) {
    final sizeText = size != null ? _formatFileSize(size) : 'Loading...';
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(label),
      trailing: Text(sizeText),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes >= 1024 * 1024) {
      return "${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB";
    } else if (bytes >= 1024) {
      return "${(bytes / 1024).toStringAsFixed(1)} KB";
    } else {
      return "$bytes B";
    }
  }
}
