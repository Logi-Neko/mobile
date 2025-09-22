// lib/core/interceptor/auth_interceptor.dart

import 'package:dio/dio.dart';
import '../config/logger.dart';
import '../storage/token_storage.dart';

class AuthInterceptor extends Interceptor {
  final TokenStorage _tokenStorage = TokenStorage.instance;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      // Lấy access token từ storage
      final accessToken = await _tokenStorage.getAccessToken();

      if (accessToken != null) {
        // Thêm Authorization header
        options.headers['Authorization'] = 'Bearer $accessToken';
        logger.d('🔑 Authorization header added: Bearer ${accessToken.substring(0, 10)}...');
      } else {
        logger.w('⚠️ No access token found for request: ${options.path}');
      }

      // Thêm Content-Type header nếu chưa có
      if (options.headers['Content-Type'] == null) {
        options.headers['Content-Type'] = 'application/json';
      }

      logger.d('🚀 Request headers: ${options.headers}');
    } catch (e) {
      logger.e('❌ Error adding auth header: $e');
    }

    super.onRequest(options, handler);
  }

  /// Cập nhật token trong header (dùng khi refresh token thành công)
  void updateToken(String newAccessToken) {
    logger.d('🔄 Token updated in auth interceptor');
  }

  /// Xóa token khỏi header (dùng khi logout)
  void clearToken() {
    logger.d('🗑️ Token cleared from auth interceptor');
  }
}
