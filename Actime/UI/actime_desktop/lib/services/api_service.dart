import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'token_service.dart';

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
}

class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final int statusCode;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    required this.statusCode,
  });
}

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final TokenService _tokenService = TokenService();

  Future<Map<String, String>> _getHeaders({bool requiresAuth = true}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requiresAuth) {
      final token = await _tokenService.getAccessToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    bool requiresAuth = true,
    T Function(dynamic)? fromJson,
    Map<String, String>? queryParams,
  }) async {
    try {
      var uri = Uri.parse(ApiConfig.fullUrl(endpoint));
      if (queryParams != null && queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final response = await http
          .get(uri, headers: await _getHeaders(requiresAuth: requiresAuth))
          .timeout(ApiConfig.connectionTimeout);

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    dynamic body,
    bool requiresAuth = true,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConfig.fullUrl(endpoint)),
            headers: await _getHeaders(requiresAuth: requiresAuth),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConfig.connectionTimeout);

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    dynamic body,
    bool requiresAuth = true,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await http
          .put(
            Uri.parse(ApiConfig.fullUrl(endpoint)),
            headers: await _getHeaders(requiresAuth: requiresAuth),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConfig.connectionTimeout);

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    bool requiresAuth = true,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await http
          .delete(
            Uri.parse(ApiConfig.fullUrl(endpoint)),
            headers: await _getHeaders(requiresAuth: requiresAuth),
          )
          .timeout(ApiConfig.connectionTimeout);

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T Function(dynamic)? fromJson,
  ) {
    final statusCode = response.statusCode;
    dynamic responseData;

    try {
      if (response.body.isNotEmpty) {
        responseData = jsonDecode(response.body);
      }
    } catch (_) {
      responseData = response.body;
    }

    if (statusCode >= 200 && statusCode < 300) {
      return ApiResponse<T>(
        success: true,
        data: fromJson != null && responseData != null
            ? fromJson(responseData)
            : responseData,
        statusCode: statusCode,
      );
    }

    String errorMessage = 'An error occurred';
    if (responseData is Map && responseData.containsKey('message')) {
      errorMessage = responseData['message'];
    }

    throw ApiException(
      statusCode: statusCode,
      message: errorMessage,
      data: responseData,
    );
  }

  ApiResponse<T> _handleError<T>(dynamic error) {
    if (error is ApiException) {
      return ApiResponse<T>(
        success: false,
        message: error.message,
        statusCode: error.statusCode,
      );
    }

    return ApiResponse<T>(
      success: false,
      message: error.toString(),
      statusCode: 0,
    );
  }
}
