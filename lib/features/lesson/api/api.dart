import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logi_neko/features/lesson/bloc/lesson.dart';

class ApiResponse<T> {
  final int status;
  final String code;
  final String message;
  final T data;

  ApiResponse({
    required this.status,
    required this.code,
    required this.message,
    required this.data,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(dynamic) fromJsonT) {
    return ApiResponse<T>(
      status: json['status'] ?? 0,
      code: json['code'] ?? '',
      message: json['message'] ?? '',
      data: fromJsonT(json['data']),
    );
  }
}

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8081';

  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Future<ApiResponse<List<Lesson>>> getLessonsByCourseId(int courseId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/lessons/course/$courseId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        return ApiResponse.fromJson(
          jsonResponse,
              (data) => (data as List)
              .map((lessonJson) => Lesson.fromJson(lessonJson))
              .toList(),
        );
      } else {
        throw ApiException(
          'Failed to load courses: ${response.statusCode}',
          response.statusCode,
        );
      }
    } catch (e) {
      throw ApiException('Network error: $e', 0);
    }
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException(this.message, this.statusCode);

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}