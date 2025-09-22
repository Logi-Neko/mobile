// lib/core/exception/error_response.dart

class ErrorResponse {
  final String message;
  final String? details;
  final int status;
  final String code;
  final String? path;
  final String? timestamp;
  final Map<String, List<String>>? errors;

  const ErrorResponse({
    required this.message,
    required this.status,
    required this.code,
    this.details,
    this.path,
    this.timestamp,
    this.errors,
  });

  factory ErrorResponse.fromJson(Map<String, dynamic> json) {
    return ErrorResponse(
      message: json['message'] ?? 'Có lỗi xảy ra',
      status: json['status'] ?? 500,
      code: json['code'] ?? 'UNKNOWN_ERROR',
      details: json['details'],
      path: json['path'],
      timestamp: json['timestamp'],
      errors: _parseErrors(json['errors']),
    );
  }

  static Map<String, List<String>>? _parseErrors(dynamic errorsData) {
    if (errorsData == null) return null;

    final Map<String, List<String>> result = {};

    if (errorsData is Map<String, dynamic>) {
      errorsData.forEach((key, value) {
        if (value is List) {
          result[key] = value.map((e) => e.toString()).toList();
        } else if (value is String) {
          result[key] = [value];
        }
      });
    }

    return result.isEmpty ? null : result;
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'status': status,
      'code': code,
      'details': details,
      'path': path,
      'timestamp': timestamp,
      'errors': errors,
    };
  }

  @override
  String toString() {
    return 'ErrorResponse(message: $message, status: $status, code: $code)';
  }
}
