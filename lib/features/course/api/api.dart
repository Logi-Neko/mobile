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

  static Future<ApiResponse<List<Course>>> getCoursesDebug() async {
    return await ApiService.getListDebug<Course>(
      '/courses',
      fromJson: (json) {
        print('    📍 Parsing course: ${json['name']}');
        final courseStart = Stopwatch()..start();

        final result = Course.fromJson(json);

        courseStart.stop();
        if (courseStart.elapsedMilliseconds > 50) {
          print('    ⚠️ SLOW: ${courseStart.elapsedMilliseconds}ms - ${json['name']}');
        }

        return result;
      },
    );
  }
}