import '../config/api_config.dart';
import '../models/models.dart';
import 'api_service.dart';

class ReviewService {
  static final ReviewService _instance = ReviewService._internal();
  factory ReviewService() => _instance;
  ReviewService._internal();

  final ApiService _apiService = ApiService();

  Future<ApiResponse<PaginatedResponse<Review>>> getReviews({
    int page = 1,
    int pageSize = 10,
    int? organizationId,
    int? userId,
  }) async {
    final queryParams = <String, String>{
      'Page': page.toString(),
      'PageSize': pageSize.toString(),
    };

    if (organizationId != null) {
      queryParams['OrganizationId'] = organizationId.toString();
    }
    if (userId != null) {
      queryParams['UserId'] = userId.toString();
    }

    return await _apiService.get<PaginatedResponse<Review>>(
      ApiConfig.review,
      queryParams: queryParams,
      fromJson: (json) => PaginatedResponse.fromJson(json, Review.fromJson),
    );
  }

  Future<ApiResponse<PaginatedResponse<Review>>> getReviewsByOrganization(
    int organizationId, {
    int page = 1,
    int pageSize = 10,
  }) async {
    final queryParams = <String, String>{
      'Page': page.toString(),
      'PageSize': pageSize.toString(),
    };

    return await _apiService.get<PaginatedResponse<Review>>(
      ApiConfig.reviewByOrganization(organizationId),
      queryParams: queryParams,
      fromJson: (json) => PaginatedResponse.fromJson(json, Review.fromJson),
    );
  }

  Future<ApiResponse<double>> getOrganizationAverageRating(int organizationId) async {
    return await _apiService.get<double>(
      ApiConfig.reviewOrganizationAverage(organizationId),
      fromJson: (json) {
        if (json is num) return json.toDouble();
        if (json is Map) {
          return (json['Average'] ?? json['average'] ?? 0).toDouble();
        }
        return 0.0;
      },
    );
  }

  Future<ApiResponse<Review>> getReviewById(int id) async {
    return await _apiService.get<Review>(
      ApiConfig.reviewById(id),
      fromJson: (json) => Review.fromJson(json),
    );
  }

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
        'Rating': rating,
        'Comment': comment,
      },
      fromJson: (json) => Review.fromJson(json),
    );
  }

  Future<ApiResponse<Review>> updateReview({
    required int id,
    int? rating,
    String? comment,
  }) async {
    final body = <String, dynamic>{};
    if (rating != null) body['Rating'] = rating;
    if (comment != null) body['Comment'] = comment;

    return await _apiService.put<Review>(
      ApiConfig.reviewById(id),
      body: body,
      fromJson: (json) => Review.fromJson(json),
    );
  }

  Future<ApiResponse<void>> deleteReview(int id) async {
    return await _apiService.delete<void>(
      ApiConfig.reviewById(id),
    );
  }
}
