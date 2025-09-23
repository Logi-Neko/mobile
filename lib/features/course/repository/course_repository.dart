import 'package:logi_neko/core/exception/exceptions.dart';
import '../api/api.dart';
import '../dto/course.dart';

abstract class CourseRepository {
  Future<List<Course>> getCourses();
  Future<Course> getCourseById(int id);
}

class CourseRepositoryImpl implements CourseRepository {
  @override
  Future<List<Course>> getCourses() async {
    final response = await CourseApi.getCourses();

    if (response.isSuccess && response.hasData) {
      return response.data!;
    }

    throw BackendException(
      message: response.message ?? 'Failed to fetch courses',
      statusCode: response.status,
      errorCode: response.code ?? 'FETCH_COURSES_ERROR',
    );
  }

  @override
  Future<Course> getCourseById(int id) async {
    final response = await CourseApi.getCourseById(id);

    if (response.isSuccess && response.hasData) {
      return response.data!;
    }

    throw BackendException(
      message: response.message ?? 'Failed to fetch course',
      statusCode: response.status,
      errorCode: response.code ?? 'FETCH_COURSE_ERROR',
      details: 'Course ID: $id',
    );
  }
}