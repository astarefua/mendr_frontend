// Updated VideoLauncherScreen to pass appointmentId
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:telemed_frontend/features/video_call/video_call_screen.dart';

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
  static const String baseUrl = 'http://10.0.2.2:8080';

  void _startVideoCall() async {
    setState(() => _loading = true);
    
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/appointments/${widget.appointmentId}/start-video-call'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final roomUrl = responseData['roomUrl'] as String;
        
        // Pass appointmentId to VideoCallScreen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoCallScreen(
              roomUrl: roomUrl,
              appointmentId: widget.appointmentId, // Pass the appointmentId
            ),
          ),
        );
      } else {
        _handleError(response);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connection error: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _handleError(http.Response response) {
    if (response.statusCode == 404) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointment not found')),
      );
    } else {
      try {
        final errorData = json.decode(response.body);
        final errorMessage = errorData['error'] ?? 'Failed to start video call';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.statusCode}')),
        );
      }
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
















