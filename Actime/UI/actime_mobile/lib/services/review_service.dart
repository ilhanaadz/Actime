import '../config/api_config.dart';
import '../models/api_response.dart';
import '../models/paginated_response.dart';
import '../models/review.dart';
import 'api_service.dart';

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
    if (ApiConfig.useMockApi) {
      return ApiResponse.success(PaginatedResponse(items: [], totalCount: 0));
    }

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
    if (ApiConfig.useMockApi) {
      return ApiResponse.error('Mock nije dostupan');
    }

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
    if (ApiConfig.useMockApi) {
      return ApiResponse.error('Mock nije dostupan');
    }

    return await _apiService.post<Review>(
      ApiConfig.review,
      body: {
        'UserId': userId,
        'OrganizationId': organizationId,
        'Rating': rating,
        if (comment != null) 'Comment': comment,
      },
      fromJson: (json) => Review.fromJson(json),
    );
  }

  /// Update review
  Future<ApiResponse<Review>> updateReview(int id, {int? rating, String? comment}) async {
    if (ApiConfig.useMockApi) {
      return ApiResponse.error('Mock nije dostupan');
    }

    return await _apiService.put<Review>(
      ApiConfig.reviewById(id),
      body: {
        if (rating != null) 'Rating': rating,
        if (comment != null) 'Comment': comment,
      },
      fromJson: (json) => Review.fromJson(json),
    );
  }

  /// Delete review
  Future<ApiResponse<void>> deleteReview(int id) async {
    if (ApiConfig.useMockApi) {
      return ApiResponse.success(null);
    }

    return await _apiService.delete(ApiConfig.reviewById(id));
  }

  /// Get reviews by organization (public endpoint)
  Future<ApiResponse<List<Review>>> getReviewsByOrganization(int organizationId) async {
    if (ApiConfig.useMockApi) {
      return ApiResponse.success([]);
    }

    return await _apiService.get<List<Review>>(
      ApiConfig.reviewByOrganization(organizationId),
      fromJson: (json) {
        final list = json['items'] as List? ?? json as List? ?? [];
        return list.map((item) => Review.fromJson(item as Map<String, dynamic>)).toList();
      },
    );
  }

  /// Get organization average rating (public endpoint)
  Future<ApiResponse<double>> getOrganizationAverageRating(int organizationId) async {
    if (ApiConfig.useMockApi) {
      return ApiResponse.success(0.0);
    }

    return await _apiService.get<double>(
      ApiConfig.reviewOrganizationAverage(organizationId),
      fromJson: (json) => (json['average'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Get reviews by user
  Future<ApiResponse<List<Review>>> getReviewsByUser(int userId) async {
    if (ApiConfig.useMockApi) {
      return ApiResponse.success([]);
    }

    return await _apiService.get<List<Review>>(
      ApiConfig.reviewByUser(userId),
      fromJson: (json) {
        final list = json['items'] as List? ?? json as List? ?? [];
        return list.map((item) => Review.fromJson(item as Map<String, dynamic>)).toList();
      },
    );
  }
}
