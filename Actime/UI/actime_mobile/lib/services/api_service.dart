import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/api_response.dart';
import 'token_service.dart';

/// Helper function to parse list responses
/// Use this when the API returns an array directly (not wrapped in an object)
List<T> parseListResponse<T>(
  dynamic json,
  T Function(Map<String, dynamic>) itemFromJson,
) {
  if (json is! List) {
    throw Exception('Expected list response but got ${json.runtimeType}');
  }
  return json.map((item) => itemFromJson(item as Map<String, dynamic>)).toList();
}

/// Core API service for making HTTP requests
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final TokenService _tokenService = TokenService();

  /// Callback for refreshing expired token
  Future<bool> Function()? onTokenRefresh;

  /// Callback for when authentication fails and can't be recovered
  Future<void> Function()? onAuthenticationFailed;

  bool _isRefreshing = false;

  final List<String> _excludedEndpoints = [
    '/login',
    '/register',
    '/refresh-token',
    '/forgot-password',
    '/reset-password',
    '/confirm-email',
  ];

  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, String>? queryParams,
    required T Function(dynamic) fromJson,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParams);
      final headers = await _getHeaders();

      final response = await http
          .get(uri, headers: headers)
          .timeout(ApiConfig.connectionTimeout);

      return await _handleUnifiedResponse<T>(response, fromJson, endpoint);
    } catch (e) {
      return ApiResponse.error(_getErrorMessage(e));
    }
  }

  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    required T Function(dynamic) fromJson,
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

      return await _handleUnifiedResponse<T>(response, fromJson, endpoint);
    } catch (e) {
      return ApiResponse.error(_getErrorMessage(e));
    }
  }

  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    required T Function(dynamic) fromJson,
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

      return await _handleUnifiedResponse<T>(response, fromJson, endpoint);
    } catch (e) {
      return ApiResponse.error(_getErrorMessage(e));
    }
  }

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

  Uri _buildUri(String endpoint, [Map<String, String>? queryParams]) {
    final baseUrl = ApiConfig.fullUrl;
    final url = '$baseUrl$endpoint';

    if (queryParams != null && queryParams.isNotEmpty) {
      return Uri.parse(url).replace(queryParameters: queryParams);
    }

    return Uri.parse(url);
  }

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

  bool _shouldHandleAuth(String endpoint) {
    return !_excludedEndpoints.any((excluded) => endpoint.contains(excluded));
  }

  /// Returns true if we should retry the request after refresh
  Future<bool> _handle401(String endpoint) async {
    // Don't handle auth for excluded endpoints (login, register, etc.)
    if (!_shouldHandleAuth(endpoint)) {
      return false;
    }

    if (_isRefreshing) {
      return false;
    }

    // Try to refresh token if callback is available
    if (onTokenRefresh != null) {
      _isRefreshing = true;
      try {
        final refreshSuccess = await onTokenRefresh!();
        _isRefreshing = false;

        if (refreshSuccess) {
          return true;
        }
      } catch (e) {
        _isRefreshing = false;
      }
    }

    if (onAuthenticationFailed != null) {
      await onAuthenticationFailed!();
    }

    return false;
  }

  Future<ApiResponse<T>> _handleUnifiedResponse<T>(
    http.Response response,
    T Function(dynamic) fromJson,
    String endpoint,
  ) async {
    final statusCode = response.statusCode;

    if (statusCode >= 200 && statusCode < 300) {
      if (response.body.isEmpty) {
        try {
          return ApiResponse.success(fromJson(null), statusCode: statusCode);
        } catch (e) {
          return ApiResponse.error('Prazan odgovor', statusCode: statusCode);
        }
      }

      try {
        final data = jsonDecode(response.body);
        final result = fromJson(data);
        return ApiResponse.success(result, statusCode: statusCode);
      } catch (e) {
        return ApiResponse.error('Greška pri parsiranju odgovora: $e', statusCode: statusCode);
      }
    }

    if (statusCode == 401) {
      await _handle401(endpoint);
    }

    String message = 'Došlo je do greške';
    Map<String, dynamic>? errors;

    try {
      final errorBody = jsonDecode(response.body) as Map<String, dynamic>;
      message = errorBody['message'] as String? ?? message;
      errors = errorBody['errors'] as Map<String, dynamic>?;
    } catch (_) {
      print('Error body not JSON: ${response.body}');
    }

    return ApiResponse.error(message, statusCode: statusCode, errors: errors);
  }

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
