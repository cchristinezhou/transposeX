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
import '../services/api_service.dart';

class TransposeResultScreen extends StatefulWidget {
  final String transposedXml;
  final String originalKey;
  final String transposedKey;
  final String? songName;

  const TransposeResultScreen({
    Key? key,
    required this.transposedXml,
    required this.originalKey,
    required this.transposedKey,
    required this.songName,
  }) : super(key: key);

  @override
  State<TransposeResultScreen> createState() => _TransposeResultScreenState();
}

class _TransposeResultScreenState extends State<TransposeResultScreen> {
  late final WebViewController _controller;
  final GlobalKey previewContainer = GlobalKey();

  int? _xmlSize;
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

    setState(() {
      _xmlSize = xmlSize;
      _showPreview = true;
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
                  Opacity(
                    opacity: 0.0,
                    alwaysIncludeSemantics: false,
                    child: RepaintBoundary(
                      key: previewContainer,
                      child: _buildSheetPreview(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Column(
              children: [
                _buildButton(Icons.remove_red_eye_outlined, "View", () async {
                  if (_xmlSize == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("❗ No XML content available.")),
                    );
                    return;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => ViewSheetScreen(
                            keySignature: widget.transposedKey,
                            xmlContent: widget.transposedXml,
                            fileName: widget.songName ?? "Untitled Song",
                          ),
                    ),
                  );
                }),
                const SizedBox(height: 10),
                _buildButton(
                  Icons.save_alt,
                  "Save to Library",
                  _handleSaveToLibrary,
                ),
                const SizedBox(height: 10),
                _buildButton(Icons.download, "Download XML", _downloadXml),
                const SizedBox(height: 10),
                _buildButton(Icons.share, "Share XML", () {
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
            "Transposition successful! You can now download or share your sheet.",
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

  void _handleSaveToLibrary() {
    final TextEditingController controller = TextEditingController();
    final scaffoldContext = context;

    showDialog(
      context: scaffoldContext,
      builder:
          (dialogContext) => AlertDialog(
            title: Text("Name your sheet"),
            content: TextField(
              controller: controller,
              decoration: InputDecoration(hintText: "e.g. My Transposed Song"),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text("Cancel"),
              ),
              TextButton(
                onPressed: () async {
                  final name = controller.text.trim();
                  Navigator.pop(dialogContext);

                  if (name.isEmpty) {
                    if (mounted) {
                      ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                        SnackBar(content: Text("❗ Please enter a name.")),
                      );
                    }
                    return;
                  }

                  final success = await ApiService.saveSongToDatabase(
                    name: name,
                    xml: widget.transposedXml,
                    originalKey: widget.originalKey,
                    transposedKey: widget.transposedKey,
                  );

                  if (!mounted) return;

                  ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? "✅ Saved to library as \"$name\""
                            : "❌ Failed to save. Try again.",
                      ),
                    ),
                  );
                },
                child: Text("Save"),
              ),
            ],
          ),
    );
  }

  void _downloadXml() async {
    final file = await saveXmlFile(widget.transposedXml);
    await saveToDownloads(file);
    _showSuccessSnackBar();
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
}
