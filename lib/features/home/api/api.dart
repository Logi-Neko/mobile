import 'package:logi_neko/core/common/ApiResponse.dart';
import 'package:logi_neko/core/common/apiService.dart';
import 'package:logi_neko/features/home/dto/user.dart';
import 'package:logi_neko/features/home/dto/show_user.dart';

class HomeApi {
  static const String _userInfoEndpoint = '/api/userinfo';
  static const String _userDashBoard = '/api/users/board';

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

  static Future<ApiResponse<List<AccountShowResponse>>> getUserDashboard() async {
    try {
      return await ApiService.getList<AccountShowResponse>(
        _userDashBoard,
        fromJson: (json) => AccountShowResponse.fromJson(json),
      );
    } catch (e) {
      rethrow;
    }
  }
}