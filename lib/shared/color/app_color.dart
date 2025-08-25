import 'package:flutter/material.dart';

class AppColors {
  // Màu gradient chính từ thiết kế
  static const Color primaryPurple = Color(0xFFC084FC);
  static const Color primaryBlue = Color(0xFF60A5FA);
  static const Color primaryPink = Color(0xFFEC4899);
  
  // Gradient colors từ Figma
  static const Color gradientStart =  Color(0xFFC084FC); // Tím nhạt
  static const Color gradientMiddle = Color(0xFFF472B6); // Tím đậm hơn
  static const Color gradientEnd = Color(0xFF60A5FA); // Xanh dương
  
  // Màu nền và text
  static const Color backgroundColor = Color(0xFFF8FAFC);
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textLight = Color(0xFF94A3B8);
  
  // Màu button
  static const Color buttonPrimary = Color(0xFF10B981);
  static const Color buttonHover = Color(0xFF059669);
  static const Color buttonDisabled = Color(0xFF9CA3AF);
  
  // Màu card và surface
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF1F5F9);
  
  // Màu accent
  static const Color accent = Color(0xFFFF6B6B);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  
  // Gradient definitions
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      gradientStart,
      gradientMiddle,
      gradientEnd,
    ],
    stops: [0.0, 0.5, 1.0],
  );
  
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFFFFFF),
      Color(0xFFF8FAFC),
    ],
  );
  
  // Box shadows
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 20,
      offset: Offset(0, 10),
    ),
  ];
  
  static const List<BoxShadow> buttonShadow = [
    BoxShadow(
      color: Color(0x3310B981),
      blurRadius: 15,
      offset: Offset(0, 5),
    ),
  ];
}