import 'package:logi_neko/core/exception/exceptions.dart';

import '../api/api.dart';
import '../dto/lesson.dart';

abstract class LessonRepository {
  Future<List<Lesson>> getLessonsByCourseId(int courseId);
  Future<Lesson> getLessonById(int id);
}

class LessonRepositoryImpl implements LessonRepository {
  @override
  Future<List<Lesson>> getLessonsByCourseId(int courseId) async {
    final response = await LessonApi.getLessonsByCourseId(courseId);

    if (response.isSuccess && response.hasData) {
      return response.data!;
    }

    throw BackendException(
      message: response.message ?? 'Failed to fetch lessons',
      statusCode: response.status,
      errorCode: response.code ?? 'FETCH_LESSONS_ERROR',
      details: 'Course ID: $courseId',
    );
  }

  @override
  Future<Lesson> getLessonById(int id) async {
    final response = await LessonApi.getLessonById(id);

    if (response.isSuccess && response.hasData) {
      return response.data!;
    }

    throw BackendException(
      message: response.message ?? 'Failed to fetch lesson',
      statusCode: response.status,
      errorCode: response.code ?? 'FETCH_LESSON_ERROR',
      details: 'Lesson ID: $id',
    );
  }
}
