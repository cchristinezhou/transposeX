import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'detect_key_screen.dart';

class ViewSheetScreen extends StatefulWidget {
  final String xmlContent;
  const ViewSheetScreen({required this.xmlContent});

  @override
  State<ViewSheetScreen> createState() => _ViewSheetScreenState();
}

class _ViewSheetScreenState extends State<ViewSheetScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    _controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageFinished: (url) async {
                print("✅ WebView finished loading: $url");
                Future.delayed(Duration(milliseconds: 300), () async {
                  final script = _buildInjectionScript(widget.xmlContent);
                  print("📦 Injecting script...");
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

    final encodedHtml =
        Uri.dataFromString(
          htmlWithTimestamp,
          mimeType: 'text/html',
          encoding: Encoding.getByName('utf-8'),
        ).toString();

    await _controller.loadRequest(Uri.parse(encodedHtml));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Sheet Preview
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: WebViewWidget(controller: _controller),
              ),
            ),
            const SizedBox(height: 16),

            // Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                children: [
                  SizedBox(
                    width: 250,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => DetectKeyScreen(
                                  xmlContent: widget.xmlContent,
                                ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 98, 85, 139),
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        "Looks Good",
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: 250,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(
                          color: Color.fromARGB(255, 98, 85, 139),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        "Reupload",
                        style: TextStyle(
                          color: Color.fromARGB(255, 98, 85, 139),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
