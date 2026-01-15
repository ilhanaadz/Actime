import 'dart:math';
import '../models/models.dart';
import 'api_service.dart';
import 'dashboard_service.dart';

class MockApiService {
  static final MockApiService _instance = MockApiService._internal();
  factory MockApiService() => _instance;
  MockApiService._internal();

  final _random = Random();

  // Simulate network delay
  Future<void> _simulateDelay() async {
    await Future.delayed(Duration(milliseconds: 300 + _random.nextInt(500)));
  }

  // Mock Users
  final List<User> _mockUsers = [
    User(id: '1', name: 'Furkan Cürek', email: 'furkancurek@outlook.com', organizationsCount: 2),
    User(id: '2', name: 'Armin Šišić', email: 'sisicarmin@gmail.com', organizationsCount: 6),
    User(id: '3', name: 'Kenan Alić', email: 'kenanalic@gmail.com', organizationsCount: 3),
    User(id: '4', name: 'Amina Hadžić', email: 'aminah@gmail.com', organizationsCount: 1),
    User(id: '5', name: 'Emir Kovačević', email: 'emirk@outlook.com', organizationsCount: 4),
    User(id: '6', name: 'Lamija Bašić', email: 'lamijab@gmail.com', organizationsCount: 2),
    User(id: '7', name: 'Tarik Mujić', email: 'tarikm@gmail.com', organizationsCount: 5),
    User(id: '8', name: 'Sara Delić', email: 'sarad@outlook.com', organizationsCount: 1),
    User(id: '9', name: 'Haris Imamović', email: 'harisi@gmail.com', organizationsCount: 3),
    User(id: '10', name: 'Lejla Hodžić', email: 'lejlah@gmail.com', organizationsCount: 2),
    User(id: '11', name: 'Adnan Begović', email: 'adnanb@outlook.com', organizationsCount: 4),
    User(id: '12', name: 'Nejra Salihović', email: 'nejras@gmail.com', organizationsCount: 1),
  ];

  // Mock Organizations
  final List<Organization> _mockOrganizations = [
    Organization(
      id: '1',
      name: 'Student Volleyball Club',
      description: 'Volleyball is a team sport in which two teams of six players are separated by a net. Each team tries to score points by grounding a ball on the other team\'s court.',
      phone: '+387 61 234 567',
      address: '1894 Arlington Avenue, Sarajevo',
      email: 'club@volleyball.com',
      membersCount: 89,
      eventsCount: 13,
    ),
    Organization(
      id: '2',
      name: 'Hiking Adventures BiH',
      description: 'We organize hiking trips across Bosnia and Herzegovina. Join us for unforgettable experiences in nature.',
      phone: '+387 62 345 678',
      address: 'Ferhadija 15, Sarajevo',
      email: 'info@hikingbih.com',
      membersCount: 156,
      eventsCount: 24,
    ),
    Organization(
      id: '3',
      name: 'Tech Meetup Sarajevo',
      description: 'A community of tech enthusiasts, developers, and entrepreneurs sharing knowledge and building connections.',
      phone: '+387 63 456 789',
      address: 'Titova 7, Sarajevo',
      email: 'hello@techmeetup.ba',
      membersCount: 234,
      eventsCount: 18,
    ),
    Organization(
      id: '4',
      name: 'Basketball Academy',
      description: 'Professional basketball training for all ages. We develop skills and teamwork in a supportive environment.',
      phone: '+387 61 567 890',
      address: 'Zmaja od Bosne 8, Sarajevo',
      email: 'academy@basketball.ba',
      membersCount: 67,
      eventsCount: 8,
    ),
    Organization(
      id: '5',
      name: 'Art & Culture Society',
      description: 'Promoting arts and culture through exhibitions, workshops, and community events.',
      phone: '+387 62 678 901',
      address: 'Maršala Tita 23, Sarajevo',
      email: 'contact@artculture.ba',
      membersCount: 112,
      eventsCount: 31,
    ),
  ];

