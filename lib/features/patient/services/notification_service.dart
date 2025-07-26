// services/notification_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationSettings {
  final bool notificationsEnabled;
  final int reminderMinutesBefore;
  final bool missedDoseReminders;
  final int missedDoseReminderMinutes;

  NotificationSettings({
    required this.notificationsEnabled,
    required this.reminderMinutesBefore,
    required this.missedDoseReminders,
    required this.missedDoseReminderMinutes,
  });

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      reminderMinutesBefore: json['reminderMinutesBefore'] ?? 5,
      missedDoseReminders: json['missedDoseReminders'] ?? true,
      missedDoseReminderMinutes: json['missedDoseReminderMinutes'] ?? 15,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notificationsEnabled': notificationsEnabled,
      'reminderMinutesBefore': reminderMinutesBefore,
      'missedDoseReminders': missedDoseReminders,
      'missedDoseReminderMinutes': missedDoseReminderMinutes,
    };
  }
}

class NotificationService {
  static const String baseUrl = 'http://10.0.2.2:8080'; // Update with your base URL

  static Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _getAuthToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Future<NotificationSettings?> getNotificationSettings() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/notifications/settings'),
        headers: await _getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return NotificationSettings.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error fetching notification settings: $e');
      return null;
    }
  }

  static Future<bool> updateNotificationSettings(NotificationSettings settings) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/notifications/settings'),
        headers: await _getAuthHeaders(),
        body: jsonEncode(settings.toJson()),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error updating notification settings: $e');
      return false;
    }
  }
}