import 'package:flutter/material.dart';

class AppColors {
  // Primary brand colors - Medical/Healthcare theme
  static const Color primary = Color(0xFF2563EB); // Professional blue
  static const Color primaryLight = Color(0xFF60A5FA);
  static const Color primaryDark = Color(0xFF1E40AF);

  // Secondary colors
  static const Color secondary = Color(0xFF10B981); // Medical green
  static const Color secondaryLight = Color(0xFF34D399);
  static const Color secondaryDark = Color(0xFF059669);

  // Accent colors for different user roles
  static const Color doctorAccent = Color(0xFF8B5CF6); // Purple
  static const Color patientAccent = Color(0xFF06B6D4); // Cyan
  static const Color adminAccent = Color(0xFFF59E0B); // Amber

  // Neutral colors
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F5F9);

  // Text colors
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);

  // Status colors
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Border and divider colors
  static const Color border = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFF1F5F9);

  // Card and container colors
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color containerLight = Color(0xFFF8FAFC);
  static const Color containerDark = Color(0xFFE2E8F0);

  // Special medical colors
  static const Color medicalRed = Color(0xFFDC2626);
  static const Color medicalBlue = Color(0xFF2563EB);
  static const Color medicalGreen = Color(0xFF059669);

  // Gradient colors
  static const List<Color> primaryGradient = [
    Color(0xFF2563EB),
    Color(0xFF3B82F6),
  ];

  static const List<Color> secondaryGradient = [
    Color(0xFF10B981),
    Color(0xFF059669),
  ];

  static const List<Color> doctorGradient = [
    Color(0xFF8B5CF6),
    Color(0xFFA855F7),
  ];

  static const List<Color> patientGradient = [
    Color(0xFF06B6D4),
    Color(0xFF0891B2),
  ];

  // Role-specific color schemes
  static const Map<String, Color> roleColors = {
    'doctor': doctorAccent,
    'patient': patientAccent,
    'admin': adminAccent,
  };

  static const Map<String, List<Color>> roleGradients = {
    'doctor': doctorGradient,
    'patient': patientGradient,
    'admin': [Color(0xFFF59E0B), Color(0xFFD97706)],
  };
}
