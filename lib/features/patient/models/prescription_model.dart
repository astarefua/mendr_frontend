// didnt end up using this model , 

class Prescription {
  final String patientName;
  final String diagnosis;
  final String medication;
  final String appointmentId;

  Prescription({
    required this.patientName,
    required this.diagnosis,
    required this.medication,
    required this.appointmentId,
  });

  factory Prescription.fromJson(Map<String, dynamic> json) {
    return Prescription(
      patientName: json['patientName'],
      diagnosis: json['diagnosis'],
      medication: json['medication'],
      appointmentId: json['appointmentId'].toString(),
    );
  }
}
