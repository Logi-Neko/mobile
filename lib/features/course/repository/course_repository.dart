import '../api/api.dart';
import '../bloc/course.dart';

abstract class CourseRepository {
  Future<List<Course>> getCourses();
  Future<Course> getCourseById(int id);
}

class CourseRepositoryImpl implements CourseRepository {
  final ApiService _apiService = ApiService();

  @override
  Future<List<Course>> getCourses() async {
    try {
      final response = await ApiService.getCourses();
      return response.data;
    } catch (e) {
      throw RepositoryException('Failed to fetch courses: $e');
    }
  }

  @override
  Future<Course> getCourseById(int id) async {
    try {
      final response = await ApiService.getCourseById(id);
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