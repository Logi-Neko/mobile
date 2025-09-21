import 'dart:convert';
import 'package:http/http.dart' as http;
import '../bloc/quiz.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8081';

  static Future<QuizResponse> getVideosByLessonId(int lessonId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/videos?lessonId=$lessonId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return QuizResponse.fromJson(jsonData);
      } else {
        throw Exception('Failed to load videos for lesson $lessonId: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching videos for lesson $lessonId: $e');
    }
  }
}