// models/analytics_models.dart
class OverviewStats {
  final int totalPatients;
  final int totalDoctors;
  final int pendingDoctorApprovals;
  final int totalAppointments;
  final Map<String, int> appointmentsByStatus;

  OverviewStats({
    required this.totalPatients,
    required this.totalDoctors,
    required this.pendingDoctorApprovals,
    required this.totalAppointments,
    required this.appointmentsByStatus,
  });

  factory OverviewStats.fromJson(Map<String, dynamic> json) {
    return OverviewStats(
      totalPatients: json['totalPatients'] ?? 0,
      totalDoctors: json['totalDoctors'] ?? 0,
      pendingDoctorApprovals: json['pendingDoctorApprovals'] ?? 0,
      totalAppointments: json['totalAppointments'] ?? 0,
      appointmentsByStatus: Map<String, int>.from(json['appointmentsByStatus'] ?? {}),
    );
  }
}

class AppointmentTrendDTO {
  final String date;
  final int count;

  AppointmentTrendDTO({required this.date, required this.count});

  factory AppointmentTrendDTO.fromJson(Map<String, dynamic> json) {
    return AppointmentTrendDTO(
      date: json['date'],
      count: json['count'],
    );
  }
}
