import 'package:flutter/material.dart';
import 'package:logi_neko/features/course/dto/course.dart';
import 'package:logi_neko/features/lesson/dto/lesson.dart';


class ReportData {
  final List<Course> courses;
  final List<Lesson> lessons;
  final String from;
  final String to;

  const ReportData({
    required this.courses,
    required this.lessons,
    required this.from,
    required this.to,
  });

  factory ReportData.fromJson(Map<String, dynamic> json) {
    return ReportData(
      courses: (json['courses'] as List<dynamic>?)
          ?.map((item) => Course.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      lessons: (json['lessons'] as List<dynamic>?)
          ?.map((item) => Lesson.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      from: json['from'] as String? ?? '',
      to: json['to'] as String? ?? '',
    );
  }
}

// Extensions to add UI-specific properties to existing models
extension CourseReportExtension on Course {
  IconData get courseIcon {
    // Map course types to icons based on name
    final lowerName = name.toLowerCase();
    if (lowerName.contains('toán') || lowerName.contains('math')) {
      return Icons.calculate_outlined;
    } else if (lowerName.contains('tiếng việt') || lowerName.contains('vietnamese')) {
      return Icons.menu_book_outlined;
    } else if (lowerName.contains('tiếng anh') || lowerName.contains('english')) {
      return Icons.language_outlined;
    } else if (lowerName.contains('khoa học') || lowerName.contains('science')) {
      return Icons.science_outlined;
    } else {
      return Icons.school_outlined;
    }
  }

  Color get courseColor {
    // Map course types to colors
    final lowerName = name.toLowerCase();
    if (lowerName.contains('toán') || lowerName.contains('math')) {
      return const Color(0xFF6366F1);
    } else if (lowerName.contains('tiếng việt') || lowerName.contains('vietnamese')) {
      return const Color(0xFFEC4899);
    } else if (lowerName.contains('tiếng anh') || lowerName.contains('english')) {
      return const Color(0xFF10B981);
    } else if (lowerName.contains('khoa học') || lowerName.contains('science')) {
      return const Color(0xFF8B5CF6);
    } else {
      return const Color(0xFF06B6D4);
    }
  }
}

extension LessonReportExtension on Lesson {
  // Use existing properties from Lesson model:
  // - progressPercentage (already calculated from star)
  // - isCompleted (already implemented)
  // - progressText (already implemented)

  // Additional helper for completion based on progress percentage
  bool get isReportCompleted => progressPercentage >= 80.0;
}