import 'package:logi_neko/core/common/ApiResponse.dart';
import 'package:logi_neko/core/common/apiService.dart';
import '../dto/result.dart';

class QuizResultApi {
  static Future<ApiResponse<bool>> submitVideoAnswer(int id, String answer) async {
    return await ApiService.post<bool>(
      '/video/questions/$id',
      queryParameters: {
        'answer': answer,
      },
      fromJson: (json) => json['success'] ?? false,
    );
  }
}