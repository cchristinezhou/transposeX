import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ViewSheetScreen extends StatefulWidget {
  final String xmlUrl;

  ViewSheetScreen({required this.xmlUrl});

  @override
  _ViewSheetScreenState createState() => _ViewSheetScreenState();
}

class _ViewSheetScreenState extends State<ViewSheetScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.xmlUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("View Sheet Music")),
      body: WebViewWidget(controller: _controller),
    );
  }
}