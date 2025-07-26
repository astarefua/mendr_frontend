
// smart_medication_guide_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../utils/constants.dart';

class SmartMedicationGuideService {
  
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<bool> createMedicationGuide({
    required int patientId,
    required String medicationName,
    required String visualDescription,
    required String imageUrl,
    required String usageInstruction,
    required String animationUrl,
    required int dosesPerDay,
    required int totalDays,
    required DateTime startDate,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final uri = Uri.parse('$baseUrl/api/medication-guides/guides');
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'patientId': patientId,
          'medicationName': medicationName,
          'visualDescription': visualDescription,
          'imageUrl': imageUrl.isEmpty ? null : imageUrl,
          'usageInstruction': usageInstruction,
          'animationUrl': animationUrl.isEmpty ? null : animationUrl,
          'dosesPerDay': dosesPerDay,
          'totalDays': totalDays,
          'startDate': startDate.toIso8601String().split('T')[0], // Format as YYYY-MM-DD
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Failed to create medication guide: ${response.statusCode} ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error creating medication guide: $e');
      return false;
    }
  }

  /// Gets medication guides for the current authenticated user
  /// - Patients: Only see their own guides
  /// - Doctors: Only see guides they created
  static Future<List<Map<String, dynamic>>> getCurrentUserMedicationGuides() async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      // Updated to use the privacy-protected endpoint
      final uri = Uri.parse('$baseUrl/api/medication-guides');
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        print('Failed to fetch medication guides: ${response.statusCode} ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error fetching medication guides: $e');
      return [];
    }
  }

  /// @deprecated This method violates privacy by allowing access to any patient's guides
  /// Use getCurrentUserMedicationGuides() instead
  @Deprecated('Use getCurrentUserMedicationGuides() for privacy protection')
  static Future<List<Map<String, dynamic>>> getPatientMedicationGuides(int patientId) async {
    // Redirect to privacy-safe method
    return getCurrentUserMedicationGuides();
  }

  static Future<Map<String, dynamic>?> getMedicationGuide(int guideId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final uri = Uri.parse('$baseUrl/api/medication-guides/$guideId');
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Failed to fetch medication guide: ${response.statusCode} ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error fetching medication guide: $e');
      return null;
    }
  }

  static Future<bool> updateMedicationGuide({
    required int guideId,
    required int patientId,
    required String medicationName,
    required String visualDescription,
    required String imageUrl,
    required String usageInstruction,
    required String animationUrl,
    required int dosesPerDay,
    required int totalDays,
    required DateTime startDate,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final uri = Uri.parse('$baseUrl/api/medication-guides/$guideId');
      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'patientId': patientId,
          'medicationName': medicationName,
          'visualDescription': visualDescription,
          'imageUrl': imageUrl.isEmpty ? null : imageUrl,
          'usageInstruction': usageInstruction,
          'animationUrl': animationUrl.isEmpty ? null : animationUrl,
          'dosesPerDay': dosesPerDay,
          'totalDays': totalDays,
          'startDate': startDate.toIso8601String().split('T')[0],
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Failed to update medication guide: ${response.statusCode} ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error updating medication guide: $e');
      return false;
    }
  }

  static Future<bool> deleteMedicationGuide(int guideId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final uri = Uri.parse('$baseUrl/api/medication-guides/$guideId');
      final response = await http.delete(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        print('Failed to delete medication guide: ${response.statusCode} ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error deleting medication guide: $e');
      return false;
    }
  }
}