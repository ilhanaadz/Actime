import '../config/api_config.dart';
import '../models/models.dart';
import 'api_service.dart';
import 'mock_api_service.dart';

/// Event service
class EventService {
  static final EventService _instance = EventService._internal();
  factory EventService() => _instance;
  EventService._internal();

  final ApiService _apiService = ApiService();
  final MockApiService _mockService = MockApiService();

  /// Get events (paginated)
  Future<ApiResponse<PaginatedResponse<Event>>> getEvents({
    int page = 1,
    int perPage = 10,
    String? search,
    String? categoryId,
    String? organizationId,
    EventStatus? status,
    String? sortBy,
    bool? featured,
  }) async {
    if (ApiConfig.useMockApi) {
      return await _mockService.getEvents(
        page: page,
        perPage: perPage,
        search: search,
        categoryId: categoryId,
        organizationId: organizationId,
        status: status,
        sortBy: sortBy,
        featured: featured,
      );
    }

    return await _apiService.get<PaginatedResponse<Event>>(
      ApiConfig.events,
      queryParams: {
        'page': page.toString(),
        'perPage': perPage.toString(),
        if (search != null) 'search': search,
        if (categoryId != null) 'categoryId': categoryId,
        if (organizationId != null) 'organizationId': organizationId,
        if (status != null) 'status': status.value,
        if (sortBy != null) 'sortBy': sortBy,
        if (featured != null) 'featured': featured.toString(),
      },
      fromJson: (json) => PaginatedResponse.fromJson(json, Event.fromJson),
    );
  }

  /// Get event by ID
  Future<ApiResponse<Event>> getEventById(String id) async {
    if (ApiConfig.useMockApi) {
      return await _mockService.getEventById(id);
    }

    return await _apiService.get<Event>(
      ApiConfig.eventById(id),
      fromJson: (json) => Event.fromJson(json),
    );
  }

  /// Get featured events
  Future<ApiResponse<PaginatedResponse<Event>>> getFeaturedEvents({
    int page = 1,
    int perPage = 5,
  }) async {
    return await getEvents(
      page: page,
      perPage: perPage,
      featured: true,
      status: EventStatus.upcoming,
    );
  }

  /// Get upcoming events
  Future<ApiResponse<PaginatedResponse<Event>>> getUpcomingEvents({
    int page = 1,
    int perPage = 10,
    String? categoryId,
  }) async {
    return await getEvents(
      page: page,
      perPage: perPage,
      status: EventStatus.upcoming,
      categoryId: categoryId,
      sortBy: 'startDate',
    );
  }

  /// Create event
  Future<ApiResponse<Event>> createEvent(Map<String, dynamic> data) async {
    if (ApiConfig.useMockApi) {
      return await _mockService.createEvent(data);
    }

    return await _apiService.post<Event>(
      ApiConfig.events,
      body: data,
      fromJson: (json) => Event.fromJson(json),
    );
  }

  /// Update event
  Future<ApiResponse<Event>> updateEvent(String id, Map<String, dynamic> data) async {
    if (ApiConfig.useMockApi) {
      return await _mockService.updateEvent(id, data);
    }

    return await _apiService.put<Event>(
      ApiConfig.eventById(id),
      body: data,
      fromJson: (json) => Event.fromJson(json),
    );
  }

  /// Delete event
  Future<ApiResponse<void>> deleteEvent(String id) async {
    if (ApiConfig.useMockApi) {
      return await _mockService.deleteEvent(id);
    }

    return await _apiService.delete(ApiConfig.eventById(id));
  }

  /// Join event
  Future<ApiResponse<void>> joinEvent(String eventId) async {
    if (ApiConfig.useMockApi) {
      return await _mockService.joinEvent(eventId);
    }

    return await _apiService.post<void>(
      ApiConfig.joinEvent(eventId),
      fromJson: (_) {},
    );
  }

  /// Leave event
  Future<ApiResponse<void>> leaveEvent(String eventId) async {
    if (ApiConfig.useMockApi) {
      return await _mockService.leaveEvent(eventId);
    }

    return await _apiService.post<void>(
      ApiConfig.leaveEvent(eventId),
      fromJson: (_) {},
    );
  }

  /// Get event participants
  Future<ApiResponse<PaginatedResponse<Participant>>> getEventParticipants(
    String eventId, {
    int page = 1,
    int perPage = 10,
  }) async {
    if (ApiConfig.useMockApi) {
      return await _mockService.getEventParticipants(
        eventId,
        page: page,
        perPage: perPage,
      );
    }

    return await _apiService.get<PaginatedResponse<Participant>>(
      ApiConfig.eventParticipants(eventId),
      queryParams: {
        'page': page.toString(),
        'perPage': perPage.toString(),
      },
      fromJson: (json) => PaginatedResponse.fromJson(json, Participant.fromJson),
    );
  }

  /// Get organization events
  Future<ApiResponse<PaginatedResponse<Event>>> getOrganizationEvents(
    String organizationId, {
    int page = 1,
    int perPage = 10,
    EventStatus? status,
  }) async {
    return await getEvents(
      page: page,
      perPage: perPage,
      organizationId: organizationId,
      status: status,
    );
  }
}
