import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../config/logger.dart';
import '../storage/token_storage.dart';
import '../common/ApiResponse.dart';
import '../navigation/navigation_service.dart';
import '../../features/auth/dto/login_response.dart';
import 'dart:async';

class AuthInterceptor extends Interceptor {
  final TokenStorage _tokenStorage = TokenStorage.instance;
  final Dio _dio;

  bool _isRefreshing = false;
  Completer<void>? _refreshCompleter;
  final List<_QueuedRequest> _requestQueue = [];

  // Cache the token in memory to avoid slow storage reads on every request
  String? _cachedAccessToken;
  bool _hasAttemptedStorageLoad = false;

  AuthInterceptor(this._dio);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      if (!_isAuthEndpoint(options.path)) {
        // Fast path: use cached token if available
        if (_cachedAccessToken != null) {
          options.headers['Authorization'] = 'Bearer $_cachedAccessToken';
        } else if (!_hasAttemptedStorageLoad) {
          // Fallback: if cache is empty and we haven't tried storage yet, load once
          _hasAttemptedStorageLoad = true;
          final accessToken = await _tokenStorage.getAccessToken();
          if (accessToken != null) {
            _cachedAccessToken = accessToken;
            options.headers['Authorization'] = 'Bearer $accessToken';
            _dio.options.headers['Authorization'] = 'Bearer $accessToken';
          }
        }
        // If cache is null and we already tried storage, just proceed without auth header
      }
      options.headers['Content-Type'] ??= 'application/json';
    } catch (e) {
      logger.e('Error adding auth header: $e');
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    if (response.statusCode == 200 &&
        response.data is Map<String, dynamic> &&
        !_isAuthEndpoint(response.requestOptions.path)) {

      final data = response.data as Map<String, dynamic>;
      final isUnauthorized = data['status'] == 401 ||
          data['code'] == 'ERR_UNAUTHORIZED' ||
          (data['message']?.toString().contains('xác thực') ?? false);

      if (isUnauthorized) {
        logger.w('401 detected in response body - attempting refresh');

        final success = await _handleTokenRefreshAndRetry(
            response.requestOptions,
            handler,
            isFromResponse: true,
            originalResponse: response
        );

        if (success) return;

        handler.reject(DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          message: data['message']?.toString() ?? 'Unauthorized',
        ));
        return;
      }
    }

    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 && !_isAuthEndpoint(err.requestOptions.path)) {
      logger.w('HTTP 401 detected - attempting refresh');

      final success = await _handleTokenRefreshAndRetry(
        err.requestOptions,
        handler,
        isFromResponse: false,
      );

      if (success) return;
    }

    super.onError(err, handler);
  }

  Future<bool> _handleTokenRefreshAndRetry(
      RequestOptions requestOptions,
      dynamic handler, {
        required bool isFromResponse,
        Response? originalResponse,
      }) async {
    try {
      _requestQueue.add(_QueuedRequest(requestOptions, handler, isFromResponse));

      if (_isRefreshing) {
        await _refreshCompleter?.future;
      } else {
        final refreshSuccess = await _performTokenRefresh();
        if (!refreshSuccess) {
          _clearQueueAndReject('Token refresh failed');
          await _clearTokensAndRedirectToLogin();
          return false;
        }
      }

      await _processQueue();
      return true;

    } catch (e) {
      logger.e('Error in token refresh process: $e');
      _clearQueueAndReject('Token refresh error: $e');
      return false;
    }
  }

  Future<bool> _performTokenRefresh() async {
    if (_isRefreshing) return false;

    _isRefreshing = true;
    _refreshCompleter = Completer<void>();

    try {
      final refreshToken = await _tokenStorage.getRefreshToken();
      if (refreshToken == null) {
        logger.e('No refresh token available');
        return false;
      }

      final refreshDio = Dio(BaseOptions(
        baseUrl: dotenv.env['AUTH_URL'] ?? 'https://api.logineko.edu.vn/api',
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
        sendTimeout: const Duration(seconds: 60),
      ));

      final response = await refreshDio.post(
        '/refresh-token',
        queryParameters: {'refresh_token': refreshToken},
        options: Options(headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        }),
      );

      if (response.statusCode == 200 && response.data != null) {
        final responseData = response.data as Map<String, dynamic>;
        final apiResponse = ApiResponse.fromJson(
          responseData,
              (json) => TokenResponse.fromJson(json as Map<String, dynamic>),
        );

        if (apiResponse.data != null) {
          await _tokenStorage.saveTokenResponse(apiResponse.data!);

          final newAccessToken = apiResponse.data!.accessToken;
          _cachedAccessToken = newAccessToken;
          _dio.options.headers['Authorization'] = 'Bearer $newAccessToken';

          logger.i('Token refreshed successfully');
          return true;
        }
      }

      logger.e('Invalid refresh response');
      return false;

    } catch (e) {
      logger.e('Refresh token API error: $e');
      return false;
    } finally {
      _isRefreshing = false;
      _refreshCompleter?.complete();
      _refreshCompleter = null;
    }
  }

  Future<void> _processQueue() async {
    if (_requestQueue.isEmpty) return;

    // Use cached token instead of reading from storage
    if (_cachedAccessToken == null) {
      _clearQueueAndReject('No access token after refresh');
      return;
    }

    final requests = List<_QueuedRequest>.from(_requestQueue);
    _requestQueue.clear();

    for (final queuedRequest in requests) {
      try {
        queuedRequest.requestOptions.headers['Authorization'] = 'Bearer $_cachedAccessToken';

        final retryResponse = await _dio.fetch(queuedRequest.requestOptions);

        if (queuedRequest.isFromResponse) {
          (queuedRequest.handler as ResponseInterceptorHandler).resolve(retryResponse);
        } else {
          (queuedRequest.handler as ErrorInterceptorHandler).resolve(retryResponse);
        }

      } catch (e) {
        final error = DioException(
          requestOptions: queuedRequest.requestOptions,
          error: e,
        );

        if (queuedRequest.isFromResponse) {
          (queuedRequest.handler as ResponseInterceptorHandler).reject(error);
        } else {
          (queuedRequest.handler as ErrorInterceptorHandler).reject(error);
        }
      }
    }
  }

  void _clearQueueAndReject(String reason) {
    final requests = List<_QueuedRequest>.from(_requestQueue);
    _requestQueue.clear();

    for (final queuedRequest in requests) {
      final error = DioException(
        requestOptions: queuedRequest.requestOptions,
        message: reason,
        type: DioExceptionType.cancel,
      );

      if (queuedRequest.isFromResponse) {
        (queuedRequest.handler as ResponseInterceptorHandler).reject(error);
      } else {
        (queuedRequest.handler as ErrorInterceptorHandler).reject(error);
      }
    }
  }

  bool _isAuthEndpoint(String path) {
    final authPaths = [
      '/auth/login', '/auth/register', '/api/refresh-token',
      '/auth/forgot-password', '/auth/reset-password',
      '/login', '/register', '/refresh', '/forgot-password', '/reset-password'
    ];
    return authPaths.any((authPath) => path.contains(authPath) || path.endsWith(authPath));
  }

  Future<void> _clearTokensAndRedirectToLogin() async {
    try {
      await _tokenStorage.clearAll();
      _cachedAccessToken = null;
      _dio.options.headers.remove('Authorization');
      _requestQueue.clear();
      logger.i('All tokens cleared due to authentication failure');
      await NavigationService.instance.showTokenExpiredDialog();
    } catch (e) {
      logger.e('Error clearing tokens: $e');
      NavigationService.instance.navigateToLogin();
    }
  }

  Future<void> syncTokenFromStorage() async {
    try {
      _hasAttemptedStorageLoad = true;
      final accessToken = await _tokenStorage.getAccessToken();
      if (accessToken != null) {
        _cachedAccessToken = accessToken;
        _dio.options.headers['Authorization'] = 'Bearer $accessToken';
        logger.d('Token synced from storage to memory cache and Dio headers');
      } else {
        _cachedAccessToken = null;
        _dio.options.headers.remove('Authorization');
      }
    } catch (e) {
      logger.e('Error syncing token from storage: $e');
    }
  }

  void updateToken(String newAccessToken) {
    _cachedAccessToken = newAccessToken;
    _dio.options.headers['Authorization'] = 'Bearer $newAccessToken';
  }

  void clearToken() {
    _cachedAccessToken = null;
    _dio.options.headers.remove('Authorization');
    _requestQueue.clear();
  }
}

class _QueuedRequest {
  final RequestOptions requestOptions;
  final dynamic handler;
  final bool isFromResponse;

  _QueuedRequest(this.requestOptions, this.handler, this.isFromResponse);
}