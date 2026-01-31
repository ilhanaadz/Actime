import '../config/api_config.dart';
import '../models/models.dart';
import 'api_service.dart';
import 'mock_api_service.dart';

class CategoryService {
  static final CategoryService _instance = CategoryService._internal();
  factory CategoryService() => _instance;
  CategoryService._internal();

  final ApiService _apiService = ApiService();
  final MockApiService _mockService = MockApiService();

  Future<ApiResponse<PaginatedResponse<Category>>> getCategories({
    int page = 1,
    int pageSize = 10,
    String? search,
    String? sortBy,
    String? sortOrder,
  }) async {
    if (ApiConfig.useMockApi) {
      return await _mockService.getCategories(
        page: page,
        pageSize: pageSize,
        search: search,
        sortBy: sortBy,
      );
    }

    final queryParams = <String, String>{
      'Page': page.toString(),
      'PageSize': pageSize.toString(),
    };

    if (search != null && search.isNotEmpty) {
      queryParams['Search'] = search;
    }
    if (sortBy != null) {
      queryParams['SortBy'] = sortBy;
    }
    if (sortOrder != null) {
      queryParams['SortOrder'] = sortOrder;
    }

    return await _apiService.get<PaginatedResponse<Category>>(
      ApiConfig.category,
      queryParams: queryParams,
      fromJson: (json) => PaginatedResponse.fromJson(json, Category.fromJson),
    );
  }

  Future<ApiResponse<List<Category>>> getAllCategories() async {
    if (ApiConfig.useMockApi) {
      final response = await _mockService.getCategories(pageSize: 100);
      if (response.success && response.data != null) {
        return ApiResponse(
          success: true,
          data: response.data!.items,
          statusCode: response.statusCode,
        );
      }
      return ApiResponse(
        success: false,
        message: response.message,
        statusCode: response.statusCode,
      );
    }

    return await _apiService.get<List<Category>>(
      ApiConfig.category,
      queryParams: {'PageSize': '100'},
      fromJson: (json) {
        if (json is Map && (json.containsKey('Items') || json.containsKey('items'))) {
          final items = json['Items'] ?? json['items'];
          return (items as List)
              .map((item) => Category.fromJson(item))
              .toList();
        }
        if (json is List) {
          return json.map((item) => Category.fromJson(item)).toList();
        }
        return <Category>[];
      },
    );
  }

  Future<ApiResponse<Category>> getCategoryById(int id) async {
    if (ApiConfig.useMockApi) {
      return await _mockService.getCategoryById(id);
    }

    return await _apiService.get<Category>(
      ApiConfig.categoryById(id),
      fromJson: (json) => Category.fromJson(json),
    );
  }

  Future<ApiResponse<Category>> createCategory({
    required String name,
    String? description,
  }) async {
    if (ApiConfig.useMockApi) {
      return await _mockService.createCategory(name, description);
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

  Future<ApiResponse<Category>> updateCategory({
    required int id,
    String? name,
    String? description,
  }) async {
    if (ApiConfig.useMockApi && name != null) {
      return await _mockService.updateCategory(id, name, description);
    }

    final body = <String, dynamic>{};
    if (name != null) body['Name'] = name;
    if (description != null) body['Description'] = description;

    return await _apiService.put<Category>(
      ApiConfig.categoryById(id),
      body: body,
      fromJson: (json) => Category.fromJson(json),
    );
  }

  Future<ApiResponse<void>> deleteCategory(int id) async {
    if (ApiConfig.useMockApi) {
      return await _mockService.deleteCategory(id);
    }

    return await _apiService.delete<void>(
      ApiConfig.categoryById(id),
    );
  }
}
