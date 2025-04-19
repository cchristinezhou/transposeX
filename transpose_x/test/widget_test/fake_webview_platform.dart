import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';
import 'package:flutter/widgets.dart';

class FakeWebViewPlatform extends WebViewPlatform {
  @override
  PlatformWebViewController createPlatformWebView(
    PlatformWebViewControllerCreationParams params,
  ) {
    return _FakeWebViewPlatformController(params);
  }

  @override
PlatformWebViewController createPlatformWebViewController(
  PlatformWebViewControllerCreationParams params,
) {
  return _FakeWebViewPlatformController(params);
}

@override
PlatformNavigationDelegate createPlatformNavigationDelegate(
  PlatformNavigationDelegateCreationParams params,
) {
  return _FakeNavigationDelegate(params);
}

@override
PlatformWebViewWidget createPlatformWebViewWidget(
  PlatformWebViewWidgetCreationParams params,
) {
  return _FakeWebViewWidget(params);
}

@override
Future<void> loadRequest(LoadRequestParams params) async {
  // Optional: print or store the request for debugging
  print("🧪 FakeWebView: loadRequest called with ${params.uri}");
}

}

class _FakeWebViewPlatformController extends PlatformWebViewController {
  _FakeWebViewPlatformController(PlatformWebViewControllerCreationParams params)
      : super.implementation(params);

  @override
  Future<void> loadHtmlString(String html, {String? baseUrl}) async {}

  @override
  Future<void> runJavaScript(String javaScriptString) async {}

  @override
  Future<void> setJavaScriptMode(JavaScriptMode javaScriptMode) async {}

   @override
  Future<void> loadRequest(LoadRequestParams params) async {
    // 👇 This is what avoids the UnimplementedError
    print('🧪 FakeWebViewController.loadRequest: ${params.uri}');
  }

  @override
  Future<void> setPlatformNavigationDelegate(
      PlatformNavigationDelegate handler) async {}
}

class _FakeNavigationDelegate extends PlatformNavigationDelegate {
  _FakeNavigationDelegate(PlatformNavigationDelegateCreationParams params)
      : super.implementation(params);

  @override
  Future<void> setOnNavigationRequest(NavigationRequestCallback onNavigationRequest) async {}

  @override
  Future<void> setOnPageStarted(PageEventCallback onPageStarted) async {}

  @override
  Future<void> setOnPageFinished(PageEventCallback onPageFinished) async {}

  @override
  Future<void> setOnHttpError(HttpResponseErrorCallback onHttpError) async {}

  @override
  Future<void> setOnProgress(ProgressCallback onProgress) async {}

  @override
  Future<void> setOnWebResourceError(WebResourceErrorCallback onWebResourceError) async {}

  @override
  Future<void> setOnUrlChange(UrlChangeCallback onUrlChange) async {}

  @override
  Future<void> setOnHttpAuthRequest(HttpAuthRequestCallback onHttpAuthRequest) async {}
}

class _FakeWebViewWidget extends PlatformWebViewWidget {
  _FakeWebViewWidget(PlatformWebViewWidgetCreationParams params) : super.implementation(params);

  @override
  Widget build(BuildContext context) {
    // ✅ Give it height to prevent Column layout from failing
    return Container(
      height: 1600,
      width: double.infinity,
      color: const Color(0xFFE0E0E0),
      alignment: Alignment.center,
      child: const Text('🔍 Fake WebView'),
    );
  }
}