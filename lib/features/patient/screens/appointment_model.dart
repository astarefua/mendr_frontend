// lib/data/models/appointment.dart
class Appointment {
  final int? id;
  final int doctorId;
  final int patientId;
  final DateTime appointmentDate;
  final String status;
  final bool? paid;
  final String? videoRoomUrl;
  final Doctor? doctor;
  final Patient? patient;

  Appointment({
    this.id,
    required this.doctorId,
    required this.patientId,
    required this.appointmentDate,
    this.status = 'PENDING',
    this.paid,
    this.videoRoomUrl,
    this.doctor,
    this.patient,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'],
      doctorId: json['doctorId'] ?? json['doctor']?['id'],
      patientId: json['patientId'] ?? json['patient']?['id'],
      appointmentDate: DateTime.parse(json['appointmentDate']),
      status: json['status'] ?? 'PENDING',
      paid: json['paid'],
      videoRoomUrl: json['videoRoomUrl'],
      doctor: json['doctor'] != null ? Doctor.fromJson(json['doctor']) : null,
      patient: json['patient'] != null ? Patient.fromJson(json['patient']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'doctorId': doctorId,
      'patientId': patientId,
      'appointmentDate': appointmentDate.toIso8601String(),
    };
  }
}

class Doctor {
  final int id;
  final String name;
  final String specialty;
  final String? profilePictureUrl;
  final int? yearsOfExperience;
  final String? bio;

  Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    this.profilePictureUrl,
    this.yearsOfExperience,
    this.bio,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'],
      name: json['name'],
      specialty: json['specialty'],
      profilePictureUrl: json['profilePictureUrl'],
      yearsOfExperience: json['yearsOfExperience'],
      bio: json['bio'],
    );
  }
}

class Patient {
  final int id;
  final String name;
  final String email;
  final String? profilePictureUrl;

  Patient({
    required this.id,
    required this.name,
    required this.email,
    this.profilePictureUrl,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      profilePictureUrl: json['profilePictureUrl'],
    );
  }
}

class DoctorAvailability {
  final int id;
  final int doctorId;
  final String dayOfWeek;
  final String startTime;
  final String endTime;

  DoctorAvailability({
    required this.id,
    required this.doctorId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
  });

  factory DoctorAvailability.fromJson(Map<String, dynamic> json) {
    return DoctorAvailability(
      id: json['id'],
      doctorId: json['doctorId'],
      dayOfWeek: json['dayOfWeek'],
      startTime: json['startTime'],
      endTime: json['endTime'],
    );
  }
}
