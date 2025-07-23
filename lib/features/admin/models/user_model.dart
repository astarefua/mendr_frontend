// models/user_summary.dart
class UserSummaryDTO {
  final int id;
  final String email;
  final String role;
  final String name;

  UserSummaryDTO({
    required this.id,
    required this.email,
    required this.role,
    required this.name,
  });

  factory UserSummaryDTO.fromJson(Map<String, dynamic> json) {
    return UserSummaryDTO(
      id: json['id'],
      email: json['email'],
      role: json['role'],
      name: json['name'] ?? '',
    );
  }
}
