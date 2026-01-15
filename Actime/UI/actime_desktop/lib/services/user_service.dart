import '../config/api_config.dart';
import '../models/models.dart';
import 'api_service.dart';

class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  final ApiService _apiService = ApiService();

  Future<ApiResponse<PaginatedResponse<User>>> getUsers({
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

    return await _apiService.get<PaginatedResponse<User>>(
      ApiConfig.users,
      queryParams: queryParams,
      fromJson: (json) => PaginatedResponse.fromJson(json, User.fromJson),
    );
  }

  Future<ApiResponse<User>> getUserById(String id) async {
    return await _apiService.get<User>(
      ApiConfig.userById(id),
      fromJson: (json) => User.fromJson(json),
    );
  }

  Future<ApiResponse<User>> createUser({
    required String name,
    required String email,
    required String password,
  }) async {
    return await _apiService.post<User>(
      ApiConfig.users,
      body: {
        'name': name,
        'email': email,
        'password': password,
      },
      fromJson: (json) => User.fromJson(json),
    );
  }

  Future<ApiResponse<User>> updateUser({
    required String id,
    String? name,
    String? email,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (email != null) body['email'] = email;

    return await _apiService.put<User>(
      ApiConfig.userById(id),
      body: body,
      fromJson: (json) => User.fromJson(json),
    );
  }

  Future<ApiResponse<void>> deleteUser(String id) async {
    return await _apiService.delete<void>(
      ApiConfig.userById(id),
    );
  }
}
