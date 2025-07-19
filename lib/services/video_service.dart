import 'dart:convert';
import 'package:http/http.dart' as http;

class VideoService {
  final String baseUrl = 'http://<your-ip>:8080/api/video'; // Replace with real IP or localhost

  Future<String> createVideoRoom(String appointmentId, String token) async {
    final url = Uri.parse('$baseUrl/generate-room');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'appointmentId': appointmentId}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['roomUrl'];
    } else {
      throw Exception('Failed to create video room: ${response.body}');
    }
  }
}
