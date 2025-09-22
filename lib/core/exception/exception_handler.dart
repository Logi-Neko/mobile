// lib/core/exception/exception_handler.dart

import 'package:dio/dio.dart';
import '../config/logger.dart';
import 'app_exception.dart';

class ExceptionHandler {
  /// Xử lý DioException và chuyển đổi thành AppException tùy chỉnh
  static AppException handleDioException(DioException dioException) {
    logger.e('DioException occurred: ${dioException.type}');
    logger.e('Error message: ${dioException.message}');
    logger.e('Response data: ${dioException.response?.data}');

    switch (dioException.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutException();

      case DioExceptionType.connectionError:
        return const NetworkException();

      case DioExceptionType.badResponse:
        return _handleResponseError(dioException.response!);

      case DioExceptionType.cancel:
        return const UnknownException(
          message: 'Yêu cầu đã bị hủy',
          errorCode: 'REQUEST_CANCELLED',
        );

      case DioExceptionType.unknown:
      default:
        return UnknownException(
          details: dioException.message,
        );
    }
  }

  /// Xử lý lỗi response dựa trên status code
  static AppException _handleResponseError(Response response) {
    final statusCode = response.statusCode ?? 0;
    String? message;
    String? errorCode;

    // Parse backend response format {status, code, message}
    try {
      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        message = data['message'] as String?;
        errorCode = data['code'] as String?;
      }
    } catch (e) {
      logger.w('Failed to parse error response: $e');
    }

    // Use backend message or fallback to default
    message ??= _getDefaultErrorMessage(statusCode);

    // Map to appropriate exception based on status code
    switch (statusCode) {
      case 401:
        return UnauthorizedException(
          message: message,
          errorCode: errorCode ?? 'UNAUTHORIZED',
        );
      case 403:
        return ForbiddenException(
          message: message,
          errorCode: errorCode ?? 'FORBIDDEN',
        );
      case 404:
        return NotFoundException(
          message: message,
          errorCode: errorCode ?? 'NOT_FOUND',
        );
      case 422:
        return ValidationException(
          message: message,
          errorCode: errorCode ?? 'VALIDATION_ERROR',
        );
      case >= 500:
        return ServerException(
          message: message,
          statusCode: statusCode,
          errorCode: errorCode ?? 'SERVER_ERROR',
        );
      default:
        return ClientException(
          message: message,
          statusCode: statusCode,
          errorCode: errorCode ?? 'CLIENT_ERROR',
        );
    }
  }

  /// Lấy message mặc định dựa trên status code
  static String _getDefaultErrorMessage(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Yêu cầu không hợp lệ';
      case 401:
        return 'Phiên đăng nhập đã hết hạn';
      case 403:
        return 'Bạn không có quyền truy cập';
      case 404:
        return 'Không tìm thấy dữ liệu';
      case 422:
        return 'Dữ liệu không hợp lệ';
      case 429:
        return 'Quá nhiều yêu cầu';
      case 500:
        return 'Lỗi máy chủ nội bộ';
      case 502:
        return 'Lỗi cổng kết nối';
      case 503:
        return 'Dịch vụ không khả dụng';
      case 504:
        return 'Hết thời gian chờ cổng kết nối';
      default:
        return 'Có lỗi xảy ra';
    }
  }

  /// Xử lý exception chung (không phải từ Dio)
  static AppException handleGeneralException(Exception exception) {
    logger.e('General exception occurred: $exception');

    if (exception is AppException) {
      return exception;
    }

    return UnknownException(
      details: exception.toString(),
    );
  }
}
