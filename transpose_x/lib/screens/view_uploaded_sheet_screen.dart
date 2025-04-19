import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'detect_key_screen.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// A screen that previews the uploaded MusicXML sheet for confirmation.
///
/// Users can proceed to key detection or reupload another file.
/// Accessibility optimized.
class ViewSheetScreen extends StatefulWidget {
  /// Raw XML content of the uploaded sheet.
  final String xmlContent;

  /// Creates a [ViewSheetScreen].
  const ViewSheetScreen({Key? key, required this.xmlContent}) : super(key: key);

  @override
  State<ViewSheetScreen> createState() => _ViewSheetScreenState();
}

class _ViewSheetScreenState extends State<ViewSheetScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) async {
            print("✅ WebView finished loading: $url");
            Future.delayed(const Duration(milliseconds: 300), () async {
              final script = _buildInjectionScript(widget.xmlContent);
              try {
                await _controller.runJavaScript(script);
                print("✅ Script injected");
              } catch (e) {
                print("❌ JavaScript injection failed: $e");
              }
            });
          },
        ),
      );
    _loadViewerHtml();
  }

  String _buildInjectionScript(String xmlContent) {
    final encoded = base64.encode(utf8.encode(xmlContent));
    return """
      (function() {
        try {
          const xmlStr = atob("$encoded");
          window.postMessage({ type: 'loadXml', xml: xmlStr }, "*");
        } catch (e) {
          console.error("⚠️ JS Injection error:", e);
        }
      })();
    """;
  }

  Future<void> _loadViewerHtml() async {
    final html = await rootBundle.loadString('assets/viewer.html');
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final htmlWithTimestamp = '$html<!-- $timestamp -->';

    final encodedHtml = Uri.dataFromString(
      htmlWithTimestamp,
      mimeType: 'text/html',
      encoding: Encoding.getByName('utf-8'),
    ).toString();

    await _controller.loadRequest(Uri.parse(encodedHtml));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        automaticallyImplyLeading: true,
        foregroundColor: AppColors.accent,
        title: Semantics(
          header: true,
          child: Text(
            'Sheet Preview',
            style: AppTextStyles.sectionHeading,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Sheet Preview
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Semantics(
                  label: "Preview of uploaded sheet music",
                  child: WebViewWidget(controller: _controller),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Action Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                children: [
                  _buildPrimaryButton(
                    label: "Looks Good",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetectKeyScreen(xmlContent: widget.xmlContent),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildSecondaryButton(
                    label: "Reupload",
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return Semantics(
      button: true,
      label: "Confirm the sheet and proceed",
      child: SizedBox(
        width: 250,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryPurple,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Text(label, style: AppTextStyles.primaryButton),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return Semantics(
      button: true,
      label: "Reupload another sheet",
      child: SizedBox(
        width: 250,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.primaryPurple),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Text(label, style: AppTextStyles.secondaryButton),
        ),
      ),
    );
  }
}