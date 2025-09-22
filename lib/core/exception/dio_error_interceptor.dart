// lib/core/exception/dio_error_interceptor.dart

import 'package:dio/dio.dart';
import '../config/logger.dart';
import '../storage/token_storage.dart';
import '../interceptor/auth_interceptor.dart';
import 'exception_handler.dart';

class DioErrorInterceptor extends Interceptor {
  final Dio dio;
  final TokenStorage _tokenStorage = TokenStorage.instance;

  DioErrorInterceptor({required this.dio});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    logger.d('🚀 Request: ${options.method} ${options.path}');
    logger.d('🚀 Data: ${options.data}');
    logger.d('🚀 Headers: ${options.headers}');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    logger.d('✅ Response: ${response.statusCode} ${response.requestOptions.path}');
    logger.d('✅ Data: ${response.data}');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    logger.e('❌ Error: ${err.type} ${err.requestOptions.path}');
    logger.e('❌ Message: ${err.message}');
    logger.e('❌ Response: ${err.response?.data}');

    // Handle 401 - Try refresh token
    if (err.response?.statusCode == 401) {
      try {
        logger.d('🔄 Attempting to refresh token for 401 error...');

        // Attempt to refresh token
        final refreshed = await _refreshToken();

        if (refreshed) {
          // Update Authorization header for the retry request
          final accessToken = await _tokenStorage.getAccessToken();
          if (accessToken != null) {
            err.requestOptions.headers['Authorization'] = 'Bearer $accessToken';
          }

          // Retry the original request with new token
          final retryResponse = await dio.fetch(err.requestOptions);
          handler.resolve(retryResponse);
          return;
        } else {
          logger.w('❌ Refresh token failed, user needs to login again');
          // Clear all data and redirect to login
          await _tokenStorage.clearAll();
        }
      } catch (e) {
        logger.e('Failed to refresh token: $e');
        // Clear all data on refresh failure
        await _tokenStorage.clearAll();
      }
    }

    // Chuyển đổi DioException thành AppException
    final appException = ExceptionHandler.handleDioException(err);

    // Tạo DioException mới với message đã được xử lý
    final processedError = DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      type: err.type,
      error: appException,
      message: appException.message,
    );

    super.onError(processedError, handler);
  }

  Future<bool> _refreshToken() async {
    try {
      logger.d('🔄 Starting refresh token process...');

      // 1. Get refresh token from storage
      final refreshToken = await _tokenStorage.getRefreshToken();
      if (refreshToken == null) {
        logger.e('❌ No refresh token found');
        return false;
      }

      // 2. Call refresh token API (without auth interceptor to avoid infinite loop)
      final refreshDio = Dio(dio.options);
      final response = await refreshDio.post(
        '/refresh-token',
        queryParameters: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200 && response.data != null) {
        // 3. Parse new tokens
        final responseData = response.data;
        final newAccessToken = responseData['data']['accessToken'] as String?;
        final newRefreshToken = responseData['data']['refreshToken'] as String?;

        if (newAccessToken != null && newRefreshToken != null) {
          // 4. Save new tokens
          await _tokenStorage.updateTokensOnly(newAccessToken, newRefreshToken);

          logger.d('✅ Token refresh successful');
          return true;
        }
      }

      logger.e('❌ Invalid refresh token response');
      return false;
    } catch (e) {
      logger.e('❌ Refresh token failed: $e');
      return false;
    }
  }
}
