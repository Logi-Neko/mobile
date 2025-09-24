import 'package:logi_neko/core/exception/exceptions.dart';
import 'package:logi_neko/features/video/result/api/api.dart';
import 'package:logi_neko/features/video/result/dto/result.dart';
import '../api/api.dart';
import '../dto/video.dart';

abstract class VideoRepository {
  Future<List<VideoData>> getVideosByLessonId(int lessonId);
  Future<VideoData> getVideoById(int id);
  Future<bool> submitVideoAnswer(int videoId, String answer);
  Future<QuizResultData?> getQuizResults(int lessonId);
}

class VideoRepositoryImpl implements VideoRepository {
  @override
  Future<List<VideoData>> getVideosByLessonId(int lessonId) async {
    final response = await VideoApi.getVideosByLessonId(lessonId);

    if (response.isSuccess && response.hasData) {
      final sortedVideos = response.data!..sort((a, b) => a.order.compareTo(b.order));
      return sortedVideos.where((video) => video.isActive).toList();
    }

    throw BackendException(
      message: response.message ?? 'Failed to fetch videos',
      statusCode: response.status,
      errorCode: response.code ?? 'FETCH_VIDEOS_ERROR',
      details: 'Lesson ID: $lessonId',
    );
  }

  @override
  Future<VideoData> getVideoById(int id) async {
    final response = await VideoApi.getVideoById(id);

    if (response.isSuccess && response.hasData) {
      return response.data!;
    }

    throw BackendException(
      message: response.message ?? 'Failed to fetch video',
      statusCode: response.status,
      errorCode: response.code ?? 'FETCH_VIDEO_ERROR',
      details: 'Video ID: $id',
    );
  }

  @override
  Future<bool> submitVideoAnswer(int videoId, String answer) async {
    final response = await QuizResultApi.submitVideoAnswer(videoId, answer);

    if (response.isSuccess && response.hasData) {
      return response.data!;
    }

    throw BackendException(
      message: response.message ?? 'Failed to submit answer',
      statusCode: response.status,
      errorCode: response.code ?? 'SUBMIT_ANSWER_ERROR',
      details: 'Video ID: $videoId, Answer: $answer',
    );
  }

  @override
  Future<QuizResultData?> getQuizResults(int lessonId) async {
    try {
      final response = await QuizResultApi.getQuizResults(lessonId);

      if (response.isSuccess && response.hasData) {
        return response.data;
      }
      return null;
    } on NotFoundException {
      return null;
    } catch (e) {
      print('Could not fetch video results: $e');
      return null;
    }
  }
}
