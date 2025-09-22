// lib/core/exception/app_exception.dart

abstract class AppException implements Exception {
  final String message;
  final String? details;
  final int? statusCode;
  final String? errorCode;

  const AppException({
    required this.message,
    this.details,
    this.statusCode,
    this.errorCode,
  });

  @override
  String toString() => message;
}

/// Exception cho lỗi server (5xx)
class ServerException extends AppException {
  const ServerException({
    required super.message,
    super.details,
    super.statusCode,
    super.errorCode,
  });
}

/// Exception cho lỗi client (4xx)
class ClientException extends AppException {
  const ClientException({
    required super.message,
    super.details,
    super.statusCode,
    super.errorCode,
  });
}

/// Exception cho lỗi network (không có kết nối)
class NetworkException extends AppException {
  const NetworkException({
    super.message = 'Không có kết nối mạng',
    super.details,
    super.errorCode = 'NETWORK_ERROR',
  });
}

/// Exception cho lỗi timeout
class TimeoutException extends AppException {
  const TimeoutException({
    super.message = 'Yêu cầu đã hết thời gian chờ',
    super.details,
    super.errorCode = 'TIMEOUT_ERROR',
  });
}

/// Exception cho lỗi authentication (401)
class UnauthorizedException extends AppException {
  const UnauthorizedException({
    super.message = 'Phiên đăng nhập đã hết hạn',
    super.details,
    super.statusCode = 401,
    super.errorCode = 'UNAUTHORIZED',
  });
}

/// Exception cho lỗi forbidden (403)
class ForbiddenException extends AppException {
  const ForbiddenException({
    super.message = 'Bạn không có quyền truy cập',
    super.details,
    super.statusCode = 403,
    super.errorCode = 'FORBIDDEN',
  });
}

/// Exception cho lỗi not found (404)
class NotFoundException extends AppException {
  const NotFoundException({
    super.message = 'Không tìm thấy dữ liệu',
    super.details,
    super.statusCode = 404,
    super.errorCode = 'NOT_FOUND',
  });
}

/// Exception cho lỗi validation (422)
class ValidationException extends AppException {
  final Map<String, List<String>>? errors;

  const ValidationException({
    super.message = 'Dữ liệu không hợp lệ',
    super.details,
    super.statusCode = 422,
    super.errorCode = 'VALIDATION_ERROR',
    this.errors,
  });
}

/// Exception cho lỗi không xác định
class UnknownException extends AppException {
  const UnknownException({
    super.message = 'Có lỗi không xác định xảy ra',
    super.details,
    super.errorCode = 'UNKNOWN_ERROR',
  });
}

/// Exception dựa trên backend error code
class BackendException extends AppException {
  const BackendException({
    required super.message,
    required super.statusCode,
    required super.errorCode,
    super.details,
  });
}
