// lib/data/repositories/auth_repository.dart

import '../../../core/common/ApiResponse.dart';
import '../../../core/exception/exception_helper.dart';
import '../api/auth_api.dart';
import '../dto/signup_request.dart';
import '../dto/signup_response.dart';
import '../dto/login_response.dart';

class AuthRepository {
  final AuthApiService _apiService;

  AuthRepository({AuthApiService? apiService})
      : _apiService = apiService ?? AuthApiService();

  /// Đăng ký tài khoản mới
  Future<ApiResponse<SignupResponse>> register({required SignUpRequest request}) async {
    return ExceptionHelper.handleApiCall(() async {
      return await _apiService.register(request: request);
    });
  }

  /// Đăng nhập
  Future<ApiResponse<TokenResponse>> login(Map<String, dynamic> loginData) async {
    return ExceptionHelper.handleApiCall(() async {
      return await _apiService.login(loginData);
    });
  }

  /// Quên mật khẩu
  Future<ApiResponse<String>> forgotPassword(String username) async {
    return ExceptionHelper.handleApiCall(() async {
      return await _apiService.forgotPassword(username);
    });
  }

  /// Refresh token
  Future<ApiResponse<TokenResponse>> refreshToken(String refreshToken) async {
    return ExceptionHelper.handleApiCall(() async {
      return await _apiService.refreshToken(refreshToken);
    });
  }

  /// Đăng xuất
  Future<ApiResponse<String>> logout(String refreshToken) async {
    return ExceptionHelper.handleApiCall(() async {
      return await _apiService.logout(refreshToken);
    });
  }

  /// Đổi mật khẩu
  Future<ApiResponse<String>> resetPassword(String oldPassword, String newPassword) async {
    return ExceptionHelper.handleApiCall(() async {
      return await _apiService.resetPassword(oldPassword, newPassword);
    });
  }
}