import '../config/api_config.dart';
import '../models/models.dart';
import 'api_service.dart';

class CategoryService {
  static final CategoryService _instance = CategoryService._internal();
  factory CategoryService() => _instance;
  CategoryService._internal();

  final ApiService _apiService = ApiService();

  Future<ApiResponse<PaginatedResponse<Category>>> getCategories({
    int page = 1,
    int pageSize = 10,
    int? perPage,
    String? search,
    String? sortBy,
    String? sortOrder,
  }) async {
    // Use perPage if provided, otherwise use pageSize
    final effectivePageSize = perPage ?? pageSize;

    final queryParams = <String, String>{
      'Page': page.toString(),
      'PageSize': effectivePageSize.toString(),
      'IncludeTotalCount': 'true',
    };

    if (search != null && search.isNotEmpty) {
      queryParams['Text'] = search;
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
    return await _apiService.get<Category>(
      ApiConfig.categoryById(id),
      fromJson: (json) => Category.fromJson(json),
    );
  }

  Future<ApiResponse<Category>> createCategory({
    required String name,
    String? description,
  }) async {
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
    return await _apiService.delete<void>(
      ApiConfig.categoryById(id),
    );
  }
}
