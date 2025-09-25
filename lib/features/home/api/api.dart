import 'package:logi_neko/core/common/ApiResponse.dart';
import 'package:logi_neko/core/common/apiService.dart';
import 'package:logi_neko/features/home/dto/user.dart';

class HomeApi {
  static const String _userInfoEndpoint = '/api/userinfo';

  static Future<ApiResponse<User>> getUserInfo() async {
    try {
      return await ApiService.getObject<User>(
        _userInfoEndpoint,
        fromJson: (json) => User.fromJson(json),
      );
    } catch (e) {
      rethrow;
    }
  }
}