// Add this to your existing api.dart file

import 'package:logi_neko/core/common/apiService.dart';
import '../dto/result.dart';

class QuizResultApi {
  static Future<ApiResponse<bool>> submitVideoAnswer(int videoId, String answer) async {
    final requestBody = SubmitAnswerRequest(
      videoId: videoId,
      answer: answer,
    );

    final response = await ApiService.post(
      '/video/questions/$videoId',
      data: requestBody.toJson(),
    );

    return ApiService.parseObjectResponse(
        response,
            (json) => json['success'] ?? false,
        'Failed to submit answer'
    );
  }

  /// Get quiz completion results (if needed for future functionality)
  static Future<ApiResponse<QuizResultData>> getQuizResults(int lessonId) async {
    final response = await ApiService.get('/quiz/results/$lessonId');
    return ApiService.parseObjectResponse(
        response,
        QuizResultData.fromJson,
        'Failed to get quiz results'
    );
  }
}