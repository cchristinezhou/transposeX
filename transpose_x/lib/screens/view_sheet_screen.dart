import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:path_provider/path_provider.dart';

import '../utils/file_export.dart';
import 'package:share_plus/share_plus.dart';
import '../services/api_service.dart';

class ViewSheetScreen extends StatefulWidget {
  final String xmlContent;
  final String keySignature;
  final String fileName;
  final String initialTitle;

  const ViewSheetScreen({
    Key? key,
    required this.xmlContent,
    required this.keySignature,
    required this.fileName,
    this.initialTitle = "Untitled Sheet",
  }) : super(key: key);

  @override
  State<ViewSheetScreen> createState() => _ViewSheetScreenState();
}

class _ViewSheetScreenState extends State<ViewSheetScreen> {
  late WebViewController _controller;
  late String _title;
  double _zoomFactor = 1.0;

  final GlobalKey _previewKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _title = widget.fileName.isNotEmpty ? widget.fileName : widget.initialTitle;
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) => _injectXml(widget.xmlContent),
        ),
      );
    _loadViewerHtml();
  }

  Future<void> _loadViewerHtml() async {
    final html = await rootBundle.loadString('assets/viewer.html');
    final encodedHtml = Uri.dataFromString(
      html,
      mimeType: 'text/html',
      encoding: Encoding.getByName('utf-8'),
    ).toString();

    _controller.loadRequest(Uri.parse(encodedHtml));
  }

  Future<void> _injectXml(String xml) async {
    final encoded = base64Encode(utf8.encode(xml));
    final script = """
      const xmlStr = atob('$encoded');
      window.postMessage({ type: 'loadXml', xml: xmlStr });
    """;
    _controller.runJavaScript(script);
  }

  Future<void> _zoom(double factor) async {
    _zoomFactor = (_zoomFactor * factor).clamp(0.5, 3.0);
    await _controller.runJavaScript(
      "document.body.style.zoom = '$_zoomFactor';",
    );
  }

 void _showRenameDialog() {
  final controller = TextEditingController(text: _title);

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text("Rename Your Sheet"),
      content: TextField(
        controller: controller,
        decoration: InputDecoration(hintText: "Enter new title"),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Cancel"),
        ),
        TextButton(
          onPressed: () async {
            final newName = controller.text.trim();
            if (newName.isEmpty) return;

            setState(() {
              _title = newName;
            });
            Navigator.pop(context);

            try {
              // TODO: call your backend to save new name
              final success = await ApiService.renameSheet(widget.fileName, newName);

              if (!mounted) return;
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("✅ Renamed successfully!")),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("❌ Failed to rename on server.")),
                );
              }
            } catch (e) {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("❌ Error updating name.")),
              );
              print('❌ Rename error: $e');
            }
          },
          child: Text("Save"),
        ),
      ],
    ),
  );
}

  void _showDownloadOptions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDownloadOption("XML", Icons.code, () async {
              try {
                final file = await saveXmlFile(widget.xmlContent);
                await saveToDownloads(file);
                _showSuccessSnackBar();
              } catch (e) {
                print('❌ XML save failed: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("❌ Failed to save XML.")),
                );
              }
            }),
          ],
        ),
      ),
    );
  }

  void _shareXml() {
    shareXmlContent(widget.xmlContent);
  }

  Widget _buildDownloadOption(String label, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(label),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(_title),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(icon: Icon(Icons.zoom_in), onPressed: () => _zoom(1.2)),
          IconButton(icon: Icon(Icons.zoom_out), onPressed: () => _zoom(0.8)),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == "Rename") {
                _showRenameDialog();
              } else if (value == "Download") {
                _showDownloadOptions();
              } else if (value == "Share") {
                _shareXml();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: "Rename", child: Text("Rename")),
              PopupMenuItem(value: "Download", child: Text("Download XML")),
              PopupMenuItem(value: "Share", child: Text("Share XML")),
            ],
          ),
        ],
      ),
      body: RepaintBoundary(
        key: _previewKey,
        child: WebViewWidget(controller: _controller),
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
}