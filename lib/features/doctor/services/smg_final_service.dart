import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../utils/constants.dart'; // Import your constants file

class SmartMedicationGuide {
  final int id;
  final String medicationName;
  final String visualDescription;
  final String? imageUrl;
  final String usageInstruction;
  final String? animationUrl;
  final int dosesPerDay;
  final int totalDays;
  final DateTime startDate;
  final Map<String, dynamic> patient;
  final Map<String, dynamic> doctor;

  SmartMedicationGuide({
    required this.id,
    required this.medicationName,
    required this.visualDescription,
    this.imageUrl,
    required this.usageInstruction,
    this.animationUrl,
    required this.dosesPerDay,
    required this.totalDays,
    required this.startDate,
    required this.patient,
    required this.doctor,
  });

  factory SmartMedicationGuide.fromJson(Map<String, dynamic> json) {
    return SmartMedicationGuide(
      id: json['id'],
      medicationName: json['medicationName'] ?? '',
      visualDescription: json['visualDescription'] ?? '',
      imageUrl: json['imageUrl'],
      usageInstruction: json['usageInstruction'] ?? '',
      animationUrl: json['animationUrl'],
      dosesPerDay: json['dosesPerDay'] ?? 1,
      totalDays: json['totalDays'] ?? 1,
      startDate: DateTime.parse(json['startDate']),
      patient: json['patient'] ?? {},
      doctor: json['doctor'] ?? {},
    );
  }
}

class MedicationGuideService {
  static Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<Map<String, String>> _getHeaders() async {
    final token = await _getAuthToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<List<SmartMedicationGuide>> getDoctorGuides() async {
    try {
      final uri = Uri.parse('$baseUrl/api/medication-guides');
      final headers = await _getHeaders();
      
      print('Making request to: $uri');
      print('Headers: $headers');
      
      final response = await http.get(uri, headers: headers);
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        // Check if response body is empty
        if (response.body.isEmpty) {
          return [];
        }
        
        try {
          final dynamic responseData = jsonDecode(response.body);
          
          // Handle case where response might be a single object instead of array
          if (responseData is List) {
            final List<dynamic> jsonList = responseData;
            return jsonList.map((json) => SmartMedicationGuide.fromJson(json)).toList();
          } else {
            // If it's not a list, return empty list or handle as needed
            print('Unexpected response format: $responseData');
            return [];
          }
        } catch (jsonError) {
          print('JSON parsing error: $jsonError');
          print('Response body was: ${response.body}');
          throw Exception('Invalid JSON response from server');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please login again');
      } else {
        // Log the actual error response
        print('Error response body: ${response.body}');
        throw Exception('Failed to load medication guides: ${response.statusCode}\nResponse: ${response.body}');
      }
    } catch (e) {
      print('Full error details: $e');
      throw Exception('Error fetching medication guides: $e');
    }
  }

  static Future<bool> createMedicationGuide({
    required int patientId,
    required String medicationName,
    required String visualDescription,
    String? imageUrl,
    required String usageInstruction,
    String? animationUrl,
    required int dosesPerDay,
    required int totalDays,
    required DateTime startDate,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/api/medication-guides');
      final headers = await _getHeaders();
      
      final body = jsonEncode({
        'patientId': patientId,
        'medicationName': medicationName,
        'visualDescription': visualDescription,
        'imageUrl': imageUrl,
        'usageInstruction': usageInstruction,
        'animationUrl': animationUrl,
        'dosesPerDay': dosesPerDay,
        'totalDays': totalDays,
        'startDate': startDate.toIso8601String().split('T')[0], // Format as YYYY-MM-DD
      });
      
      final response = await http.post(uri, headers: headers, body: body);
      
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error creating medication guide: $e');
      return false;
    }
  }

  static Future<bool> updateMedicationGuide({
    required int id,
    required int patientId,
    required String medicationName,
    required String visualDescription,
    String? imageUrl,
    required String usageInstruction,
    String? animationUrl,
    required int dosesPerDay,
    required int totalDays,
    required DateTime startDate,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/api/medication-guides/$id');
      final headers = await _getHeaders();
      
      final body = jsonEncode({
        'patientId': patientId,
        'medicationName': medicationName,
        'visualDescription': visualDescription,
        'imageUrl': imageUrl,
        'usageInstruction': usageInstruction,
        'animationUrl': animationUrl,
        'dosesPerDay': dosesPerDay,
        'totalDays': totalDays,
        'startDate': startDate.toIso8601String().split('T')[0],
      });
      
      final response = await http.put(uri, headers: headers, body: body);
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error updating medication guide: $e');
      return false;
    }
  }

  static Future<bool> deleteMedicationGuide(int id) async {
    try {
      final uri = Uri.parse('$baseUrl/api/medication-guides/$id');
      final headers = await _getHeaders();
      
      final response = await http.delete(uri, headers: headers);
      
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('Error deleting medication guide: $e');
      return false;
    }
  }
}