// lib/data/providers/auth_api_service.dart

import 'package:dio/dio.dart';
import 'package:logi_neko/features/auth/dto/signup_request.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../core/common/ApiResponse.dart';
import '../../../core/config/logger.dart';
import '../../../core/exception/dio_error_interceptor.dart';
import '../../../core/interceptor/auth_interceptor.dart';
import '../../../core/exception/exception_helper.dart';
import '../dto/login_response.dart';
import '../dto/signup_response.dart';

class AuthApiService {
  final Dio _dio;
  late final AuthInterceptor _authInterceptor;

  AuthApiService({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl:  "http://10.0.2.2:8081/api",
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 15),
            )) {
    // Khởi tạo interceptors
    _authInterceptor = AuthInterceptor();

    // Thêm interceptors theo thứ tự ưu tiên
    _dio.interceptors.add(_authInterceptor); // Auth trước
    _dio.interceptors.add(DioErrorInterceptor(dio: _dio)); // Error sau
  }

  Future<ApiResponse<SignupResponse>> register({
    required SignUpRequest request,
  }) async {
    return ExceptionHelper.handleApiCall(() async {
      logger.i("🌍 POST /register");
      final response = await _dio.post(
        '/register',
        data: request.toJson(),
      );
      logger.i('Status: ${response.statusCode}');
      logger.i('Response: ${response.data}');

      return ApiResponse.fromJson(
        response.data,
        (json) => SignupResponse.fromJson(json as Map<String, dynamic>)
      );
    });
  }

  Future<ApiResponse<SignupResponse>> getUserInfo() async {
    return ExceptionHelper.handleApiCall(() async {
      final response = await _dio.get(
        '/userinfo',
      );
      return ApiResponse.fromJson(
          response.data,
              (json) => SignupResponse.fromJson(json as Map<String, dynamic>)
      );
    });
  }

  Future<ApiResponse<TokenResponse>> login(Map<String, dynamic> body) async {
    return ExceptionHelper.handleApiCall(() async {
      final response = await _dio.post(
        '/login/exchange',
        data: body,
      );
      return ApiResponse.fromJson(
          response.data,
          (json) => TokenResponse.fromJson(json as Map<String, dynamic>)
      );
    });
  }

  /// Forgot password (gửi email reset)
  Future<ApiResponse<String>> forgotPassword(String username) async {
    return ExceptionHelper.handleApiCall(() async {
      final response = await _dio.post(
        '/forgot-password',
        data: {'username': username},
      );
      return ApiResponse.fromJson(response.data, (json) => json.toString());
    });
  }

  /// Refresh token để lấy access token mới
  Future<ApiResponse<TokenResponse>> refreshToken(String refreshToken) async {
    return ExceptionHelper.handleApiCall(() async {
      final response = await _dio.post(
        '/refresh-token',
        queryParameters: {'refresh_token': refreshToken},
      );
      return ApiResponse.fromJson(
        response.data,
        (json) => TokenResponse.fromJson(json as Map<String, dynamic>),
      );
    });
  }

  /// Login với Google ID token
  Future<ApiResponse<TokenResponse>> loginWithGoogle(String idToken) async {
    return ExceptionHelper.handleApiCall(() async {
      logger.i("🌍 POST /login/google");
      final response = await _dio.post(
        '/login/google',
        data: {
          'id_token': idToken,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        ),
      );
      logger.i('Status: ${response.statusCode}');
      logger.i('Response: ${response.data}');

      return ApiResponse.fromJson(
        response.data,
        (json) => TokenResponse.fromJson(json as Map<String, dynamic>),
      );
    });
  }

  /// Logout (thu hồi refresh token)
  Future<ApiResponse<String>> logout(String refreshToken) async {
    return ExceptionHelper.handleApiCall(() async {
      final response = await _dio.post(
        '/logout',
        queryParameters: {'refresh_token': refreshToken},
      );
      return ApiResponse.fromJson(response.data, (json) => json.toString());
    });
  }

  /// Reset password
  Future<ApiResponse<String>> resetPassword(
      String oldPassword, String newPassword) async {
    return ExceptionHelper.handleApiCall(() async {
      final response = await _dio.post(
        '/reset-password',
        queryParameters: {
          'old_password': oldPassword,
          'new_password': newPassword,
        },
      );
      return ApiResponse.fromJson(response.data, (json) => json.toString());
    });
  }
}