import 'dart:convert';
import 'package:dio/dio.dart';

class ApiResponse<T> {
  final int status;
  final String code;
  final String message;
  final T data;

  ApiResponse({
    required this.status,
    required this.code,
    required this.message,
    required this.data,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(dynamic) fromJsonT) {
    return ApiResponse<T>(
      status: json['status'] ?? 0,
      code: json['code'] ?? '',
      message: json['message'] ?? '',
      data: fromJsonT(json['data']),
    );
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;
  final dynamic data;

  ApiException(this.message, this.statusCode, {this.data});

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

abstract class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8081';

  static late Dio _dio;

  static void initialize() {
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
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          handler.next(error);
        },
      ),
    );
  }

  static Dio get dio {
    try {
      return _dio;
    } catch (e) {
      initialize();
      return _dio;
    }
  }

  static Future<Response> get(
      String path, {
        Map<String, dynamic>? queryParameters,
        Options? options,
        CancelToken? cancelToken,
      }) async {
    try {
      final response = await dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ApiException('Unexpected error: $e', 0);
    }
  }

  static Future<Response> post(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
        CancelToken? cancelToken,
      }) async {
    try {
      final response = await dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ApiException('Unexpected error: $e', 0);
    }
  }

  static Future<Response> put(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
        CancelToken? cancelToken,
      }) async {
    try {
      final response = await dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ApiException('Unexpected error: $e', 0);
    }
  }

  static Future<Response> delete(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
        CancelToken? cancelToken,
      }) async {
    try {
      final response = await dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ApiException('Unexpected error: $e', 0);
    }
  }

  static Future<Response> patch(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
        CancelToken? cancelToken,
      }) async {
    try {
      final response = await dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ApiException('Unexpected error: $e', 0);
    }
  }


  static ApiResponse<List<T>> parseListResponse<T>(
      Response response,
      T Function(Map<String, dynamic>) fromJson,
      String errorMessage,
      ) {
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = response.data;

      return ApiResponse.fromJson(
        jsonResponse,
            (data) => (data as List)
            .map((item) => fromJson(item as Map<String, dynamic>))
            .toList(),
      );
    } else {
      throw ApiException('$errorMessage: ${response.statusCode}', response.statusCode ?? 0);
    }
  }

  static ApiResponse<T> parseObjectResponse<T>(
      Response response,
      T Function(Map<String, dynamic>) fromJson,
      String errorMessage,
      ) {
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = response.data;

      return ApiResponse.fromJson(
        jsonResponse,
            (data) => fromJson(data as Map<String, dynamic>),
      );
    } else {
      throw ApiException('$errorMessage: ${response.statusCode}', response.statusCode ?? 0);
    }
  }

  static T parseSimpleResponse<T>(
      Response response,
      T Function(Map<String, dynamic>) fromJson,
      String errorMessage,
      ) {
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = response.data;
      return fromJson(jsonData);
    } else {
      throw ApiException('$errorMessage: ${response.statusCode}', response.statusCode ?? 0);
    }
  }

  static ApiException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return ApiException('Connection timeout', 0);
      case DioExceptionType.sendTimeout:
        return ApiException('Send timeout', 0);
      case DioExceptionType.receiveTimeout:
        return ApiException('Receive timeout', 0);
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode ?? 0;
        final message = error.response?.data?['message'] ?? 'Server error';
        return ApiException(message, statusCode, data: error.response?.data);
      case DioExceptionType.cancel:
        return ApiException('Request cancelled', 0);
      case DioExceptionType.connectionError:
        return ApiException('Connection error', 0);
      case DioExceptionType.badCertificate:
        return ApiException('Bad certificate', 0);
      case DioExceptionType.unknown:
      default:
        return ApiException('Unknown error: ${error.message}', 0);
    }
  }

  static void setAuthToken(String token) {
    dio.options.headers['Authorization'] = 'Bearer $token';
  }

  static void clearAuthToken() {
    dio.options.headers.remove('Authorization');
  }

  static void updateBaseUrl(String newBaseUrl) {
    dio.options.baseUrl = newBaseUrl;
  }

  static void addHeader(String key, String value) {
    dio.options.headers[key] = value;
  }

  static void removeHeader(String key) {
    dio.options.headers.remove(key);
  }
}

