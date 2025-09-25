// lib/core/network/api_service.dart

import 'package:dio/dio.dart';
import 'package:logi_neko/core/interceptor/auth_interceptor.dart';
import '../config/logger.dart';
import '../storage/token_storage.dart';
import '../exception/exceptions.dart';
import './ApiResponse.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8081';

  static late Dio _dio;
  static late TokenStorage _tokenStorage;
  static late AuthInterceptor _authInterceptor;

  static Future<void> initialize() async  {
    _tokenStorage = TokenStorage.instance;
    _authInterceptor = AuthInterceptor();

    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _setupInterceptors();
  }

  static void _setupInterceptors() {
    _dio.interceptors.add(_authInterceptor);

    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => logger.d(obj),
      ));
    }

    _dio.interceptors.add(DioErrorInterceptor(dio: _dio));
  }


  static Dio get dio {
    try {
      return _dio;
    } catch (e) {
      initialize();
      return _dio;
    }
  }

  // =================================================================
  // GENERIC API METHODS WITH EXCEPTION HANDLING
  // =================================================================

  /// Generic GET method với exception handling
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

  /// Generic POST method với exception handling
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

  /// Generic PUT method với exception handling
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

  /// Generic DELETE method với exception handling
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

  /// Generic PATCH method với exception handling
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

  // =================================================================
  // SPECIALIZED RESPONSE PARSERS
  // =================================================================

  /// Parse response cho object đơn lẻ
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

  /// Parse response cho list objects
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

  /// Post object và trả về object
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

  /// Put object và trả về object
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

  /// Delete và trả về response status
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
      fromJson: (data) => true, // Delete thành công
    );
  }

  // =================================================================
  // RESPONSE PARSING HELPERS
  // =================================================================

  /// Parse response thành ApiResponse
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

      // Nếu response data là null
      if (responseData == null) {
        return ApiResponse<T>(
          status: response.statusCode!,
          message: 'Success',
          data: null,
        );
      }

      // Nếu response data không phải Map (response trực tiếp)
      if (responseData is! Map<String, dynamic>) {
        final parsedData = fromJson != null ? fromJson(responseData) : null;
        return ApiResponse<T>(
          status: response.statusCode!,
          message: 'Success',
          data: parsedData,
        );
      }

      // Parse theo cấu trúc ApiResponse chuẩn
      final json = responseData as Map<String, dynamic>;

      return ApiResponse.fromJson(
        json,
        fromJson,
      );
    } catch (e) {
      logger.e('Error parsing response: $e');
      throw ServerException(
        message: 'Không thể xử lý phản hồi từ server',
        details: e.toString(),
      );
    }
  }

  // =================================================================
  // UTILITY METHODS
  // =================================================================

  /// Set authorization token
  static Future<void> setAuthToken(String token) async {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// Clear authorization token
  static Future<void> clearAuthToken() async {
    _dio.options.headers.remove('Authorization');
  }

  /// Update base URL
  static void updateBaseUrl(String newBaseUrl) {
    _dio.options.baseUrl = newBaseUrl;
  }

  /// Add custom header
  static void addHeader(String key, String value) {
    _dio.options.headers[key] = value;
  }

  /// Remove header
  static void removeHeader(String key) {
    _dio.options.headers.remove(key);
  }

  /// Get current headers
  static Map<String, dynamic> get headers => _dio.options.headers;

  /// Check if has auth token
  static bool get hasAuthToken =>
      _dio.options.headers.containsKey('Authorization');

  /// Get current base URL
  static String get currentBaseUrl => _dio.options.baseUrl;

  // =================================================================
  // FILE UPLOAD/DOWNLOAD METHODS
  // =================================================================

  /// Upload file
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
          await MultipartFile.fromFile(
            filePath,
            filename: fileName,
          ),
        ),
      );

      // Add other data
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

  /// Download file
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

  /// Execute multiple requests concurrently
  static Future<List<Response>> batch(List<RequestOptions> requests) async {
    return await ExceptionHelper.handleApiCall<List<Response>>(() async {
      final futures = requests.map((request) => _dio.fetch(request)).toList();
      return await Future.wait(futures);
    });
  }

  /// Cancel all pending requests
  static void cancelAllRequests([String? reason]) {
    // Implementation would depend on how you track active requests
    // This is a placeholder for the concept
  }
}
// extension ApiServiceExtension on ApiService {
//   /// Quick method để call API và chỉ lấy data
//   static Future<T?> fetchData<T>(
//       String path, {
//         Map<String, dynamic>? queryParameters,
//         T Function(dynamic)? fromJson,
//       }) async {
//     try {
//       final response = await get<T>(
//         path,
//         queryParameters: queryParameters,
//         fromJson: fromJson,
//       );
//       return response.data;
//     } catch (e) {
//       logger.e('Failed to fetch data from $path: $e');
//       return null;
//     }
//   }
// }