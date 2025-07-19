import 'package:flutter/material.dart';
import 'package:telemed_frontend/services/video_service.dart';
import 'video_call_screen.dart';

class VideoLauncherScreen extends StatefulWidget {
  final String appointmentId;
  final String token;

  const VideoLauncherScreen({
    super.key,
    required this.appointmentId,
    required this.token,
  });

  @override
  State<VideoLauncherScreen> createState() => _VideoLauncherScreenState();
}

class _VideoLauncherScreenState extends State<VideoLauncherScreen> {
  bool _loading = false;

  void _startVideoCall() async {
  setState(() => _loading = true);
  try {
    final roomUrl = 'https://meet.jit.si/newmeetingggg'; // any unique room name

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoCallScreen(roomUrl: roomUrl),
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: ${e.toString()}')),
    );
  } finally {
    setState(() => _loading = false);
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Start Video Call")),
      body: Center(
        child: _loading
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: _startVideoCall,
                child: const Text("Join Video Room"),
              ),
      ),
    );
  }
}
