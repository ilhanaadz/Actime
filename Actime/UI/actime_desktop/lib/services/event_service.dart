import '../config/api_config.dart';
import '../models/models.dart';
import 'api_service.dart';

class EventService {
  static final EventService _instance = EventService._internal();
  factory EventService() => _instance;
  EventService._internal();

  final ApiService _apiService = ApiService();

  Future<ApiResponse<PaginatedResponse<Event>>> getEvents({
    int page = 1,
    int perPage = 10,
    String? search,
    String? sortBy,
    String? sortOrder,
    String? status,
    String? organizationId,
    String? categoryId,
    DateTime? startDate,
    DateTime? endDate,
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
    if (status != null) {
      queryParams['status'] = status;
    }
    if (organizationId != null) {
      queryParams['organization_id'] = organizationId;
    }
    if (categoryId != null) {
      queryParams['category_id'] = categoryId;
    }
    if (startDate != null) {
      queryParams['start_date'] = startDate.toIso8601String().split('T')[0];
    }
    if (endDate != null) {
      queryParams['end_date'] = endDate.toIso8601String().split('T')[0];
    }

    return await _apiService.get<PaginatedResponse<Event>>(
      ApiConfig.events,
      queryParams: queryParams,
      fromJson: (json) => PaginatedResponse.fromJson(json, Event.fromJson),
    );
  }

  Future<ApiResponse<Event>> getEventById(String id) async {
    return await _apiService.get<Event>(
      ApiConfig.eventById(id),
      fromJson: (json) => Event.fromJson(json),
    );
  }

  Future<ApiResponse<Event>> createEvent({
    required String name,
    String? description,
    String? location,
    DateTime? startDate,
    DateTime? endDate,
    int? maxParticipants,
    String? organizationId,
    String? categoryId,
  }) async {
    return await _apiService.post<Event>(
      ApiConfig.events,
      body: {
        'name': name,
        'description': description,
        'location': location,
        'start_date': startDate?.toIso8601String(),
        'end_date': endDate?.toIso8601String(),
        'max_participants': maxParticipants,
        'organization_id': organizationId,
        'category_id': categoryId,
      },
      fromJson: (json) => Event.fromJson(json),
    );
  }

  Future<ApiResponse<Event>> updateEvent({
    required String id,
    String? name,
    String? description,
    String? location,
    DateTime? startDate,
    DateTime? endDate,
    int? maxParticipants,
    String? status,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (description != null) body['description'] = description;
    if (location != null) body['location'] = location;
    if (startDate != null) body['start_date'] = startDate.toIso8601String();
    if (endDate != null) body['end_date'] = endDate.toIso8601String();
    if (maxParticipants != null) body['max_participants'] = maxParticipants;
    if (status != null) body['status'] = status;

    return await _apiService.put<Event>(
      ApiConfig.eventById(id),
      body: body,
      fromJson: (json) => Event.fromJson(json),
    );
  }

  Future<ApiResponse<void>> deleteEvent(String id) async {
    return await _apiService.delete<void>(
      ApiConfig.eventById(id),
    );
  }
}
