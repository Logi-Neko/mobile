import 'package:logi_neko/core/common/ApiResponse.dart';
import 'package:logi_neko/core/common/apiService.dart';
import '../dto/result.dart';

class QuizResultApi {
  static Future<ApiResponse<bool>> submitVideoAnswer(int videoId, String answer) async {
    final requestBody = SubmitAnswerRequest(
      videoId: videoId,
      answer: answer,
    );

    return await ApiService.postObject<bool>(
      '/video/questions/$videoId',
      data: requestBody.toJson(),
      fromJson: (json) => json['success'] ?? false,
    );
  }

  static Future<ApiResponse<QuizResultData>> getQuizResults(int lessonId) async {
    return await ApiService.getObject<QuizResultData>(
      '/video/results/$lessonId',
      fromJson: QuizResultData.fromJson,
    );
  }
}