// features/admin/models/doctor_response_model.dart
// 🆕 PENDING CODE: Doctor response model for pending doctors
class DoctorResponseDTO {
  final int id;
  final String name;
  final String email;
  final String specialty;
  final bool isApproved;
  final String? profilePictureUrl;
  final int? yearsOfExperience;
  final String? education;
  final List<String>? certifications;
  final List<String>? languagesSpoken;
  final String? affiliations;
  final String? bio;
  final double? reviewsRating;

  DoctorResponseDTO({
    required this.id,
    required this.name,
    required this.email,
    required this.specialty,
    required this.isApproved,
    this.profilePictureUrl,
    this.yearsOfExperience,
    this.education,
    this.certifications,
    this.languagesSpoken,
    this.affiliations,
    this.bio,
    this.reviewsRating,
  });

  factory DoctorResponseDTO.fromJson(Map<String, dynamic> json) {
    return DoctorResponseDTO(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      specialty: json['specialty'] ?? '',
      isApproved: json['approved'] ?? false,
      profilePictureUrl: json['profilePictureUrl'],
      yearsOfExperience: json['yearsOfExperience'],
      education: json['education'],
      // ✅ Fixed: Handle both String and List cases
      certifications: _parseStringOrList(json['certifications']),
      languagesSpoken: _parseStringOrList(json['languagesSpoken']),
      // ✅ Fixed: affiliations should be String, not List<String>
      affiliations: json['affiliations'],
      bio: json['bio'],
      reviewsRating: json['reviewsRating']?.toDouble(),
    );
  }

  // Helper method to handle String or List conversion
  static List<String>? _parseStringOrList(dynamic value) {
    if (value == null) return null;
    
    if (value is String) {
      // If it's a string, split by comma and trim whitespace
      return value.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    } else if (value is List) {
      // If it's already a list, convert to List<String>
      return List<String>.from(value);
    }
    
    return null;
  }
}



















// // features/admin/models/doctor_response_model.dart
// // 🆕 PENDING CODE: Doctor response model for pending doctors
// class DoctorResponseDTO {
//   final int id;
//   final String name;
//   final String email;
//   final String specialty;
//   final bool isApproved;
//   final String? profilePictureUrl;
//   final int? yearsOfExperience;
//   final String? education;
//   final List<String>? certifications;
//   final List<String>? languagesSpoken;
//   final String? affiliations;
//   final String? bio;
//   final double? reviewsRating;

//   DoctorResponseDTO({
//     required this.id,
//     required this.name,
//     required this.email,
//     required this.specialty,
//     required this.isApproved,
//     this.profilePictureUrl,
//     this.yearsOfExperience,
//     this.education,
//     this.certifications,
//     this.languagesSpoken,
//     this.affiliations,
//     this.bio,
//     this.reviewsRating,
//   });

//   factory DoctorResponseDTO.fromJson(Map<String, dynamic> json) {
//     return DoctorResponseDTO(
//       id: json['id'],
//       name: json['name'] ?? '',
//       email: json['email'] ?? '',
//       specialty: json['specialty'] ?? '',
//       isApproved: json['approved'] ?? false,
//       profilePictureUrl: json['profilePictureUrl'],
//       yearsOfExperience: json['yearsOfExperience'],
//       education: json['education'],
//       certifications: json['certifications'] != null 
//           ? List<String>.from(json['certifications']) 
//           : null,
//       languagesSpoken: json['languagesSpoken'] != null 
//           ? List<String>.from(json['languagesSpoken']) 
//           : null,
//       affiliations: json['affiliations'],
//       bio: json['bio'],
//       reviewsRating: json['reviewsRating']?.toDouble(),
//     );
//   }
// }