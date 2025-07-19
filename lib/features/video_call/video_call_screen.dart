import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class VideoCallScreen extends StatefulWidget {
  final String roomUrl;

  const VideoCallScreen({super.key, required this.roomUrl});

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.roomUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Telemedicine Video Call')),
      body: WebViewWidget(controller: _controller),
    );
  }
}
