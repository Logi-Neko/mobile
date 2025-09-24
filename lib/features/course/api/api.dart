import 'package:logi_neko/core/common/ApiResponse.dart';
import 'package:logi_neko/core/common/apiService.dart';
import '../dto/course.dart';

class CourseApi {
  static Future<ApiResponse<List<Course>>> getCourses() async {
    return await ApiService.getList<Course>(
      '/courses',
      fromJson: Course.fromJson,
    );
  }

  static Future<ApiResponse<Course>> getCourseById(int id) async {
    return await ApiService.getObject<Course>(
      '/courses/$id',
      fromJson: Course.fromJson,
    );
  }
}