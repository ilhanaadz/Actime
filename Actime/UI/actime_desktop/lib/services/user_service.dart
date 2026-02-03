import '../config/api_config.dart';
import '../models/models.dart';
import 'api_service.dart';
import 'mock_api_service.dart';

class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  final ApiService _apiService = ApiService();
  final MockApiService _mockService = MockApiService();

  Future<ApiResponse<PaginatedResponse<User>>> getUsers({
    int page = 1,
    int pageSize = 10,
    int? perPage,
    String? search,
    String? sortBy,
    String? sortOrder,
  }) async {
    // Use perPage if provided, otherwise use pageSize
    final effectivePageSize = perPage ?? pageSize;

    if (ApiConfig.useMockApi) {
      return await _mockService.getUsers(
        page: page,
        pageSize: effectivePageSize,
        search: search,
        sortBy: sortBy,
      );
    }

    final queryParams = <String, String>{
      'Page': page.toString(),
      'PageSize': effectivePageSize.toString(),
      'IncludeTotalCount': 'true',
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

    return await _apiService.get<PaginatedResponse<User>>(
      ApiConfig.user,
      queryParams: queryParams,
      fromJson: (json) => PaginatedResponse.fromJson(json, User.fromJson),
    );
  }

  Future<ApiResponse<User>> getUserById(int id) async {
    if (ApiConfig.useMockApi) {
      return await _mockService.getUserById(id);
    }

    return await _apiService.get<User>(
      ApiConfig.userById(id),
      fromJson: (json) => User.fromJson(json),
    );
  }

  Future<ApiResponse<User>> createUser({
    required String username,
    required String email,
    required String password,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    DateTime? dateOfBirth,
  }) async {
    return await _apiService.post<User>(
      ApiConfig.user,
      body: {
        'Username': username,
        'Email': email,
        'Password': password,
        'FirstName': firstName,
        'LastName': lastName,
        'PhoneNumber': phoneNumber,
        'DateOfBirth': dateOfBirth?.toIso8601String(),
      },
      fromJson: (json) => User.fromJson(json),
    );
  }

  Future<ApiResponse<User>> updateUser({
    required int id,
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    String? profileImageUrl,
    DateTime? dateOfBirth,
  }) async {
    final body = <String, dynamic>{};
    if (firstName != null) body['FirstName'] = firstName;
    if (lastName != null) body['LastName'] = lastName;
    if (email != null) body['Email'] = email;
    if (phoneNumber != null) body['PhoneNumber'] = phoneNumber;
    if (profileImageUrl != null) body['ProfileImageUrl'] = profileImageUrl;
    if (dateOfBirth != null) body['DateOfBirth'] = dateOfBirth.toIso8601String();

    return await _apiService.put<User>(
      ApiConfig.userById(id),
      body: body,
      fromJson: (json) => User.fromJson(json),
    );
  }

  Future<ApiResponse<void>> deleteUser(int id) async {
    if (ApiConfig.useMockApi) {
      return await _mockService.deleteUser(id);
    }

    return await _apiService.delete<void>(
      ApiConfig.userById(id),
    );
  }
}
