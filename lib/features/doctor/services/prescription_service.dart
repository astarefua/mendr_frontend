// prescription_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../utils/constants.dart';

class PrescriptionService {
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Complete appointment
  static Future<Map<String, dynamic>?> completeAppointment(String appointmentId) async {
    final token = await _getToken();
    if (token == null) return null;

    final uri = Uri.parse('$baseUrl/api/appointments/$appointmentId/complete');
    final response = await http.put(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }

  // Create prescription
  static Future<Map<String, dynamic>?> createPrescription({
    required String appointmentId,
    required String medicationName,
    required String dosage,
    required String notes,
  }) async {
    final token = await _getToken();
    if (token == null) return null;

    final uri = Uri.parse('$baseUrl/api/prescriptions/appointment/$appointmentId');
    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'medicationName': medicationName,
        'dosage': dosage,
        'notes': notes,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    }
    return null;
  }
}