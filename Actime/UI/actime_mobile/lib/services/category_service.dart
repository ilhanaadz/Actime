import '../config/api_config.dart';
import '../models/models.dart';
import 'api_service.dart';
import 'mock_api_service.dart';

/// Category service
class CategoryService {
  static final CategoryService _instance = CategoryService._internal();
  factory CategoryService() => _instance;
  CategoryService._internal();

  final ApiService _apiService = ApiService();
  final MockApiService _mockService = MockApiService();

  /// Get all categories
  Future<ApiResponse<PaginatedResponse<Category>>> getCategories({
    int page = 1,
    int perPage = 20,
    String? search,
  }) async {
    if (ApiConfig.useMockApi) {
      return await _mockService.getCategories(
        page: page,
        perPage: perPage,
        search: search,
      );
    }

    return await _apiService.get<PaginatedResponse<Category>>(
      ApiConfig.categories,
      queryParams: {
        'page': page.toString(),
        'perPage': perPage.toString(),
        if (search != null) 'search': search,
      },
      fromJson: (json) => PaginatedResponse.fromJson(json, Category.fromJson),
    );
  }

  /// Get category by ID
  Future<ApiResponse<Category>> getCategoryById(String id) async {
    if (ApiConfig.useMockApi) {
      return await _mockService.getCategoryById(id);
    }

    return await _apiService.get<Category>(
      ApiConfig.categoryById(id),
      fromJson: (json) => Category.fromJson(json),
    );
  }

  /// Get all categories as a simple list
  Future<List<Category>> getAllCategories() async {
    final response = await getCategories(perPage: 100);
    if (response.success && response.data != null) {
      return response.data!.data;
    }
    return [];
  }
}
