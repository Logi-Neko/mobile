import 'package:logi_neko/core/common/ApiResponse.dart';
import 'package:logi_neko/core/common/apiService.dart';
import '../dto/lesson.dart';

class LessonApi {
  static Future<ApiResponse<List<Lesson>>> getLessonsByCourseId(int courseId) async {
    return await ApiService.getList<Lesson>(
      '/lessons/course/$courseId',
      fromJson: Lesson.fromJson,
    );
  }

  static Future<ApiResponse<Lesson>> getLessonById(int id) async {
    return await ApiService.getObject<Lesson>(
      '/lessons/$id',
      fromJson: Lesson.fromJson,
    );
  }
}