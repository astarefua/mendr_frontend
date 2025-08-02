// services/review_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/review_models.dart';
import '../../../utils/constants.dart'; // Adjust path as needed

class ReviewService {
  
  // Get authorization header with JWT token
  static Future<Map<String, String>> _getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Submit a review for a doctor
  static Future<ReviewSubmissionResult> submitReview({
    required int doctorId,
    required int rating,
    required String comment,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/api/reviews/doctor/$doctorId');
      final headers = await _getAuthHeaders();
      
      final reviewDto = DoctorReviewDTO(
        rating: rating,
        comment: comment,
      );

      print('Submitting review to: $uri');
      print('Review data: ${reviewDto.toJson()}');

      final response = await http.post(
        uri,
        headers: headers,
        body: jsonEncode(reviewDto.toJson()),
      );

      print('Review submission response: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        final review = DoctorReviewDTO.fromJson(responseData);
        
        return ReviewSubmissionResult(
          success: true,
          review: review,
          message: 'Review submitted successfully!',
        );
      } else {
        // Handle different error cases
        String errorMessage = 'Failed to submit review';
        
        if (response.statusCode == 400) {
          errorMessage = 'You have already reviewed this doctor or invalid rating';
        } else if (response.statusCode == 403) {
          errorMessage = 'You can only review doctors after an appointment';
        } else if (response.statusCode == 404) {
          errorMessage = 'Doctor not found';
        }

        return ReviewSubmissionResult(
          success: false,
          message: errorMessage,
        );
      }
    } catch (e) {
      print('Review submission error: $e');
      return ReviewSubmissionResult(
        success: false,
        message: 'Network error. Please try again.',
      );
    }
  }

  // Get all reviews by the current patient
  static Future<List<ReviewAboutDoctorDTO>> getMyReviews() async {
    try {
      final uri = Uri.parse('$baseUrl/api/reviews/my-reviews');
      final headers = await _getAuthHeaders();

      print('Fetching reviews from: $uri');

      final response = await http.get(uri, headers: headers);

      print('Get reviews response: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> reviewsJson = jsonDecode(response.body);
        return reviewsJson
            .map((json) => ReviewAboutDoctorDTO.fromJson(json))
            .toList();
      } else {
        print('Failed to fetch reviews: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Get reviews error: $e');
      return [];
    }
  }
}