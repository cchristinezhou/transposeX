import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'home_screen.dart';
import 'view_sheet_screen.dart';
import '../utils/file_export.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// A screen that displays the result of a successful transposition.
///
/// Provides options to view, download, save, or share the transposed sheet music.
class TransposeResultScreen extends StatefulWidget {
  /// The transposed MusicXML content.
  final String transposedXml;

  /// The original key signature.
  final String originalKey;

  /// The new, transposed key signature.
  final String transposedKey;

  /// The name of the song.
  final String? songName;

  /// Creates a [TransposeResultScreen].
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
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (_) => _loadXml(),
      ));
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

    if (mounted) {
      setState(() {
        _xmlSize = xmlSize;
        _showPreview = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  WebViewWidget(controller: _controller),
                  Opacity(
                    opacity: 0.0,
                    child: RepaintBoundary(
                      key: previewContainer,
                      child: _buildSheetPreview(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildOptions(),
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
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 1),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.music_note, size: 48, color: AppColors.primaryPurple),
          const SizedBox(height: 24),
          const Text(
            "Transposition successful! You can now download or share your sheet.",
            style: AppTextStyles.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOptions() {
    return Column(
      children: [
        _buildButton(Icons.remove_red_eye_outlined, "View", _handleView),
        _buildButton(Icons.save_alt, "Save to Library", _handleSaveToLibrary),
        _buildButton(Icons.download, "Download XML", _downloadXml),
        _buildButton(Icons.share, "Share XML", _handleShareXml),
        _buildButton(Icons.music_note, "Transpose Another One?", _handleTransposeAnother),
        const SizedBox(height: 32),
      ],
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
            backgroundColor: AppColors.primaryPurple,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.background),
              const SizedBox(width: 10),
              Text(
                label,
                style: AppTextStyles.primaryButton,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleView() {
    if (_xmlSize == null) {
      _showSnackBar("❗ No XML content available.", false);
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ViewSheetScreen(
          keySignature: widget.transposedKey,
          xmlContent: widget.transposedXml,
          fileName: widget.songName ?? "Untitled Song",
        ),
      ),
    );
  }

  void _handleSaveToLibrary() {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Name your sheet", style: AppTextStyles.bodyMedium),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "e.g. My Transposed Song"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancel", style: AppTextStyles.primaryAction),
          ),
          TextButton(
            onPressed: () async {
              final name = controller.text.trim();
              Navigator.pop(dialogContext);

              if (name.isEmpty) {
                _showSnackBar("❗ Please enter a name.", false);
                return;
              }

              final success = await ApiService.saveSongToDatabase(
                name: name,
                xml: widget.transposedXml,
                originalKey: widget.originalKey,
                transposedKey: widget.transposedKey,
              );

              if (!mounted) return;
              _showSnackBar(
                success
                    ? "✅ Saved to library as \"$name\""
                    : "❌ Failed to save. Try again.",
                success,
              );
            },
            child: const Text("Save", style: AppTextStyles.primaryAction),
          ),
        ],
      ),
    );
  }

  void _handleShareXml() {
    shareXmlContent(widget.transposedXml);
  }

  void _handleTransposeAnother() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => HomeScreen()),
      (route) => false,
    );
  }

  void _downloadXml() async {
    final file = await saveXmlFile(widget.transposedXml);
    await saveToDownloads(file);
    _showSnackBar("✅ Download successful!", true);
  }

  void _showSnackBar(String message, bool isSuccess) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle_outline : Icons.error_outline,
              color: AppColors.background,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isSuccess ? AppColors.successGreen : AppColors.warningRed,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}