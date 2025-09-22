// Updated quiz_repo.dart
import 'package:logi_neko/features/quiz/quizChoice/api/api.dart';
import 'package:logi_neko/features/quiz/quizChoice/dto/quiz.dart';
import 'package:logi_neko/features/quiz/result/dto/result.dart';
import '../api/api.dart';


abstract class VideoRepository {
  Future<List<VideoData>> getVideosByLessonId(int lessonId);
  Future<VideoData> getVideoById(int id);
  Future<bool> submitVideoAnswer(int videoId, String answer);
  Future<QuizResultData?> getQuizResults(int lessonId);
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

  @override
  Future<bool> submitVideoAnswer(int videoId, String answer) async {
    try {
      final response = await QuizResultApi.submitVideoAnswer(videoId, answer);
      return response.data;
    } catch (e) {
      throw RepositoryException('Failed to submit answer for video $videoId: $e');
    }
  }

  @override
  Future<QuizResultData?> getQuizResults(int lessonId) async {
    try {
      final response = await QuizResultApi.getQuizResults(lessonId);
      return response.data;
    } catch (e) {
      // This might be optional, so don't throw error
      print('Could not fetch quiz results: $e');
      return null;
    }
  }
}

class RepositoryException implements Exception {
  final String message;

  RepositoryException(this.message);

  @override
  String toString() => 'RepositoryException: $message';
}