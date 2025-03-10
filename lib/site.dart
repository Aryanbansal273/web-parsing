import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';

class WebViewPage extends StatefulWidget {
  const WebViewPage({super.key});

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  InAppWebViewController? webViewController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAndSetupWebView();
  }

  Future<void> _checkAndSetupWebView() async {
    PermissionStatus status = await Permission.location.request();

    if (status.isGranted) {
      _setupWebViewWithGeolocation();
    } else if (status.isDenied) {
      _setupWebViewWithoutGeolocation();
    } else if (status.isPermanentlyDenied) {
      _setupWebViewWithoutGeolocation();
      openAppSettings();
    }
  }
  void _setupWebViewWithGeolocation() {
    _loadWebView(geolocationEnabled: true);
  }
  void _setupWebViewWithoutGeolocation() {
    _loadWebView(geolocationEnabled: false);
  }
  void _loadWebView({required bool geolocationEnabled}) {
    setState(() {
      _isLoading = true;
    });
    webViewController?.loadUrl(
        urlRequest: URLRequest(url: WebUri.uri(Uri.parse("https://phoneo.in/"))));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(5.0),
        child: AppBar(
          backgroundColor: Color(0xFFf4f2f4),
        ),
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              geolocationEnabled: true,
              mediaPlaybackRequiresUserGesture: false,
              allowsInlineMediaPlayback: true,
              javaScriptCanOpenWindowsAutomatically: true,
            ),
            onWebViewCreated: (controller) {
              webViewController = controller;
              _loadWebView(geolocationEnabled: true);
            },
            onLoadStart: (controller, url) {
              setState(() {
                _isLoading = true;
              });
            },
            onLoadStop: (controller, url) {
              setState(() {
                _isLoading = false;
              });
            },
            onLoadError: (controller, url, code, message) {
              setState(() {
                _isLoading = false;
              });
            },
            androidOnGeolocationPermissionsShowPrompt: (InAppWebViewController controller, String origin) async {
              return GeolocationPermissionShowPromptResponse(origin: origin, allow: true, retain: false);
            },
            onConsoleMessage: (InAppWebViewController controller, ConsoleMessage consoleMessage) {
            },
          ),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}