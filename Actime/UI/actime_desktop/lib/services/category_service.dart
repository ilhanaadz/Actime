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
    int perPage = 10,
    String? search,
    String? sortBy,
    String? sortOrder,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'per_page': perPage.toString(),
    };

    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }
    if (sortBy != null) {
      queryParams['sort_by'] = sortBy;
    }
    if (sortOrder != null) {
      queryParams['sort_order'] = sortOrder;
    }

    return await _apiService.get<PaginatedResponse<Category>>(
      ApiConfig.categories,
      queryParams: queryParams,
      fromJson: (json) => PaginatedResponse.fromJson(json, Category.fromJson),
    );
  }

  Future<ApiResponse<List<Category>>> getAllCategories() async {
    return await _apiService.get<List<Category>>(
      ApiConfig.categories,
      queryParams: {'per_page': '100'},
      fromJson: (json) {
        if (json is Map && json.containsKey('data')) {
          return (json['data'] as List)
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

  Future<ApiResponse<Category>> getCategoryById(String id) async {
    return await _apiService.get<Category>(
      ApiConfig.categoryById(id),
      fromJson: (json) => Category.fromJson(json),
    );
  }

  Future<ApiResponse<Category>> createCategory({
    required String name,
    String? description,
    String? icon,
  }) async {
    return await _apiService.post<Category>(
      ApiConfig.categories,
      body: {
        'name': name,
        'description': description,
        'icon': icon,
      },
      fromJson: (json) => Category.fromJson(json),
    );
  }

  Future<ApiResponse<Category>> updateCategory({
    required String id,
    String? name,
    String? description,
    String? icon,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (description != null) body['description'] = description;
    if (icon != null) body['icon'] = icon;

    return await _apiService.put<Category>(
      ApiConfig.categoryById(id),
      body: body,
      fromJson: (json) => Category.fromJson(json),
    );
  }

  Future<ApiResponse<void>> deleteCategory(String id) async {
    return await _apiService.delete<void>(
      ApiConfig.categoryById(id),
    );
  }
}
