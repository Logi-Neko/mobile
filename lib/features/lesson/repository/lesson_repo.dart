import '../api/api.dart';
import '../bloc/lesson.dart';

abstract class LessonRepository {
  Future<List<Lesson>> getLessonsByCourseId(int courseId);
}

class LessonRepositoryImpl implements LessonRepository {
  @override
  Future<List<Lesson>> getLessonsByCourseId(int courseId) async {
    try {
      final response = await ApiService.getLessonsByCourseId(courseId);
        return response.data;
    } catch (e) {
      throw RepositoryException('Failed to fetch lessons: $e');
    }
  }
}

class RepositoryException implements Exception {
  final String message;

  RepositoryException(this.message);

  @override
  String toString() => 'RepositoryException: $message';
}