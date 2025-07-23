import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../../utils/constants.dart'; // ✅ or the correct relative path


class AuthService {
  //static const String baseUrl = 'http://localhost:8080';

  static Future<bool> registerPatient({
    required String name,
    required String email,
    required String password,
    required String role,
    required String gender,
    required String contactNumber,
    required String emergencyContactName,
    required String emergencyContactRelationship,
    required String emergencyContactPhone,
    required String dateOfBirth,
    required String profilePictureUrl,
  }) async {
    final uri = Uri.parse('$baseUrl/auth/register');
    final response = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "password": password,
        "role": role.toLowerCase(),
        "name": name,
        "dateOfBirth": dateOfBirth,
        "gender": gender,
        "contactNumber": contactNumber,
        "emergencyContactName": emergencyContactName,
        "emergencyContactRelationship": emergencyContactRelationship,
        "emergencyContactPhone": emergencyContactPhone,
        "profilePictureUrl": profilePictureUrl,
      }),
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }

  static Future<bool> registerDoctor({
    required String name,
    required String email,
    required String password,
    required String role,
    required int age,
    required String specialty,
    required String profilePictureUrl,
    required int yearsOfExperience,
    required String education,
    required String certifications,
    required String languagesSpoken,
    required String bio,
    required String affiliations,
  }) async {
    final uri = Uri.parse('$baseUrl/auth/register');
    final response = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": name,
        "email": email,
        "password": password,
        "role": role.toLowerCase(),
        "age": age,
        "specialty": specialty,
        "profilePictureUrl": profilePictureUrl,
        "yearsOfExperience": yearsOfExperience,
        "education": education,
        "certifications": certifications,
        "languagesSpoken": languagesSpoken,
        "bio": bio,
        "affiliations": affiliations,
      }),
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }

  static Future<bool> registerAdmin({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    final uri = Uri.parse('$baseUrl/auth/register');
    final response = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "password": password,
        "name": name,
        "role": role.toLowerCase(),
      }),
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }

  // auth_service.dart
static Future<bool> login({required String email, required String password}) async {
  final uri = Uri.parse('$baseUrl/auth/login');
  final response = await http.post(
    uri,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({"email": email, "password": password}),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    if (data.containsKey('token')) {
      final token = data['token'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      return true;
    }
  }

  print('Login failed: ${response.statusCode} ${response.body}');
  return false;
}

  static Future<Map<String, dynamic>?> getUserFromToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null && !JwtDecoder.isExpired(token)) {
      return JwtDecoder.decode(token);
    }
    return null;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }
}































