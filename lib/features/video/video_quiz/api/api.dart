import 'package:logi_neko/core/common/ApiResponse.dart';
import 'package:logi_neko/core/common/apiService.dart';
import '../dto/video.dart';

class VideoApi {
  static Future<ApiResponse<List<VideoData>>> getVideosByLessonId(int lessonId) async {
    return await ApiService.getList<VideoData>(
      '/videos',
      queryParameters: {'lessonId': lessonId},
      fromJson: VideoData.fromJson,
    );
  }

  static Future<ApiResponse<VideoData>> getVideoById(int id) async {
    return await ApiService.getObject<VideoData>(
      '/videos/$id',
      fromJson: VideoData.fromJson,
    );
  }
}