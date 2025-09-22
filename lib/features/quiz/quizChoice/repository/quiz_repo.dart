import '../api/api.dart';
import '../dto/quiz.dart';

abstract class VideoRepository {
  Future<List<VideoData>> getVideosByLessonId(int lessonId);
  Future<VideoData> getVideoById(int id);
}

class VideoRepositoryImpl implements VideoRepository {
  @override
  Future<List<VideoData>> getVideosByLessonId(int lessonId) async {
    try {
      final response = await VideoApi.getVideosByLessonId(lessonId);
      final sortedVideos = response.data..sort((a, b) => a.order.compareTo(b.order));
      return sortedVideos.where((video) => video.isActive).toList();
    } catch (e) {
      throw RepositoryException('Failed to fetch videos: $e');
    }
  }

  @override
  Future<VideoData> getVideoById(int id) async {
    try {
      final response = await VideoApi.getVideoById(id);
      return response.data;
    } catch (e) {
      throw RepositoryException('Failed to fetch video with id $id: $e');
    }
  }
}

class RepositoryException implements Exception {
  final String message;

  RepositoryException(this.message);

  @override
  String toString() => 'RepositoryException: $message';
}