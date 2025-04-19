// coverage:ignore-file
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../utils/file_export.dart';
import '../services/api_service.dart';
import 'package:share_plus/share_plus.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// A screen that displays a MusicXML sheet using a WebView viewer.
///
/// Supports zooming, renaming, downloading, and sharing of sheet music.
/// Optimized for screen reader accessibility.
class ViewSheetScreen extends StatefulWidget {
  /// The MusicXML content.
  final String xmlContent;

  /// The key signature of the sheet.
  final String keySignature;

  /// The original filename of the sheet.
  final String fileName;

  /// The initial title to display if [fileName] is empty.
  final String initialTitle;

  /// Creates a [ViewSheetScreen].
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
    _controller =
        WebViewController()
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
    final encodedHtml =
        Uri.dataFromString(
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
    await _controller.runJavaScript(script);
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
      builder:
          (context) => AlertDialog(
            title: Semantics(
              header: true,
              child: Text("Rename Your Sheet", style: AppTextStyles.bodyMedium),
            ),
            content: Semantics(
              textField: true,
              child: TextField(
                controller: controller,
                decoration: const InputDecoration(hintText: "Enter new title"),
              ),
            ),
            actions: [
              Semantics(
                button: true,
                label: "Cancel renaming",
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Cancel",
                    style: AppTextStyles.primaryAction,
                  ),
                ),
              ),
              Semantics(
                button: true,
                label: "Save new title",
                child: TextButton(
                  onPressed: () async {
                    final newName = controller.text.trim();
                    if (newName.isEmpty) return;
                    setState(() {
                      _title = newName;
                    });
                    Navigator.pop(context);

                    try {
                      final success = await ApiService.renameSheet(
                        widget.fileName,
                        newName,
                      );
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            success
                                ? "✅ Renamed successfully!"
                                : "❌ Failed to rename on server.",
                          ),
                        ),
                      );
                    } catch (e) {
                      if (!mounted) return;
                      print('❌ Rename error: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("❌ Error updating name.")),
                      );
                    }
                  },
                  child: const Text("Save", style: AppTextStyles.primaryAction),
                ),
              ),
            ],
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
            child: _buildDownloadOption(
              "Download as XML",
              Icons.code,
              () async {
                try {
                  final file = await saveXmlFile(widget.xmlContent);
                  await saveToDownloads(file);
                  _showSuccessSnackBar();
                } catch (e) {
                  print('❌ XML save failed: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("❌ Failed to save XML.")),
                  );
                }
              },
            ),
          ),
    );
  }

  void _shareXml() {
    shareXmlContent(widget.xmlContent);
  }

  Widget _buildDownloadOption(String label, IconData icon, VoidCallback onTap) {
    return Semantics(
      button: true,
      label: "Download option: $label",
      child: ListTile(
        leading: Icon(icon, color: AppColors.accent),
        title: Text(label, style: AppTextStyles.bodyMedium),
        onTap: () {
          Navigator.pop(context);
          onTap();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.accent,
        elevation: 0,
        title: Semantics(
          header: true,
          child: Text(_title, style: AppTextStyles.bodyMedium),
        ),
        actions: [
          Semantics(
            button: true,
            label: "Zoom in sheet",
            child: IconButton(
              icon: const Icon(Icons.zoom_in),
              onPressed: () => _zoom(1.2),
            ),
          ),
          Semantics(
            button: true,
            label: "Zoom out sheet",
            child: IconButton(
              icon: const Icon(Icons.zoom_out),
              onPressed: () => _zoom(0.8),
            ),
          ),
          Semantics(
            button: true,
            label: "More options for sheet",
            child: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == "Rename") {
                  _showRenameDialog();
                } else if (value == "Download") {
                  _showDownloadOptions();
                } else if (value == "Share") {
                  _shareXml();
                }
              },
              itemBuilder:
                  (context) => const [
                    PopupMenuItem(value: "Rename", child: Text("Rename")),
                    PopupMenuItem(
                      value: "Download",
                      child: Text("Download XML"),
                    ),
                    PopupMenuItem(value: "Share", child: Text("Share XML")),
                  ],
            ),
          ),
        ],
      ),
      body: RepaintBoundary(
        key: _previewKey,
        child: Semantics(
          label: "Sheet music preview",
          child: WebViewWidget(controller: _controller),
        ),
      ),
    );
  }

  void _showSuccessSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white),
            SizedBox(width: 12),
            Text("Download successful!"),
          ],
        ),
        backgroundColor: AppColors.successGreen,
        duration: Duration(seconds: 2),
      ),
    );
  }
}
