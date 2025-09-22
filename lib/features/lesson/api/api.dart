import 'package:logi_neko/core/common/apiService.dart';
import '../dto/lesson.dart';

class LessonApi {
  static Future<ApiResponse<List<Lesson>>> getLessonsByCourseId(int courseId) async {
    final response = await ApiService.get('/lessons/course/$courseId');
    return ApiService.parseListResponse(response, Lesson.fromJson, 'Failed to load lessons');
  }

  static Future<ApiResponse<Lesson>> getLessonById(int id) async {
    final response = await ApiService.get('/lessons/$id');
    return ApiService.parseObjectResponse(response, Lesson.fromJson, 'Failed to load lesson');
  }
}