import '../config/api_config.dart';
import '../models/models.dart';
import 'api_service.dart';
import 'mock_api_service.dart';

/// Category service
/// Communicates with backend CategoryController
class CategoryService {
  static final CategoryService _instance = CategoryService._internal();
  factory CategoryService() => _instance;
  CategoryService._internal();

  final ApiService _apiService = ApiService();
  final MockApiService _mockService = MockApiService();

  /// Get all categories (paginated)
  /// Backend uses TextSearchObject for filtering
  Future<ApiResponse<PaginatedResponse<Category>>> getCategories({
    int page = 1,
    int pageSize = 20,
    String? text,
    String? sortBy,
    bool sortDescending = false,
    bool includeTotalCount = true,
  }) async {
    if (ApiConfig.useMockApi) {
      return await _mockService.getCategories(
        page: page,
        perPage: pageSize,
        search: text,
      );
    }

    return await _apiService.get<PaginatedResponse<Category>>(
      ApiConfig.category,
      queryParams: {
        'Page': page.toString(),
        'PageSize': pageSize.toString(),
        'IncludeTotalCount': includeTotalCount.toString(),
        if (text != null && text.isNotEmpty) 'Text': text,
        if (sortBy != null) 'SortBy': sortBy,
        'SortDescending': sortDescending.toString(),
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
      '${ApiConfig.category}/$id',
      fromJson: (json) => Category.fromJson(json),
    );
  }

  /// Create category (admin only)
  Future<ApiResponse<Category>> createCategory({
    required String name,
    String? description,
  }) async {
    if (ApiConfig.useMockApi) {
      return ApiResponse.success(Category(
        id: '100',
        name: name,
        description: description,
      ));
    }

    return await _apiService.post<Category>(
      ApiConfig.category,
      body: {
        'Name': name,
        'Description': description,
      },
      fromJson: (json) => Category.fromJson(json),
    );
  }

  /// Update category
  Future<ApiResponse<Category>> updateCategory(
    String id, {
    String? name,
    String? description,
  }) async {
    if (ApiConfig.useMockApi) {
      return ApiResponse.success(Category(
        id: id,
        name: name ?? 'Updated',
        description: description,
      ));
    }

    return await _apiService.put<Category>(
      '${ApiConfig.category}/$id',
      body: {
        if (name != null) 'Name': name,
        if (description != null) 'Description': description,
      },
      fromJson: (json) => Category.fromJson(json),
    );
  }

  /// Delete category
  Future<ApiResponse<void>> deleteCategory(String id) async {
    if (ApiConfig.useMockApi) {
      return ApiResponse.success(null, message: 'Kategorija je obrisana');
    }

    return await _apiService.delete('${ApiConfig.category}/$id');
  }

  /// Get all categories as a simple list (no pagination)
  Future<List<Category>> getAllCategories() async {
    final response = await getCategories(pageSize: 100);
    if (response.success && response.data != null) {
      return response.data!.items;
    }
    return [];
  }
}
