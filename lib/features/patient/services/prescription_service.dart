import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import '../../../utils/constants.dart';

class PrescriptionDTO {
  final int id;
  final String medicationName;
  final String dosage;
  final String notes;
  final String doctorName;
  final String patientName;
  final DateTime issuedAt;

  PrescriptionDTO({
    required this.id,
    required this.medicationName,
    required this.dosage,
    required this.notes,
    required this.doctorName,
    required this.patientName,
    required this.issuedAt,
  });

  factory PrescriptionDTO.fromJson(Map<String, dynamic> json) {
    return PrescriptionDTO(
      id: json['id'],
      medicationName: json['medicationName'] ?? '',
      dosage: json['dosage'] ?? '',
      notes: json['notes'] ?? '',
      doctorName: json['doctorName'] ?? '',
      patientName: json['patientName'] ?? '',
      issuedAt: DateTime.parse(json['issuedAt']),
    );
  }
}

class PrescriptionService {
  static Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Map<String, String> _getHeaders(String token) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Future<List<PrescriptionDTO>> getMyPrescriptions() async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final uri = Uri.parse('$baseUrl/api/prescriptions/me/patient');
      final response = await http.get(uri, headers: _getHeaders(token));

      print('Get prescriptions response: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => PrescriptionDTO.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized access. Please login again.');
      } else {
        throw Exception('Failed to load prescriptions: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching prescriptions: $e');
      throw Exception('Network error: $e');
    }
  }

  static Future<String?> downloadPrescriptionPdf(int appointmentId) async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final uri = Uri.parse('$baseUrl/api/prescriptions/$appointmentId/prescription/pdf');
      final response = await http.get(
        uri, 
        headers: {
          'Authorization': 'Bearer $token',
        }
      );

      print('Download PDF response: ${response.statusCode}');

      if (response.statusCode == 200) {
        // For Android - save to Downloads directory
        Directory? directory;
        String fileName = 'prescription_$appointmentId.pdf';
        
        if (Platform.isAndroid) {
          // Save to Downloads folder on Android
          directory = Directory('/storage/emulated/0/Download');
          if (!await directory.exists()) {
            // Fallback to external storage directory
            directory = await getExternalStorageDirectory();
          }
        } else {
          // For iOS and other platforms, use documents directory
          directory = await getApplicationDocumentsDirectory();
        }

        if (directory != null) {
          final file = File('${directory.path}/$fileName');
          await file.writeAsBytes(response.bodyBytes);
          
          print('PDF saved to: ${file.path}');
          return file.path;
        } else {
          throw Exception('Could not access storage directory');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized access. Please login again.');
      } else if (response.statusCode == 403) {
        throw Exception('Access denied. This prescription is not available for download.');
      } else if (response.statusCode == 404) {
        throw Exception('Prescription not found or appointment not completed.');
      } else {
        throw Exception('Failed to download prescription: ${response.statusCode}');
      }
    } catch (e) {
      print('Error downloading prescription: $e');
      throw Exception('Download error: $e');
    }
  }
}











