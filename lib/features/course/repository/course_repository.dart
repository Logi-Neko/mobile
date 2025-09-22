import '../api/api.dart';
import '../dto/course.dart';

abstract class CourseRepository {
  Future<List<Course>> getCourses();
  Future<Course> getCourseById(int id);
}

class CourseRepositoryImpl implements CourseRepository {
  @override
  Future<List<Course>> getCourses() async {
    try {
      final response = await CourseApi.getCourses();
      return response.data;
    } catch (e) {
      throw RepositoryException('Failed to fetch courses: $e');
    }
  }

  @override
  Future<Course> getCourseById(int id) async {
    try {
      final response = await CourseApi.getCourseById(id);
      return response.data;
    } catch (e) {
      throw RepositoryException('Failed to fetch course with id $id: $e');
    }
  }
}

class RepositoryException implements Exception {
  final String message;

  RepositoryException(this.message);

  @override
  String toString() => 'RepositoryException: $message';
}