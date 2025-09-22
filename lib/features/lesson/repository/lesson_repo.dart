import '../api/api.dart';
import '../dto/lesson.dart';

abstract class LessonRepository {
  Future<List<Lesson>> getLessonsByCourseId(int courseId);
  Future<Lesson> getLessonById(int id);
}

class LessonRepositoryImpl implements LessonRepository {
  @override
  Future<List<Lesson>> getLessonsByCourseId(int courseId) async {
    try {
      final response = await LessonApi.getLessonsByCourseId(courseId);
      return response.data;
    } catch (e) {
      throw RepositoryException('Failed to fetch lessons: $e');
    }
  }

  @override
  Future<Lesson> getLessonById(int id) async {
    try {
      final response = await LessonApi.getLessonById(id);
      return response.data;
    } catch (e) {
      throw RepositoryException('Failed to fetch lesson with id $id: $e');
    }
  }
}

class RepositoryException implements Exception {
  final String message;

  RepositoryException(this.message);

  @override
  String toString() => 'RepositoryException: $message';
}