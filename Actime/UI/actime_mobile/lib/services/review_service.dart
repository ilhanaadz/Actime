import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/api_response.dart';
import '../models/paginated_response.dart';
import '../models/review.dart';
import 'api_service.dart';
import 'token_service.dart';

/// Review service
/// Communicates with backend ReviewController
class ReviewService {
  static final ReviewService _instance = ReviewService._internal();
  factory ReviewService() => _instance;
  ReviewService._internal();

  final ApiService _apiService = ApiService();

  /// Get reviews (paginated)
  Future<ApiResponse<PaginatedResponse<Review>>> getReviews({
    int page = 1,
    int pageSize = 10,
    bool includeTotalCount = true,
  }) async {
    return await _apiService.get<PaginatedResponse<Review>>(
      ApiConfig.review,
      queryParams: {
        'Page': page.toString(),
        'PageSize': pageSize.toString(),
        'IncludeTotalCount': includeTotalCount.toString(),
      },
      fromJson: (json) => PaginatedResponse.fromJson(json, Review.fromJson),
    );
  }

  /// Get review by ID
  Future<ApiResponse<Review>> getReviewById(int id) async {
    return await _apiService.get<Review>(
      ApiConfig.reviewById(id),
      fromJson: (json) => Review.fromJson(json),
    );
  }

  /// Create review
  Future<ApiResponse<Review>> createReview({
    required int userId,
    required int organizationId,
    required int rating,
    String? comment,
  }) async {
    return await _apiService.post<Review>(
      ApiConfig.review,
      body: {
        'UserId': userId,
        'OrganizationId': organizationId,
        'Score': rating,
        if (comment != null) 'Text': comment,
      },
      fromJson: (json) => Review.fromJson(json),
    );
  }

  /// Update review
  Future<ApiResponse<Review>> updateReview(int id, {int? rating, String? comment}) async {
    return await _apiService.put<Review>(
      ApiConfig.reviewById(id),
      body: {
        if (rating != null) 'Score': rating,
        if (comment != null) 'Text': comment,
      },
      fromJson: (json) => Review.fromJson(json),
    );
  }

  /// Delete review
  Future<ApiResponse<void>> deleteReview(int id) async {
    return await _apiService.delete(ApiConfig.reviewById(id));
  }

  /// Get reviews by organization (public endpoint)
  /// Uses raw HTTP because backend returns a plain JSON array, not a Map.
  Future<ApiResponse<List<Review>>> getReviewsByOrganization(int organizationId) async {
    try {
      final uri = Uri.parse('${ApiConfig.fullUrl}${ApiConfig.reviewByOrganization(organizationId)}');
      final headers = await _buildHeaders();
      final response = await http.get(uri, headers: headers).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final list = jsonDecode(response.body) as List;
        return ApiResponse.success(
          list.map((item) => Review.fromJson(item as Map<String, dynamic>)).toList(),
        );
      }
      return ApiResponse.error('Greška pri učitavanju recenzija', statusCode: response.statusCode);
    } catch (e) {
      return ApiResponse.error('Došlo je do greške. Pokušajte ponovo.');
    }
  }

  /// Get organization average rating (public endpoint)
  /// Uses raw HTTP because backend returns a plain double, not a Map.
  Future<ApiResponse<double>> getOrganizationAverageRating(int organizationId) async {
    try {
      final uri = Uri.parse('${ApiConfig.fullUrl}${ApiConfig.reviewOrganizationAverage(organizationId)}');
      final headers = await _buildHeaders();
      final response = await http.get(uri, headers: headers).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final value = jsonDecode(response.body) as num;
        return ApiResponse.success(value.toDouble());
      }
      return ApiResponse.error('Greška pri učitavanju ocjene', statusCode: response.statusCode);
    } catch (e) {
      return ApiResponse.error('Došlo je do greške. Pokušajte ponovo.');
    }
  }

  /// Get reviews by user
  /// Uses raw HTTP because backend returns a plain JSON array, not a Map.
  Future<ApiResponse<List<Review>>> getReviewsByUser(int userId) async {
    try {
      final uri = Uri.parse('${ApiConfig.fullUrl}${ApiConfig.reviewByUser(userId)}');
      final headers = await _buildHeaders();
      final response = await http.get(uri, headers: headers).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final list = jsonDecode(response.body) as List;
        return ApiResponse.success(
          list.map((item) => Review.fromJson(item as Map<String, dynamic>)).toList(),
        );
      }
      return ApiResponse.error('Greška pri učitavanju recenzija', statusCode: response.statusCode);
    } catch (e) {
      return ApiResponse.error('Došlo je do greške. Pokušajte ponovo.');
    }
  }

  Future<Map<String, String>> _buildHeaders() async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    final token = await TokenService().getAccessToken();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }
}
