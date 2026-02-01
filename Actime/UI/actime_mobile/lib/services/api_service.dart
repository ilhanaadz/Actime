import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/api_response.dart';
import 'token_service.dart';

/// Core API service for making HTTP requests
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final TokenService _tokenService = TokenService();

  /// GET request
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, String>? queryParams,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParams);
      final headers = await _getHeaders();

      final response = await http
          .get(uri, headers: headers)
          .timeout(ApiConfig.connectionTimeout);

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return ApiResponse.error(_getErrorMessage(e));
    }
  }

  /// POST request
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      final uri = _buildUri(endpoint);
      final response = await http
          .post(
            uri,
            headers: await _getHeaders(),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConfig.connectionTimeout);

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return ApiResponse.error(_getErrorMessage(e));
    }
  }

  /// PUT request
  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      final uri = _buildUri(endpoint);
      final response = await http
          .put(
            uri,
            headers: await _getHeaders(),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConfig.connectionTimeout);

      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return ApiResponse.error(_getErrorMessage(e));
    }
  }

  /// DELETE request
  Future<ApiResponse<void>> delete(String endpoint) async {
    try {
      final uri = _buildUri(endpoint);
      final response = await http
          .delete(uri, headers: await _getHeaders())
          .timeout(ApiConfig.connectionTimeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse.success(null, statusCode: response.statusCode);
      }

      final errorBody = jsonDecode(response.body) as Map<String, dynamic>;
      return ApiResponse.error(
        errorBody['message'] as String? ?? 'Greška pri brisanju',
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse.error(_getErrorMessage(e));
    }
  }

  /// Build URI with query parameters
  Uri _buildUri(String endpoint, [Map<String, String>? queryParams]) {
    final baseUrl = ApiConfig.fullUrl;
    final url = '$baseUrl$endpoint';

    if (queryParams != null && queryParams.isNotEmpty) {
      return Uri.parse(url).replace(queryParameters: queryParams);
    }

    return Uri.parse(url);
  }

  /// Get headers with authorization token
  Future<Map<String, String>> _getHeaders() async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    final token = await _tokenService.getAccessToken();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  /// Handle HTTP response
  ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final statusCode = response.statusCode;

    if (statusCode >= 200 && statusCode < 300) {
      if (response.body.isEmpty) {
        return ApiResponse.success(fromJson({}), statusCode: statusCode);
      }

      try {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return ApiResponse.success(fromJson(data), statusCode: statusCode);
      } catch (e) {
        return ApiResponse.error('Greška pri parsiranju odgovora: $e', statusCode: statusCode);
      }
    }

    // Handle error responses
    String message = 'Došlo je do greške';
    Map<String, dynamic>? errors;

    try {
      final errorBody = jsonDecode(response.body) as Map<String, dynamic>;
      message = errorBody['message'] as String? ?? message;
      errors = errorBody['errors'] as Map<String, dynamic>?;
    } catch (_) {
      // If body is not JSON, use default message
      print('Error body not JSON: ${response.body}');
    }

    return ApiResponse.error(message, statusCode: statusCode, errors: errors);
  }

  /// Get user-friendly error message
  String _getErrorMessage(dynamic error) {
    if (error.toString().contains('SocketException')) {
      return 'Nema internet veze';
    }
    if (error.toString().contains('TimeoutException')) {
      return 'Zahtjev je istekao. Pokušajte ponovo.';
    }
    return 'Došlo je do greške. Pokušajte ponovo.';
  }
}
