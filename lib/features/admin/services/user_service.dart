//services/admin_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:telemed_frontend/features/admin/models/analytics_model.dart';
import 'package:telemed_frontend/features/admin/models/doctor_model.dart';
import 'package:telemed_frontend/features/admin/models/system_log_model.dart';
import 'package:telemed_frontend/features/admin/models/user_model.dart';
import 'package:telemed_frontend/utils/constants.dart';




class AdminService {
  static Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _getAuthToken();
    if (token == null) throw Exception('No token found');
    
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  // Users Management
  static Future<List<UserSummaryDTO>> getAllUsers() async {
    final uri = Uri.parse('$baseUrl/api/admins/all-users');
    final response = await http.get(uri, headers: await _getAuthHeaders());

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => UserSummaryDTO.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load users: ${response.statusCode}');
    }
  }

  static Future<bool> deleteUser(int userId) async {
    final uri = Uri.parse('$baseUrl/api/admins/delete-user/$userId');
    final response = await http.delete(uri, headers: await _getAuthHeaders());
    return response.statusCode == 200;
  }


  static Future<List<SystemLog>> getLogs() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/admins/logs'),
        headers: headers,
      );

      print('📋 LOG SERVICE DEBUG:');
      print('URL: $baseUrl/api/admins/logs');
      print('Headers: $headers');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((log) => SystemLog.fromJson(log)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please login again');
      } else if (response.statusCode == 403) {
        throw Exception('Forbidden: Admin access required');
      } else {
        throw Exception('Failed to load logs: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ LOG SERVICE ERROR: $e');
      rethrow;
    }
  }


  

  // Analytics APIs
  static Future<OverviewStats> getOverviewStats() async {
    final uri = Uri.parse('$baseUrl/api/admin/analytics');
    final response = await http.get(uri, headers: await _getAuthHeaders());

    if (response.statusCode == 200) {
      return OverviewStats.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load overview stats: ${response.statusCode}');
    }
  }

  static Future<List<AppointmentTrendDTO>> getAppointmentTrend({String? from, String? to}) async {
    var uri = Uri.parse('$baseUrl/api/admin/analytics/appointments/trend');
    if (from != null || to != null) {
      final queryParams = <String, String>{};
      if (from != null) queryParams['from'] = from;
      if (to != null) queryParams['to'] = to;
      uri = uri.replace(queryParameters: queryParams);
    }

    final response = await http.get(uri, headers: await _getAuthHeaders());

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => AppointmentTrendDTO.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load appointment trend: ${response.statusCode}');
    }
  }

  static Future<Map<String, int>> getDoctorApprovalStats() async {
    final uri = Uri.parse('$baseUrl/api/admin/analytics/charts/doctor-approval-status');
    final response = await http.get(uri, headers: await _getAuthHeaders());

    if (response.statusCode == 200) {
      return Map<String, int>.from(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load doctor approval stats: ${response.statusCode}');
    }
  }

  static Future<Map<String, int>> getMostBookedDoctors() async {
    final uri = Uri.parse('$baseUrl/api/admin/analytics/appointments/most-booked-doctors');
    final response = await http.get(uri, headers: await _getAuthHeaders());

    if (response.statusCode == 200) {
      return Map<String, int>.from(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load most booked doctors: ${response.statusCode}');
    }
  }

  static Future<Map<int, int>> getAppointmentsByHour() async {
    final uri = Uri.parse('$baseUrl/api/admin/analytics/appointments/hourly');
    final response = await http.get(uri, headers: await _getAuthHeaders());

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return data.map((key, value) => MapEntry(int.parse(key), value as int));
    } else {
      throw Exception('Failed to load hourly appointments: ${response.statusCode}');
    }
  }

  static Future<Map<String, int>> getWeeklyPatientRegistrations() async {
    final uri = Uri.parse('$baseUrl/api/admin/analytics/patients/weekly-registrations?weeks=8');
    final response = await http.get(uri, headers: await _getAuthHeaders());

    if (response.statusCode == 200) {
      return Map<String, int>.from(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load weekly registrations: ${response.statusCode}');
    }
  }



  //Get all pending doctors
  static Future<List<DoctorResponseDTO>> getPendingDoctors() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/admins/pending-doctors'),
        headers: headers,
      );

      print('📋 PENDING DOCTORS DEBUG:');
      print('URL: $baseUrl/api/admins/pending-doctors');
      print('Headers: $headers');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((doctor) => DoctorResponseDTO.fromJson(doctor)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please login again');
      } else if (response.statusCode == 403) {
        throw Exception('Forbidden: Admin access required');
      } else {
        throw Exception('Failed to load pending doctors: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ PENDING DOCTORS SERVICE ERROR: $e');
      rethrow;
    }
  }

  // Approve a doctor
  static Future<bool> approveDoctor(int doctorId) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.patch(
        Uri.parse('$baseUrl/api/admins/approve-doctor/$doctorId'),
        headers: headers,
      );

      print('📋 APPROVE DOCTOR DEBUG:');
      print('URL: $baseUrl/api/admins/approve-doctor/$doctorId');
      print('Headers: $headers');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please login again');
      } else if (response.statusCode == 403) {
        throw Exception('Forbidden: Admin access required');
      } else if (response.statusCode == 404) {
        throw Exception('Doctor not found');
      } else {
        throw Exception('Failed to approve doctor: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ APPROVE DOCTOR SERVICE ERROR: $e');
      rethrow;
    }
  }
}



  












