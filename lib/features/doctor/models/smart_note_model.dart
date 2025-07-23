// smart_note_model.dart
class SmartNoteModel {
  final String symptom;
  final String bodyPart;
  final String severity;
  final String action;
  final String followUp;
  final String extraNotes;
  final DateTime? createdAt;

  SmartNoteModel({
    required this.symptom,
    required this.bodyPart,
    required this.severity,
    required this.action,
    required this.followUp,
    required this.extraNotes,
    this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'symptom': symptom,
      'bodyPart': bodyPart,
      'severity': severity,
      'action': action,
      'followUp': followUp,
      'extraNotes': extraNotes,
    };
  }

  factory SmartNoteModel.fromJson(Map<String, dynamic> json) {
    return SmartNoteModel(
      symptom: json['symptom'] ?? '',
      bodyPart: json['bodyPart'] ?? '',
      severity: json['severity'] ?? '',
      action: json['action'] ?? '',
      followUp: json['followUp'] ?? '',
      extraNotes: json['extraNotes'] ?? '',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
    );
  }
}
