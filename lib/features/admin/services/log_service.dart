import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:telemed_frontend/features/admin/models/system_log_model.dart';
import '../../../utils/constants.dart'; // baseUrl


class LogService {
  static Future<List<SystemLog>> getLogs() async {
    final response = await http.get(Uri.parse('$baseUrl/api/admins/logs'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((log) => SystemLog.fromJson(log)).toList();
    } else {
      throw Exception('Failed to load logs');
    }
  }
}
