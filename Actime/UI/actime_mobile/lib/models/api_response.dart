/// Generic API response wrapper
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final int statusCode;
  final Map<String, dynamic>? errors;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.statusCode = 200,
    this.errors,
  });

  /// Create a successful response
  factory ApiResponse.success(T data, {String? message, int statusCode = 200}) {
    return ApiResponse(
      success: true,
      data: data,
      message: message,
      statusCode: statusCode,
    );
  }

  /// Create an error response
  factory ApiResponse.error(
    String message, {
    int statusCode = 400,
    Map<String, dynamic>? errors,
  }) {
    return ApiResponse(
      success: false,
      message: message,
      statusCode: statusCode,
      errors: errors,
    );
  }

  /// Check if the response has data
  bool get hasData => data != null;

  /// Check if there are validation errors
  bool get hasErrors => errors != null && errors!.isNotEmpty;
}

/// API Exception for handling errors
class ApiException implements Exception {
  final int statusCode;
  final String message;
  final dynamic data;

  ApiException({
    required this.statusCode,
    required this.message,
    this.data,
  });

  @override
  String toString() => 'ApiException: $statusCode - $message';

  /// Check if it's an authentication error
  bool get isAuthError => statusCode == 401;

  /// Check if it's a forbidden error
  bool get isForbiddenError => statusCode == 403;

  /// Check if it's a not found error
  bool get isNotFoundError => statusCode == 404;

  /// Check if it's a validation error
  bool get isValidationError => statusCode == 422;

  /// Check if it's a server error
  bool get isServerError => statusCode >= 500;
}
