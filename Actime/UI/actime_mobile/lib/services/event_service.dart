import '../config/api_config.dart';
import '../models/models.dart';
import 'api_service.dart';
import 'mock_api_service.dart';

/// Participant model for event participants
class Participant {
  final String id;
  final String eventId;
  final String userId;
  final String? userName;
  final String? userEmail;
  final String? userPhone;
  final String? userAvatar;
  final DateTime joinedAt;
  final bool isPaid;

  Participant({
    required this.id,
    required this.eventId,
    required this.userId,
    this.userName,
    this.userEmail,
    this.userPhone,
    this.userAvatar,
    required this.joinedAt,
    this.isPaid = false,
  });

  /// Get user object from participant data
  User get user => User(
    id: userId,
    name: userName ?? '',
    email: userEmail ?? '',
    phone: userPhone,
    profileImageUrl: userAvatar,
    createdAt: joinedAt,
  );

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      id: (json['Id'] ?? json['id'])?.toString() ?? '0',
      eventId: (json['EventId'] ?? json['eventId'])?.toString() ?? '0',
      userId: (json['UserId'] ?? json['userId'])?.toString() ?? '0',
      userName: json['UserName'] as String? ?? json['userName'] as String?,
      userEmail: json['UserEmail'] as String? ?? json['userEmail'] as String?,
      userPhone: json['UserPhone'] as String? ?? json['userPhone'] as String?,
      userAvatar: json['UserAvatar'] as String? ?? json['userAvatar'] as String?,
      joinedAt: DateTime.tryParse(json['JoinedAt']?.toString() ?? json['joinedAt']?.toString() ?? '') ?? DateTime.now(),
      isPaid: json['IsPaid'] as bool? ?? json['isPaid'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'EventId': eventId,
      'UserId': userId,
      'UserName': userName,
      'UserEmail': userEmail,
      'UserPhone': userPhone,
      'UserAvatar': userAvatar,
      'JoinedAt': joinedAt.toIso8601String(),
      'IsPaid': isPaid,
    };
  }
}

/// Event service
/// Communicates with backend EventController
class EventService {
  static final EventService _instance = EventService._internal();
  factory EventService() => _instance;
  EventService._internal();

  final ApiService _apiService = ApiService();
  final MockApiService _mockService = MockApiService();

  /// Get events (paginated)
  /// Backend uses TextSearchObject for filtering
  Future<ApiResponse<PaginatedResponse<Event>>> getEvents({
    int page = 1,
    int pageSize = 10,
    int? perPage,
    String? text,
    String? search,
    String? sortBy,
    bool sortDescending = false,
    bool includeTotalCount = true,
    EventStatus? status,
  }) async {
    final effectivePageSize = perPage ?? pageSize;
    final effectiveSearch = search ?? text;

    if (ApiConfig.useMockApi) {
      return await _mockService.getEvents(
        page: page,
        perPage: effectivePageSize,
        search: effectiveSearch,
        sortBy: sortBy,
      );
    }

    return await _apiService.get<PaginatedResponse<Event>>(
      ApiConfig.event,
      queryParams: {
        'Page': page.toString(),
        'PageSize': effectivePageSize.toString(),
        'IncludeTotalCount': includeTotalCount.toString(),
        if (effectiveSearch != null && effectiveSearch.isNotEmpty) 'Text': effectiveSearch,
        if (sortBy != null) 'SortBy': sortBy,
        if (status != null) 'Status': status.name,
        'SortDescending': sortDescending.toString(),
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
      '${ApiConfig.event}/$id',
      fromJson: (json) => Event.fromJson(json),
    );
  }

  /// Create event
  /// Request body: EventInsertRequest
  Future<ApiResponse<Event>> createEvent(Map<String, dynamic> data) async {
    if (ApiConfig.useMockApi) {
      return await _mockService.createEvent(data);
    }

    return await _apiService.post<Event>(
      ApiConfig.event,
      body: data,
      fromJson: (json) => Event.fromJson(json),
    );
  }

  /// Update event
  /// Request body: EventUpdateRequest (all fields optional)
  Future<ApiResponse<Event>> updateEvent(String id, Map<String, dynamic> data) async {
    if (ApiConfig.useMockApi) {
      return await _mockService.updateEvent(id, data);
    }

    return await _apiService.put<Event>(
      '${ApiConfig.event}/$id',
      body: data,
      fromJson: (json) => Event.fromJson(json),
    );
  }

  /// Delete event
  Future<ApiResponse<void>> deleteEvent(String id) async {
    if (ApiConfig.useMockApi) {
      return await _mockService.deleteEvent(id);
    }

    return await _apiService.delete('${ApiConfig.event}/$id');
  }

  /// Join event (participate)
  Future<ApiResponse<void>> joinEvent(String eventId) async {
    if (ApiConfig.useMockApi) {
      return ApiResponse.success(null, message: 'Uspješno ste se prijavili na događaj');
    }

    final response = await _apiService.post<Map<String, dynamic>>(
      ApiConfig.participation,
      body: {'EventId': eventId},
      fromJson: (json) => json,
    );

    if (response.success) {
      return ApiResponse.success(null, message: 'Uspješno ste se prijavili na događaj');
    }
    return ApiResponse.error(response.message ?? 'Greška pri prijavi');
  }

  /// Leave event (cancel participation)
  Future<ApiResponse<void>> leaveEvent(String eventId) async {
    if (ApiConfig.useMockApi) {
      return ApiResponse.success(null, message: 'Uspješno ste se odjavili sa događaja');
    }

    return await _apiService.delete('${ApiConfig.participation}/event/$eventId');
  }

  /// Get organization events
  Future<ApiResponse<PaginatedResponse<Event>>> getOrganizationEvents(
    String organizationId, {
    int page = 1,
    int perPage = 10,
  }) async {
    if (ApiConfig.useMockApi) {
      // Filter mock events by organization ID
      final allEventsResponse = await _mockService.getEvents(page: page, perPage: perPage);
      if (allEventsResponse.success && allEventsResponse.data != null) {
        final filteredItems = allEventsResponse.data!.items
            .where((e) => e.organizationId == organizationId)
            .toList();
        return ApiResponse.success(PaginatedResponse<Event>(
          items: filteredItems,
          totalCount: filteredItems.length,
          page: page,
          pageSize: perPage,
        ));
      }
      return allEventsResponse;
    }

    return await _apiService.get<PaginatedResponse<Event>>(
      '${ApiConfig.event}/organization/$organizationId',
      queryParams: {
        'page': page.toString(),
        'perPage': perPage.toString(),
      },
      fromJson: (json) => PaginatedResponse.fromJson(json, Event.fromJson),
    );
  }

  /// Get event participants
  Future<ApiResponse<PaginatedResponse<Participant>>> getEventParticipants(
    String eventId, {
    int page = 1,
    int perPage = 10,
  }) async {
    if (ApiConfig.useMockApi) {
      // Return mock participants
      return ApiResponse.success(PaginatedResponse<Participant>(
        items: [],
        totalCount: 0,
        page: page,
        pageSize: perPage,
      ));
    }

    return await _apiService.get<PaginatedResponse<Participant>>(
      '${ApiConfig.participation}/event/$eventId',
      queryParams: {
        'page': page.toString(),
        'perPage': perPage.toString(),
      },
      fromJson: (json) => PaginatedResponse.fromJson(json, Participant.fromJson),
    );
  }
}
