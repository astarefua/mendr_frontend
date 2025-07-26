import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:telemed_frontend/features/patient/services/firebase_service.dart';
import '../../utils/constants.dart'; // ✅ or the correct relative path


class AuthService {
  
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
  XFile? profileImage, // Changed from String to XFile?
}) async {
  try {
    final uri = Uri.parse('$baseUrl/auth/register-with-file');
    var request = http.MultipartRequest('POST', uri);
    
    // Add all form fields
    request.fields['email'] = email;
    request.fields['password'] = password;
    request.fields['role'] = role.toLowerCase();
    request.fields['name'] = name;
    request.fields['dateOfBirth'] = dateOfBirth;
    request.fields['gender'] = gender;
    request.fields['contactNumber'] = contactNumber;
    request.fields['emergencyContactName'] = emergencyContactName;
    request.fields['emergencyContactRelationship'] = emergencyContactRelationship;
    request.fields['emergencyContactPhone'] = emergencyContactPhone;
    
    // Add profile picture if provided
    if (profileImage != null) {
      var multipartFile = await http.MultipartFile.fromPath(
        'profilePicture',
        profileImage.path,
      );
      request.files.add(multipartFile);
    }
    
    final response = await request.send();
    print('Registration response status: ${response.statusCode}');
    
    if (response.statusCode != 200 && response.statusCode != 201) {
      final responseBody = await response.stream.bytesToString();
      print('Registration failed with response: $responseBody');
    }
    
    return response.statusCode == 200 || response.statusCode == 201;
    
  } catch (e) {
    print('Registration error: $e');
    return false;
  }
}


  
// Replace your existing registerDoctor method in AuthService with this updated version
static Future<bool> registerDoctor({
  required String name,
  required String email,
  required String password,
  required String role,
  required String specialty,
  required int yearsOfExperience,
  required String education,
  required String certifications,
  required String languagesSpoken,
  required String bio,
  required String affiliations,
  double reviewsRating = 0.0,
  XFile? profileImage, // Changed from String to XFile?
}) async {
  try {
    final uri = Uri.parse('$baseUrl/auth/register-doctor-with-file');
    var request = http.MultipartRequest('POST', uri);
    
    // Add all form fields
    request.fields['email'] = email;
    request.fields['password'] = password;
    request.fields['role'] = role.toLowerCase();
    request.fields['name'] = name;
    request.fields['specialty'] = specialty;
    request.fields['yearsOfExperience'] = yearsOfExperience.toString();
    request.fields['education'] = education;
    request.fields['certifications'] = certifications;
    request.fields['languagesSpoken'] = languagesSpoken;
    request.fields['affiliations'] = affiliations;
    request.fields['bio'] = bio;
    request.fields['reviewsRating'] = reviewsRating.toString();
    
    // Add profile picture if provided
    if (profileImage != null) {
      var multipartFile = await http.MultipartFile.fromPath(
        'profilePicture',
        profileImage.path,
      );
      request.files.add(multipartFile);
    }
    
    final response = await request.send();
    print('Doctor registration response status: ${response.statusCode}');
    
    if (response.statusCode != 200 && response.statusCode != 201) {
      final responseBody = await response.stream.bytesToString();
      print('Doctor registration failed with response: $responseBody');
    }
    
    return response.statusCode == 200 || response.statusCode == 201;
    
  } catch (e) {
    print('Doctor registration error: $e');
    return false;
  }
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

  

// Update your existing auth_service.dart login method
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
      
      // Register FCM token after successful login
      await FirebaseService.registerTokenWithBackend();
      
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































