import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'home_screen.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

// Utility to share XML content
Future<void> shareXmlContent(String xmlContent) async {
  final directory = await getTemporaryDirectory();
  final filePath = '${directory.path}/transposed_music.xml';
  final file = File(filePath);
  await file.writeAsString(xmlContent);

  Share.shareXFiles([XFile(filePath)], text: 'Check out my transposed sheet music!');
}

class TransposeResultScreen extends StatefulWidget {
  final String transposedXml;

  const TransposeResultScreen({Key? key, required this.transposedXml})
      : super(key: key);

  @override
  State<TransposeResultScreen> createState() => _TransposeResultScreenState();
}

class _TransposeResultScreenState extends State<TransposeResultScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) => _loadXml(),
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

  Future<void> _loadXml() async {
    final encoded = base64Encode(utf8.encode(widget.transposedXml));
    final script = """
      const xmlStr = atob('$encoded');
      window.postMessage({ type: 'loadXml', xml: xmlStr });
    """;
    _controller.runJavaScript(script);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: WebViewWidget(controller: _controller),
            ),
            SizedBox(height: 24),
            Column(
              children: [
                _buildButton(
                  icon: Icons.remove_red_eye_outlined,
                  label: "View",
                  onPressed: () {
                    // Already viewing, optional
                  },
                ),
                SizedBox(height: 10),
                _buildButton(
                  icon: Icons.download,
                  label: "Download",
                  onPressed: () {
                    // TODO: Hook up download logic
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Download coming soon!")),
                    );
                  },
                ),
                SizedBox(height: 10),
                _buildButton(
                  icon: Icons.share,
                  label: "Share",
                  onPressed: () {
                    shareXmlContent(widget.transposedXml);
                  },
                ),
                SizedBox(height: 10),
                _buildButton(
                  icon: Icons.music_note,
                  label: "Transpose Another One?",
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => HomeScreen()),
                      (route) => false,
                    );
                  },
                ),
                SizedBox(height: 32),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton({
  required IconData icon,
  required String label,
  required VoidCallback onPressed,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6.0),
    child: SizedBox(
      width: 250,
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
          mainAxisSize: MainAxisSize.min,
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
}