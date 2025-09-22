import 'package:logi_neko/core/common/apiService.dart';
import '../dto/course.dart';

class CourseApi {
  static Future<ApiResponse<List<Course>>> getCourses() async {
    final response = await ApiService.get('/courses');
    return ApiService.parseListResponse(response, Course.fromJson, 'Failed to load courses');
  }

  static Future<ApiResponse<Course>> getCourseById(int id) async {
    final response = await ApiService.get('/courses/$id');
    return ApiService.parseObjectResponse(response, Course.fromJson, 'Failed to load course');
  }
}