// lib/core/interceptor/auth_interceptor.dart

import 'package:dio/dio.dart';
import '../config/logger.dart';
import '../storage/token_storage.dart';
import '../common/ApiResponse.dart';
import '../navigation/navigation_service.dart';
import '../../features/auth/dto/login_response.dart';

class AuthInterceptor extends Interceptor {
  final TokenStorage _tokenStorage = TokenStorage.instance;

  // Để tránh infinite loop khi refresh token
  bool _isRefreshing = false;
  final List<RequestOptions> _failedRequests = [];

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      // Skip thêm token cho các endpoint auth (login, register, refresh)
      final isAuthEndpoint = _isAuthEndpoint(options.path);

      if (!isAuthEndpoint) {
        // Lấy access token từ storage
        final accessToken = await _tokenStorage.getAccessToken();

        if (accessToken != null) {
          // Thêm Authorization header
          options.headers['Authorization'] = 'Bearer $accessToken';
          logger.d('🔑 Authorization header added: Bearer ${accessToken.substring(0, 10)}...');
        } else {
          logger.w('⚠️ No access token found for request: ${options.path}');
        }
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

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Kiểm tra nếu lỗi 401 và không phải endpoint auth
    if (err.response?.statusCode == 401 && !_isAuthEndpoint(err.requestOptions.path)) {
      logger.w('🔄 401 Unauthorized - Attempting token refresh...');

      // Nếu đang refresh thì add request vào queue
      if (_isRefreshing) {
        _failedRequests.add(err.requestOptions);
        return;
      }

      _isRefreshing = true;

      try {
        // Lấy refresh token
        final refreshToken = await _tokenStorage.getRefreshToken();

        if (refreshToken == null) {
          logger.e('❌ No refresh token available');
          await _clearTokensAndRedirectToLogin();
          return super.onError(err, handler);
        }

        // Gọi API refresh token
        logger.i('🔄 Refreshing token...');
        final newTokenResponse = await _refreshToken(refreshToken);

        if (newTokenResponse != null && newTokenResponse.data != null) {
          // Lưu tokens mới
          await _tokenStorage.saveTokenResponse(newTokenResponse.data!);
          logger.i('✅ Token refreshed successfully');

          // Retry request ban đầu với token mới
          final newAccessToken = newTokenResponse.data!.accessToken;
          err.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';

          // Tạo Dio mới để retry request
          final dio = Dio();
          dio.options = err.requestOptions as BaseOptions;
          final retryResponse = await dio.fetch(err.requestOptions);

          // Retry tất cả các requests đang chờ
          await _retryFailedRequests(newAccessToken);

          return handler.resolve(retryResponse);

        } else {
          logger.e('❌ Refresh token response is null');
          await _clearTokensAndRedirectToLogin();
          return super.onError(err, handler);
        }

      } catch (refreshError) {
        logger.e('❌ Refresh token failed: $refreshError');
        await _clearTokensAndRedirectToLogin();
        return super.onError(err, handler);

      } finally {
        _isRefreshing = false;
        _failedRequests.clear();
      }
    }

    super.onError(err, handler);
  }

  /// Kiểm tra xem có phải endpoint auth không
  bool _isAuthEndpoint(String path) {
    final authPaths = [
      '/login',
      '/register',
      '/refresh',
      '/forgot-password',
      '/reset-password'
    ];

    return authPaths.any((authPath) => path.contains(authPath));
  }

  /// Gọi API refresh token
  Future<ApiResponse<TokenResponse>?> _refreshToken(String refreshToken) async {
    try {
      final dio = Dio();
      dio.options.baseUrl = 'http://10.0.2.2:8081/api';

      final response = await dio.post(
        '/refresh',
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        return ApiResponse.fromJson(
          response.data,
          (json) => TokenResponse.fromJson(json as Map<String, dynamic>),
        );
      }

      return null;
    } catch (e) {
      logger.e('❌ Error calling refresh token API: $e');
      return null;
    }
  }

  /// Retry tất cả các requests đã fail với token mới
  Future<void> _retryFailedRequests(String newAccessToken) async {
    final dio = Dio();

    for (final request in _failedRequests) {
      try {
        request.headers['Authorization'] = 'Bearer $newAccessToken';
        await dio.fetch(request);
        logger.d('✅ Retried failed request: ${request.path}');
      } catch (e) {
        logger.e('❌ Failed to retry request ${request.path}: $e');
      }
    }
  }

  /// Xóa tokens và chuyển hướng về login
  Future<void> _clearTokensAndRedirectToLogin() async {
    try {
      // Xóa tất cả tokens trong storage
      await _tokenStorage.clearAll();
      logger.i('🗑️ All tokens cleared due to refresh failure');

      // Hiển thị dialog thông báo phiên hết hạn và chuyển về login
      await NavigationService.instance.showTokenExpiredDialog();

    } catch (e) {
      logger.e('❌ Error clearing tokens: $e');
      // Fallback: chuyển thẳng về login nếu có lỗi
      NavigationService.instance.navigateToLogin();
    }
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