  // Mock Events
  final List<Event> _mockEvents = [
    Event(
      id: '1',
      name: 'Bjelašnica hiking trip',
      description: 'Come join us on a hiking trip to Bjelašnica mountain. We will meet at the parking lot at 8am and start our hike at 8:30am.',
      location: 'Bjelašnica',
      startDate: DateTime.now().add(const Duration(days: 7)),
      participantsCount: 45,
      maxParticipants: 60,
      status: EventStatus.upcoming,
      organizationName: 'Hiking Adventures BiH',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    Event(
      id: '2',
      name: 'Volleyball tournament',
      description: 'Annual volleyball tournament. Teams from all over Bosnia will compete for the championship.',
      location: 'Sports Hall Sarajevo',
      startDate: DateTime.now().add(const Duration(days: 14)),
      participantsCount: 120,
      maxParticipants: 150,
      status: EventStatus.upcoming,
      organizationName: 'Student Volleyball Club',
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
    Event(
      id: '3',
      name: 'Tech Talk: Flutter Development',
      description: 'Learn about modern mobile development with Flutter. Guest speaker from Google Developer Group.',
      location: 'Coworking Space, Sarajevo',
      startDate: DateTime.now().subtract(const Duration(days: 2)),
      participantsCount: 78,
      maxParticipants: 80,
      status: EventStatus.closed,
      organizationName: 'Tech Meetup Sarajevo',
      createdAt: DateTime.now().subtract(const Duration(days: 14)),
    ),
    Event(
      id: '4',
      name: 'Basketball training session',
      description: 'Weekly training session for intermediate players. Focus on defense techniques.',
      location: 'Basketball Academy Court',
      startDate: DateTime.now(),
      participantsCount: 24,
      maxParticipants: 30,
      status: EventStatus.active,
      organizationName: 'Basketball Academy',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Event(
      id: '5',
      name: 'Art Exhibition Opening',
      description: 'Opening night of our new exhibition featuring local artists. Wine and refreshments will be served.',
      location: 'Gallery Collegium Artisticum',
      startDate: DateTime.now().add(const Duration(days: 21)),
      participantsCount: 67,
      maxParticipants: 100,
      status: EventStatus.upcoming,
      organizationName: 'Art & Culture Society',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    Event(
      id: '6',
      name: 'Jahorina ski trip',
      description: 'Weekend ski trip to Jahorina. All skill levels welcome. Equipment rental available.',
      location: 'Jahorina',
      startDate: DateTime.now().add(const Duration(days: 30)),
      participantsCount: 32,
      maxParticipants: 50,
      status: EventStatus.upcoming,
      organizationName: 'Hiking Adventures BiH',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  // Mock Categories
  final List<Category> _mockCategories = [
    Category(id: '1', name: 'Sports', organizationsCount: 12),
    Category(id: '2', name: 'Volleyball', organizationsCount: 3),
    Category(id: '3', name: 'Hiking', organizationsCount: 5),
    Category(id: '4', name: 'Technology', organizationsCount: 8),
    Category(id: '5', name: 'Basketball', organizationsCount: 4),
    Category(id: '6', name: 'Art & Culture', organizationsCount: 7),
    Category(id: '7', name: 'Music', organizationsCount: 6),
    Category(id: '8', name: 'Education', organizationsCount: 9),
  ];

  // AUTH
  Future<ApiResponse<AuthResponse>> login(String email, String password) async {
    await _simulateDelay();

    // Accept any credentials for mock
    if (email.isNotEmpty && password.isNotEmpty) {
      return ApiResponse(
        success: true,
        data: AuthResponse(
          accessToken: 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
          refreshToken: 'mock_refresh_token',
          expiresAt: DateTime.now().add(const Duration(days: 7)),
          user: User(
            id: '0',
            name: 'Admin User',
            email: email,
            organizationsCount: 0,
          ),
        ),
        statusCode: 200,
      );
    }

    return ApiResponse(
      success: false,
      message: 'Invalid credentials',
      statusCode: 401,
    );
  }

  // DASHBOARD
  Future<ApiResponse<DashboardStats>> getDashboardStats() async {
    await _simulateDelay();

    return ApiResponse(
      success: true,
      data: DashboardStats(
        totalUsers: _mockUsers.length,
        totalOrganizations: _mockOrganizations.length,
        totalEvents: _mockEvents.length,
      ),
      statusCode: 200,
    );
  }

  Future<ApiResponse<List<UserGrowthData>>> getUserGrowth() async {
    await _simulateDelay();

    return ApiResponse(
      success: true,
      data: [
        UserGrowthData(month: 'Jan', count: 120),
        UserGrowthData(month: 'Feb', count: 150),
        UserGrowthData(month: 'Mar', count: 180),
        UserGrowthData(month: 'Apr', count: 220),
        UserGrowthData(month: 'May', count: 280),
        UserGrowthData(month: 'Jun', count: 350),
        UserGrowthData(month: 'Jul', count: 410),
        UserGrowthData(month: 'Aug', count: 480),
        UserGrowthData(month: 'Sep', count: 520),
        UserGrowthData(month: 'Oct', count: 590),
        UserGrowthData(month: 'Nov', count: 650),
        UserGrowthData(month: 'Dec', count: 720),
      ],
      statusCode: 200,
    );
  }

  // USERS
  Future<ApiResponse<PaginatedResponse<User>>> getUsers({
    int page = 1,
    int perPage = 10,
    String? search,
    String? sortBy,
  }) async {
    await _simulateDelay();

    var users = List<User>.from(_mockUsers);

    // Filter by search
    if (search != null && search.isNotEmpty) {
      users = users.where((u) =>
        u.name.toLowerCase().contains(search.toLowerCase()) ||
        u.email.toLowerCase().contains(search.toLowerCase())
      ).toList();
    }

    // Sort
    if (sortBy != null) {
      switch (sortBy) {
        case 'name':
          users.sort((a, b) => a.name.compareTo(b.name));
          break;
        case 'email':
          users.sort((a, b) => a.email.compareTo(b.email));
          break;
        case 'organizations_count':
          users.sort((a, b) => b.organizationsCount.compareTo(a.organizationsCount));
          break;
      }
    }

    // Paginate
    final total = users.length;
    final lastPage = (total / perPage).ceil();
    final start = (page - 1) * perPage;
    final end = start + perPage > total ? total : start + perPage;
    final paginatedUsers = users.sublist(start, end);

    return ApiResponse(
      success: true,
      data: PaginatedResponse(
        data: paginatedUsers,
        currentPage: page,
        lastPage: lastPage > 0 ? lastPage : 1,
        perPage: perPage,
        total: total,
      ),
      statusCode: 200,
    );
  }

  Future<ApiResponse<void>> deleteUser(String id) async {
    await _simulateDelay();
    _mockUsers.removeWhere((u) => u.id == id);
    return ApiResponse(success: true, statusCode: 204);
  }

  // ORGANIZATIONS
  Future<ApiResponse<PaginatedResponse<Organization>>> getOrganizations({
    int page = 1,
    int perPage = 10,
    String? search,
    String? sortBy,
  }) async {
    await _simulateDelay();

    var orgs = List<Organization>.from(_mockOrganizations);

    if (search != null && search.isNotEmpty) {
      orgs = orgs.where((o) =>
        o.name.toLowerCase().contains(search.toLowerCase())
      ).toList();
    }

    if (sortBy != null) {
      switch (sortBy) {
        case 'name':
          orgs.sort((a, b) => a.name.compareTo(b.name));
          break;
        case 'members_count':
          orgs.sort((a, b) => b.membersCount.compareTo(a.membersCount));
          break;
        case 'events_count':
          orgs.sort((a, b) => b.eventsCount.compareTo(a.eventsCount));
          break;
      }
    }

    final total = orgs.length;
    final lastPage = (total / perPage).ceil();
    final start = (page - 1) * perPage;
    final end = start + perPage > total ? total : start + perPage;
    final paginatedOrgs = start < total ? orgs.sublist(start, end) : <Organization>[];

    return ApiResponse(
      success: true,
      data: PaginatedResponse(
        data: paginatedOrgs,
        currentPage: page,
        lastPage: lastPage > 0 ? lastPage : 1,
        perPage: perPage,
        total: total,
      ),
      statusCode: 200,
    );
  }

  Future<ApiResponse<Organization>> getOrganizationById(String id) async {
    await _simulateDelay();

    final org = _mockOrganizations.firstWhere(
      (o) => o.id == id,
      orElse: () => _mockOrganizations.first,
    );

    return ApiResponse(success: true, data: org, statusCode: 200);
  }

  Future<ApiResponse<void>> deleteOrganization(String id) async {
    await _simulateDelay();
    _mockOrganizations.removeWhere((o) => o.id == id);
    return ApiResponse(success: true, statusCode: 204);
  }

  // EVENTS
  Future<ApiResponse<PaginatedResponse<Event>>> getEvents({
    int page = 1,
    int perPage = 10,
    String? search,
    String? sortBy,
    String? status,
    DateTime? startDate,
  }) async {
    await _simulateDelay();

    var events = List<Event>.from(_mockEvents);

    if (search != null && search.isNotEmpty) {
      events = events.where((e) =>
        e.name.toLowerCase().contains(search.toLowerCase())
      ).toList();
    }

    if (status != null) {
      events = events.where((e) => e.status.name == status).toList();
    }

    if (sortBy != null) {
      switch (sortBy) {
        case 'name':
          events.sort((a, b) => a.name.compareTo(b.name));
          break;
        case 'start_date':
          events.sort((a, b) => (a.startDate ?? DateTime.now()).compareTo(b.startDate ?? DateTime.now()));
          break;
        case 'participants_count':
          events.sort((a, b) => b.participantsCount.compareTo(a.participantsCount));
          break;
      }
    }

    final total = events.length;
    final lastPage = (total / perPage).ceil();
    final start = (page - 1) * perPage;
    final end = start + perPage > total ? total : start + perPage;
    final paginatedEvents = start < total ? events.sublist(start, end) : <Event>[];

    return ApiResponse(
      success: true,
      data: PaginatedResponse(
        data: paginatedEvents,
        currentPage: page,
        lastPage: lastPage > 0 ? lastPage : 1,
        perPage: perPage,
        total: total,
      ),
      statusCode: 200,
    );
  }

  Future<ApiResponse<void>> deleteEvent(String id) async {
    await _simulateDelay();
    _mockEvents.removeWhere((e) => e.id == id);
    return ApiResponse(success: true, statusCode: 204);
  }

  // CATEGORIES
  Future<ApiResponse<PaginatedResponse<Category>>> getCategories({
    int page = 1,
    int perPage = 10,
    String? search,
    String? sortBy,
  }) async {
    await _simulateDelay();

    var categories = List<Category>.from(_mockCategories);

    if (search != null && search.isNotEmpty) {
      categories = categories.where((c) =>
        c.name.toLowerCase().contains(search.toLowerCase())
      ).toList();
    }

    if (sortBy != null) {
      switch (sortBy) {
        case 'name':
          categories.sort((a, b) => a.name.compareTo(b.name));
          break;
        case 'organizations_count':
          categories.sort((a, b) => b.organizationsCount.compareTo(a.organizationsCount));
          break;
      }
    }

    final total = categories.length;
    final lastPage = (total / perPage).ceil();
    final start = (page - 1) * perPage;
    final end = start + perPage > total ? total : start + perPage;
    final paginatedCategories = start < total ? categories.sublist(start, end) : <Category>[];

    return ApiResponse(
      success: true,
      data: PaginatedResponse(
        data: paginatedCategories,
        currentPage: page,
        lastPage: lastPage > 0 ? lastPage : 1,
        perPage: perPage,
        total: total,
      ),
      statusCode: 200,
    );
  }

  Future<ApiResponse<Category>> createCategory(String name) async {
    await _simulateDelay();

    final newCategory = Category(
      id: '${_mockCategories.length + 1}',
      name: name,
      organizationsCount: 0,
    );
    _mockCategories.add(newCategory);

    return ApiResponse(success: true, data: newCategory, statusCode: 201);
  }

  Future<ApiResponse<Category>> updateCategory(String id, String name) async {
    await _simulateDelay();

    final index = _mockCategories.indexWhere((c) => c.id == id);
    if (index != -1) {
      _mockCategories[index] = _mockCategories[index].copyWith(name: name);
      return ApiResponse(success: true, data: _mockCategories[index], statusCode: 200);
    }

    return ApiResponse(success: false, message: 'Category not found', statusCode: 404);
  }

  Future<ApiResponse<void>> deleteCategory(String id) async {
    await _simulateDelay();
    _mockCategories.removeWhere((c) => c.id == id);
    return ApiResponse(success: true, statusCode: 204);
  }
}
