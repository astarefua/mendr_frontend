// models/review_models.dart

class DoctorReviewDTO {
  final int rating;
  final String comment;
  final String? patientName;
  final String? doctorName;

  DoctorReviewDTO({
    required this.rating,
    required this.comment,
    this.patientName,
    this.doctorName,
  });

  Map<String, dynamic> toJson() {
    return {
      'rating': rating,
      'comment': comment,
      if (patientName != null) 'patientName': patientName,
      if (doctorName != null) 'doctorName': doctorName,
    };
  }

  factory DoctorReviewDTO.fromJson(Map<String, dynamic> json) {
    return DoctorReviewDTO(
      rating: json['rating'] ?? 0,
      comment: json['comment'] ?? '',
      patientName: json['patientName'],
      doctorName: json['doctorName'],
    );
  }
}

class ReviewAboutDoctorDTO {
  final int rating;
  final String comment;
  final String doctorName;

  ReviewAboutDoctorDTO({
    required this.rating,
    required this.comment,
    required this.doctorName,
  });

  factory ReviewAboutDoctorDTO.fromJson(Map<String, dynamic> json) {
    return ReviewAboutDoctorDTO(
      rating: json['rating'] ?? 0,
      comment: json['comment'] ?? '',
      doctorName: json['doctorName'] ?? json['doctorName'] ?? '',
    );
  }
}

class ReviewSubmissionResult {
  final bool success;
  final String? message;
  final DoctorReviewDTO? review;

  ReviewSubmissionResult({
    required this.success,
    this.message,
    this.review,
  });
}