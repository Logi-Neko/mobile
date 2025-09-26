import 'package:logi_neko/core/common/ApiResponse.dart';
import 'package:logi_neko/core/common/apiService.dart';
import 'package:logi_neko/features/home/dto/user.dart';
import 'package:logi_neko/features/home/dto/update_age_request.dart';

class UserApi {
  static const String _updateAgeEndpoint = '/api/user/update-age';

  static Future<ApiResponse<User>> updateUserAge(UpdateAgeRequest request) async {
    try {
      return await ApiService.put<User>(
        _updateAgeEndpoint,
        data: request.toJson(),
        fromJson: (json) => User.fromJson(json),
      );
    } catch (e) {
      rethrow;
    }
  }
}