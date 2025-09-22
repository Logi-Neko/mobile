class ApiResponse<T> {
  final int status;
  final String? code;
  final String? message;
  final T? data;
  final String? path;
  final List<String>? errors;
  final Map<String, dynamic>? metadata;

  ApiResponse({
    required this.status,
    this.code,
    this.message,
    this.data,
    this.path,
    this.errors,
    this.metadata,
  });

  /// Generic fromJson
  factory ApiResponse.fromJson(
      Map<String, dynamic> json,
      T Function(Object? json)? fromJsonT,
      ) {
    return ApiResponse<T>(
      status: json['status'] ?? 0,
      code: json['code'],
      message: json['message'],
      data: fromJsonT != null && json['data'] != null
          ? fromJsonT(json['data'])
          : null,
      path: json['path'],
      errors: (json['errors'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      metadata: json['metadata'] != null
          ? Map<String, dynamic>.from(json['metadata'])
          : null,
    );
  }

  /// toJson để debug hoặc gửi ngược lên BE (hiếm khi dùng)
  Map<String, dynamic> toJson(Object? Function(T value)? toJsonT) {
    return {
      'status': status,
      'code': code,
      'message': message,
      'data': data != null && toJsonT != null ? toJsonT(data as T) : data,
      'path': path,
      'errors': errors,
      'metadata': metadata,
    };
  }

  bool get isSuccess => status >= 200 && status < 300;
  bool get isError => !isSuccess;
  bool get hasData => data != null;
}
