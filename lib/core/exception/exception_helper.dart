// lib/core/exception/exception_helper.dart

import 'package:dio/dio.dart';
import 'app_exception.dart';
import 'exception_handler.dart';

class ExceptionHelper {
  /// Wrapper function để tự động xử lý exception cho các API calls
  static Future<T> handleApiCall<T>(Future<T> Function() apiCall) async {
    try {
      return await apiCall();
    } on DioException catch (e) {
      throw ExceptionHandler.handleDioException(e);
    } on AppException {
      rethrow;
    } catch (e) {
      throw ExceptionHandler.handleGeneralException(e as Exception);
    }
  }

  /// Lấy user-friendly message từ exception
  static String getErrorMessage(dynamic error) {
    if (error is AppException) {
      return error.message;
    } else if (error is DioException && error.error is AppException) {
      return (error.error as AppException).message;
    } else if (error is Exception) {
      return 'Có lỗi không xác định xảy ra';
    } else {
      return error.toString();
    }
  }

  /// Lấy error code từ exception
  static String? getErrorCode(dynamic error) {
    if (error is AppException) {
      return error.errorCode;
    } else if (error is DioException && error.error is AppException) {
      return (error.error as AppException).errorCode;
    }
    return null;
  }

  /// Kiểm tra xem có phải lỗi network không
  static bool isNetworkError(dynamic error) {
    return error is NetworkException ||
        (error is DioException && error.error is NetworkException);
  }

  /// Kiểm tra xem có phải lỗi authentication không
  static bool isAuthError(dynamic error) {
    return error is UnauthorizedException ||
        (error is DioException && error.error is UnauthorizedException);
  }

  /// Kiểm tra xem có phải lỗi validation không
  static bool isValidationError(dynamic error) {
    return error is ValidationException ||
        (error is DioException && error.error is ValidationException);
  }

  /// Kiểm tra error dựa trên backend error code
  static bool hasErrorCode(dynamic error, String errorCode) {
    final code = getErrorCode(error);
    return code != null && code == errorCode;
  }

  /// Kiểm tra xem có phải lỗi từ backend không (có error code)
  static bool isBackendError(dynamic error) {
    return error is BackendException ||
        (error is DioException && error.error is BackendException);
  }

  /// Lấy validation errors nếu có
  static Map<String, List<String>>? getValidationErrors(dynamic error) {
    if (error is ValidationException) {
      return error.errors;
    } else if (error is DioException && error.error is ValidationException) {
      return (error.error as ValidationException).errors;
    }
    return null;
  }

  /// Kiểm tra các loại lỗi phổ biến từ backend
  static bool isUserNotFoundError(dynamic error) {
    return hasErrorCode(error, 'USER_NOT_FOUND');
  }

  static bool isInvalidCredentialsError(dynamic error) {
    return hasErrorCode(error, 'INVALID_CREDENTIALS');
  }

  static bool isTokenExpiredError(dynamic error) {
    return hasErrorCode(error, 'TOKEN_EXPIRED');
  }

  static bool isResourceNotFoundError(dynamic error) {
    return hasErrorCode(error, 'RESOURCE_NOT_FOUND');
  }

  static bool isAccessDeniedError(dynamic error) {
    return hasErrorCode(error, 'ACCESS_DENIED');
  }

  /// Xử lý lỗi một cách tự động dựa trên error code
  static String getLocalizedErrorMessage(dynamic error) {
    final errorCode = getErrorCode(error);

    if (errorCode != null) {
      switch (errorCode) {
        case 'USER_NOT_FOUND':
          return 'Không tìm thấy người dùng';
        case 'INVALID_CREDENTIALS':
          return 'Tên đăng nhập hoặc mật khẩu không đúng';
        case 'TOKEN_EXPIRED':
          return 'Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại';
        case 'ACCESS_DENIED':
          return 'Bạn không có quyền thực hiện hành động này';
        case 'RESOURCE_NOT_FOUND':
          return 'Không tìm thấy tài nguyên yêu cầu';
        case 'VALIDATION_ERROR':
          return 'Dữ liệu nhập vào không hợp lệ';
        case 'NETWORK_ERROR':
          return 'Không có kết nối mạng';
        case 'TIMEOUT_ERROR':
          return 'Kết nối quá chậm, vui lòng thử lại';
        default:
          break;
      }
    }

    // Fallback về message gốc
    return getErrorMessage(error);
  }
}
