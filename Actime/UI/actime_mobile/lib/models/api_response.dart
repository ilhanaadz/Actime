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

  factory ApiResponse.success(T data, {String? message, int statusCode = 200}) {
    return ApiResponse(
      success: true,
      data: data,
      message: message,
      statusCode: statusCode,
    );
  }

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

  bool get hasData => data != null;

  bool get hasErrors => errors != null && errors!.isNotEmpty;

  String? getFieldError(String fieldName) {
    if (errors == null) return null;

    final error = errors![fieldName];
    if (error != null) {
      if (error is List && error.isNotEmpty) {
        return error.first.toString();
      } else if (error is String) {
        return error;
      }
    }

    final pascalCase = fieldName[0].toUpperCase() + fieldName.substring(1);
    final pascalError = errors![pascalCase];
    if (pascalError != null) {
      if (pascalError is List && pascalError.isNotEmpty) {
        return pascalError.first.toString();
      } else if (pascalError is String) {
        return pascalError;
      }
    }

    return null;
  }

  Map<String, String> getAllFieldErrors() {
    if (errors == null) return {};

    final result = <String, String>{};
    errors!.forEach((key, value) {
      final camelCaseKey = key[0].toLowerCase() + key.substring(1);
      if (value is List && value.isNotEmpty) {
        result[camelCaseKey] = value.first.toString();
      } else if (value is String) {
        result[camelCaseKey] = value;
      }
    });
    return result;
  }
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

  bool get isAuthError => statusCode == 401;

  bool get isForbiddenError => statusCode == 403;

  bool get isNotFoundError => statusCode == 404;

  bool get isValidationError => statusCode == 422;

  bool get isServerError => statusCode >= 500;
}
