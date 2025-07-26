import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../utils/constants.dart';

class MedicationService {
  
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Get all medication guides for the patient
  static Future<List<SmartMedicationGuide>> getAllGuides() async {
    try {
      final uri = Uri.parse('$baseUrl/api/medication/guides');
      final headers = await _getHeaders();
      
      final response = await http.get(uri, headers: headers);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => SmartMedicationGuide.fromJson(json)).toList();
      } else {
        print('Failed to fetch medication guides: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching medication guides: $e');
      return [];
    }
  }

  // Get adherence history
  static Future<List<MedicationAdherence>> getAdherenceHistory() async {
    try {
      final uri = Uri.parse('$baseUrl/api/medication/adherence');
      final headers = await _getHeaders();
      
      final response = await http.get(uri, headers: headers);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => MedicationAdherence.fromJson(json)).toList();
      } else {
        print('Failed to fetch adherence history: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching adherence history: $e');
      return [];
    }
  }

  // Confirm dose taken
  static Future<bool> confirmDose(int guideId) async {
    try {
      final uri = Uri.parse('$baseUrl/api/medication/confirm/$guideId');
      final headers = await _getHeaders();
      
      final response = await http.post(uri, headers: headers);
      
      if (response.statusCode == 200) {
        print('Dose confirmed successfully');
        return true;
      } else {
        print('Failed to confirm dose: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error confirming dose: $e');
      return false;
    }
  }

  // Get progress for a specific medication guide
  static Future<MedicationProgress?> getProgress(int guideId) async {
    try {
      final uri = Uri.parse('$baseUrl/api/medication/progress/$guideId');
      final headers = await _getHeaders();
      
      final response = await http.get(uri, headers: headers);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return MedicationProgress.fromJson(data);
      } else {
        print('Failed to fetch progress: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching progress: $e');
      return null;
    }
  }

  // Get today's due medications
  static Future<List<SmartMedicationGuide>> getTodaysDueMedications() async {
    try {
      final uri = Uri.parse('$baseUrl/api/medication/due-today');
      final headers = await _getHeaders();
      
      final response = await http.get(uri, headers: headers);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => SmartMedicationGuide.fromJson(json)).toList();
      } else {
        print('Failed to fetch today\'s due medications: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching today\'s due medications: $e');
      return [];
    }
  }

  // Get dose calendar
  static Future<Map<String, List<String>>> getDoseCalendar() async {
    try {
      final uri = Uri.parse('$baseUrl/api/medication/calendar');
      final headers = await _getHeaders();
      
      final response = await http.get(uri, headers: headers);
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        Map<String, List<String>> calendar = {};
        
        data.forEach((key, value) {
          calendar[key] = List<String>.from(value);
        });
        
        return calendar;
      } else {
        print('Failed to fetch dose calendar: ${response.statusCode}');
        return {};
      }
    } catch (e) {
      print('Error fetching dose calendar: $e');
      return {};
    }
  }
}

// Model classes
class SmartMedicationGuide {
  final int id;
  final String medicationName;
  final String? visualDescription;
  final String? imageUrl;
  final String? usageInstruction;
  final String? animationUrl;
  final int dosesPerDay;
  final int totalDays;
  final String startDate;

  SmartMedicationGuide({
    required this.id,
    required this.medicationName,
    this.visualDescription,
    this.imageUrl,
    this.usageInstruction,
    this.animationUrl,
    required this.dosesPerDay,
    required this.totalDays,
    required this.startDate,
  });

  factory SmartMedicationGuide.fromJson(Map<String, dynamic> json) {
    return SmartMedicationGuide(
      id: json['id'],
      medicationName: json['medicationName'],
      visualDescription: json['visualDescription'],
      imageUrl: json['imageUrl'],
      usageInstruction: json['usageInstruction'],
      animationUrl: json['animationUrl'],
      dosesPerDay: json['dosesPerDay'],
      totalDays: json['totalDays'],
      startDate: json['startDate'],
    );
  }
}

class MedicationAdherence {
  final int id;
  final String takenAt;
  final SmartMedicationGuide guide;

  MedicationAdherence({
    required this.id,
    required this.takenAt,
    required this.guide,
  });

  factory MedicationAdherence.fromJson(Map<String, dynamic> json) {
    return MedicationAdherence(
      id: json['id'],
      takenAt: json['takenAt'],
      guide: SmartMedicationGuide.fromJson(json['guide']),
    );
  }
}

class MedicationProgress {
  final int expectedDoses;
  final int takenDoses;
  final double progressPercentage;
  final int remainingDoses;
  final bool isCompleted;

  MedicationProgress({
    required this.expectedDoses,
    required this.takenDoses,
    required this.progressPercentage,
    required this.remainingDoses,
    required this.isCompleted,
  });

  factory MedicationProgress.fromJson(Map<String, dynamic> json) {
    return MedicationProgress(
      expectedDoses: json['expectedDoses'],
      takenDoses: json['takenDoses'],
      progressPercentage: (json['progressPercentage'] as num).toDouble(),
      remainingDoses: json['remainingDoses'],
      isCompleted: json['isCompleted'],
    );
  }
}