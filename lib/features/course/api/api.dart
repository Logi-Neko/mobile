import 'dart:convert';
import 'package:http/http.dart' as http;
import '../bloc/course.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8081';

  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Future<ApiResponse<List<Course>>> getCourses() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/courses'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        return ApiResponse.fromJson(
          jsonResponse,
              (data) => (data as List)
              .map((courseJson) => Course.fromJson(courseJson))
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

  static Future<ApiResponse<Course>> getCourseById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/courses/$id'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        return ApiResponse.fromJson(
          jsonResponse,
              (data) => Course.fromJson(data),
        );
      } else {
        throw ApiException(
          'Failed to load course: ${response.statusCode}',
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