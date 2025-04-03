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
              onPageFinished: (_) async {
                final encoded = base64Encode(utf8.encode(widget.xmlContent));
                final script = """
            const xmlStr = atob('$encoded');
            window.postMessage({ type: 'loadXml', xml: xmlStr });
          """;
                _controller.runJavaScript(script);
              },
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

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.white,
    appBar: AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: true,
    ),
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8.0), // small space above WebView
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.65,
            child: WebViewWidget(controller: _controller),
          ),
        ),
        const SizedBox(height: 16),
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
                      MaterialPageRoute(builder: (context) => DetectKeyScreen(
                        xmlContent: widget.xmlContent,
                      )),
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
                    side: BorderSide(color: Color.fromARGB(255, 98, 85, 139)),
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
  );
}
}
