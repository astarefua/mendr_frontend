import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:telemed_frontend/features/doctor/models/smart_note_model.dart';

class SmartNoteService {
  static const String baseUrl = 'http://10.0.2.2:8080';

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<bool> saveSmartNote(String appointmentId, SmartNoteModel note) async {
    try {
      final token = await _getToken();
      if (token == null) return false;

      final response = await http.post(
        Uri.parse('$baseUrl/api/smart-notes/$appointmentId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(note.toJson()),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error saving smart note: $e');
      return false;
    }
  }

  static Future<List<SmartNoteModel>> getSmartNotes(String appointmentId) async {
    try {
      final token = await _getToken();
      if (token == null) return [];

      final response = await http.get(
        Uri.parse('$baseUrl/api/smart-notes/$appointmentId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> notesJson = jsonDecode(response.body);
        return notesJson.map((json) => SmartNoteModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching smart notes: $e');
      return [];
    }
  }
}

