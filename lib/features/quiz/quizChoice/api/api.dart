import 'package:logi_neko/core/common/apiService.dart';
import '../dto/quiz.dart';

class VideoApi {
  static Future<ApiResponse<List<VideoData>>> getVideosByLessonId(int lessonId) async {
    final response = await ApiService.get('/videos', queryParameters: {'lessonId': lessonId});
    return ApiService.parseListResponse(response, VideoData.fromJson, 'Failed to load videos');
  }

  static Future<ApiResponse<VideoData>> getVideoById(int id) async {
    final response = await ApiService.get('/videos/$id');
    return ApiService.parseObjectResponse(response, VideoData.fromJson, 'Failed to load video');
  }
}