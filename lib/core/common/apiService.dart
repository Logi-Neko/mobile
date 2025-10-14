import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logi_neko/core/interceptor/auth_interceptor.dart';
import 'package:logi_neko/features/auth/dto/login_response.dart';
import '../config/logger.dart';
import '../storage/token_storage.dart';
import '../exception/exceptions.dart';
import './ApiResponse.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  static String baseUrl = dotenv.env['BASE_URL'] ?? "";

  static late Dio _dio;
  static late TokenStorage _tokenStorage;
  static late AuthInterceptor _authInterceptor;

  static Future<void> initialize() async {
    _tokenStorage = TokenStorage.instance;

    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
      sendTimeout: const Duration(seconds: 60),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _authInterceptor = AuthInterceptor(_dio);
    _setupInterceptors();
    await _syncTokenOnStartup();
  }

  static Future<void> _syncTokenOnStartup() async {
    try {
      await _authInterceptor.syncTokenFromStorage();
      logger.i('Token synced successfully on app startup');
    } catch (e) {
      logger.e('Failed to sync token on startup: $e');
    }
  }

  static void _setupInterceptors() {
    _dio.interceptors.add(_authInterceptor);

    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: true,
        error: true,
        logPrint: (obj) {
          final logMessage = obj.toString();
          if (logMessage.contains('Authorization')) {
            logger.d(logMessage.replaceAll(RegExp(r'Bearer [^\s,}]+'), 'Bearer [HIDDEN]'));
          } else {
            logger.d(obj);
          }
        },
      ));
    }
  }

  static Future<void> setAuthTokenFromLogin(TokenResponse tokenResponse) async {
    try {
      await _tokenStorage.saveTokenResponse(tokenResponse);
      _dio.options.headers['Authorization'] = 'Bearer ${tokenResponse.accessToken}';
      _authInterceptor.updateToken(tokenResponse.accessToken);
      logger.i('Auth token set successfully from login');
    } catch (e) {
      logger.e('Failed to set auth token from login: $e');
      throw Exception('Failed to set authentication token');
    }
  }

  static Future<void> logout() async {
    try {
      await _tokenStorage.clearAll();
      _dio.options.headers.remove('Authorization');
      _authInterceptor.clearToken();
      logger.i('Logout completed - all tokens cleared');
    } catch (e) {
      logger.e('Error during logout: $e');
      throw Exception('Failed to logout properly');
    }
  }
  static Dio get dio => _dio;

  // Generic API methods
  static Future<ApiResponse<T>> get<T>(
      String path, {
        Map<String, dynamic>? queryParameters,
        Options? options,
        CancelToken? cancelToken,
        T Function(dynamic)? fromJson,
      }) async {
    return await ExceptionHelper.handleApiCall<ApiResponse<T>>(() async {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return _parseResponse<T>(response, fromJson);
    });
  }

  static Future<ApiResponse<T>> post<T>(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
        CancelToken? cancelToken,
        T Function(dynamic)? fromJson,
      }) async {
    return await ExceptionHelper.handleApiCall<ApiResponse<T>>(() async {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return _parseResponse<T>(response, fromJson);
    });
  }

  static Future<ApiResponse<T>> put<T>(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
        CancelToken? cancelToken,
        T Function(dynamic)? fromJson,
      }) async {
    return await ExceptionHelper.handleApiCall<ApiResponse<T>>(() async {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return _parseResponse<T>(response, fromJson);
    });
  }

  static Future<ApiResponse<T>> delete<T>(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
        CancelToken? cancelToken,
        T Function(dynamic)? fromJson,
      }) async {
    return await ExceptionHelper.handleApiCall<ApiResponse<T>>(() async {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return _parseResponse<T>(response, fromJson);
    });
  }

  static Future<ApiResponse<T>> patch<T>(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
        CancelToken? cancelToken,
        T Function(dynamic)? fromJson,
      }) async {
    return await ExceptionHelper.handleApiCall<ApiResponse<T>>(() async {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return _parseResponse<T>(response, fromJson);
    });
  }

  // Specialized methods
  static Future<ApiResponse<T>> getObject<T>(
      String path, {
        Map<String, dynamic>? queryParameters,
        required T Function(Map<String, dynamic>) fromJson,
        Options? options,
        CancelToken? cancelToken,
      }) async {
    return await get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      fromJson: (data) => fromJson(data as Map<String, dynamic>),
    );
  }

  static Future<ApiResponse<List<T>>> getList<T>(
      String path, {
        Map<String, dynamic>? queryParameters,
        required T Function(Map<String, dynamic>) fromJson,
        Options? options,
        CancelToken? cancelToken,
      }) async {
    return await get<List<T>>(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      fromJson: (data) => (data as List)
          .map((item) => fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  static Future<ApiResponse<T>> postObject<T>(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        required T Function(Map<String, dynamic>) fromJson,
        Options? options,
        CancelToken? cancelToken,
      }) async {
    return await post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      fromJson: (responseData) => fromJson(responseData as Map<String, dynamic>),
    );
  }

  static Future<ApiResponse<T>> putObject<T>(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        required T Function(Map<String, dynamic>) fromJson,
        Options? options,
        CancelToken? cancelToken,
      }) async {
    return await put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      fromJson: (responseData) => fromJson(responseData as Map<String, dynamic>),
    );
  }

  static Future<ApiResponse<bool>> deleteResource(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
        CancelToken? cancelToken,
      }) async {
    return await delete<bool>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      fromJson: (data) => true,
    );
  }

  static ApiResponse<T> _parseResponse<T>(
      Response response,
      T Function(dynamic)? fromJson,
      ) {
    if (response.statusCode == null || response.statusCode! < 200 || response.statusCode! >= 300) {
      throw ClientException(
        message: 'Invalid response status: ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }

    try {
      final responseData = response.data;

      if (responseData == null) {
        return ApiResponse<T>(
          status: response.statusCode!,
          message: 'Success',
          data: null,
        );
      }

      if (responseData is! Map<String, dynamic>) {
        final parsedData = fromJson != null ? fromJson(responseData) : null;
        return ApiResponse<T>(
          status: response.statusCode!,
          message: 'Success',
          data: parsedData,
        );
      }

      final json = responseData as Map<String, dynamic>;
      return ApiResponse.fromJson(json, fromJson);
    } catch (e) {
      logger.e('Error parsing response: $e');
      throw ServerException(
        message: 'Cannot process server response',
        details: e.toString(),
      );
    }
  }

  // Utility methods
  static Future<void> setAuthToken(String token) async {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  static Future<void> clearAuthToken() async {
    _dio.options.headers.remove('Authorization');
  }

  static void updateBaseUrl(String newBaseUrl) {
    _dio.options.baseUrl = newBaseUrl;
  }

  static void addHeader(String key, String value) {
    _dio.options.headers[key] = value;
  }

  static void removeHeader(String key) {
    _dio.options.headers.remove(key);
  }

  static Map<String, dynamic> get headers => _dio.options.headers;

  static bool get hasAuthToken => _dio.options.headers.containsKey('Authorization');

  static String get currentBaseUrl => _dio.options.baseUrl;

  // File upload/download methods
  static Future<ApiResponse<T>> uploadFile<T>(
      String path,
      String filePath, {
        String? fileName,
        Map<String, dynamic>? data,
        Map<String, dynamic>? queryParameters,
        T Function(dynamic)? fromJson,
        ProgressCallback? onSendProgress,
        CancelToken? cancelToken,
      }) async {
    return await ExceptionHelper.handleApiCall<ApiResponse<T>>(() async {
      final formData = FormData();

      formData.files.add(
        MapEntry(
          'file',
          await MultipartFile.fromFile(filePath, filename: fileName),
        ),
      );

      if (data != null) {
        data.forEach((key, value) {
          formData.fields.add(MapEntry(key, value.toString()));
        });
      }

      final response = await _dio.post(
        path,
        data: formData,
        queryParameters: queryParameters,
        onSendProgress: onSendProgress,
        cancelToken: cancelToken,
      );

      return _parseResponse<T>(response, fromJson);
    });
  }

  static Future<void> downloadFile(
      String url,
      String savePath, {
        Map<String, dynamic>? queryParameters,
        ProgressCallback? onReceiveProgress,
        CancelToken? cancelToken,
      }) async {
    return await ExceptionHelper.handleApiCall<void>(() async {
      await _dio.download(
        url,
        savePath,
        queryParameters: queryParameters,
        onReceiveProgress: onReceiveProgress,
        cancelToken: cancelToken,
      );
    });
  }
}