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
    User(id: 1, username: 'furkancurek', email: 'furkancurek@outlook.com', firstName: 'Furkan', lastName: 'Cürek', createdAt: DateTime.now()),
    User(id: 2, username: 'sisicarmin', email: 'sisicarmin@gmail.com', firstName: 'Armin', lastName: 'Šišić', createdAt: DateTime.now()),
    User(id: 3, username: 'kenanalic', email: 'kenanalic@gmail.com', firstName: 'Kenan', lastName: 'Alić', createdAt: DateTime.now()),
    User(id: 4, username: 'aminah', email: 'aminah@gmail.com', firstName: 'Amina', lastName: 'Hadžić', createdAt: DateTime.now()),
    User(id: 5, username: 'emirk', email: 'emirk@outlook.com', firstName: 'Emir', lastName: 'Kovačević', createdAt: DateTime.now()),
    User(id: 6, username: 'lamijab', email: 'lamijab@gmail.com', firstName: 'Lamija', lastName: 'Bašić', createdAt: DateTime.now()),
    User(id: 7, username: 'tarikm', email: 'tarikm@gmail.com', firstName: 'Tarik', lastName: 'Mujić', createdAt: DateTime.now()),
    User(id: 8, username: 'sarad', email: 'sarad@outlook.com', firstName: 'Sara', lastName: 'Delić', createdAt: DateTime.now()),
    User(id: 9, username: 'harisi', email: 'harisi@gmail.com', firstName: 'Haris', lastName: 'Imamović', createdAt: DateTime.now()),
    User(id: 10, username: 'lejlah', email: 'lejlah@gmail.com', firstName: 'Lejla', lastName: 'Hodžić', createdAt: DateTime.now()),
    User(id: 11, username: 'adnanb', email: 'adnanb@outlook.com', firstName: 'Adnan', lastName: 'Begović', createdAt: DateTime.now()),
    User(id: 12, username: 'nejras', email: 'nejras@gmail.com', firstName: 'Nejra', lastName: 'Salihović', createdAt: DateTime.now()),
  ];

  // Mock Organizations
  final List<Organization> _mockOrganizations = [
    Organization(
      id: 1,
      name: 'Student Volleyball Club',
      email: 'club@volleyball.com',
      description: 'Volleyball is a team sport in which two teams of six players are separated by a net.',
      phoneNumber: '+387 61 234 567',
      userId: 1,
      categoryId: 1,
      addressId: 1,
      createdAt: DateTime.now(),
    ),
    Organization(
      id: 2,
      name: 'Hiking Adventures BiH',
      email: 'info@hikingbih.com',
      description: 'We organize hiking trips across Bosnia and Herzegovina.',
      phoneNumber: '+387 62 345 678',
      userId: 2,
      categoryId: 3,
      addressId: 2,
      createdAt: DateTime.now(),
    ),
    Organization(
      id: 3,
      name: 'Tech Meetup Sarajevo',
      email: 'hello@techmeetup.ba',
      description: 'A community of tech enthusiasts, developers, and entrepreneurs.',
      phoneNumber: '+387 63 456 789',
      userId: 3,
      categoryId: 4,
      addressId: 3,
      createdAt: DateTime.now(),
    ),
    Organization(
      id: 4,
      name: 'Basketball Academy',
      email: 'academy@basketball.ba',
      description: 'Professional basketball training for all ages.',
      phoneNumber: '+387 61 567 890',
      userId: 4,
      categoryId: 5,
      addressId: 4,
      createdAt: DateTime.now(),
    ),
    Organization(
      id: 5,
      name: 'Art & Culture Society',
      email: 'contact@artculture.ba',
      description: 'Promoting arts and culture through exhibitions and workshops.',
      phoneNumber: '+387 62 678 901',
      userId: 5,
      categoryId: 6,
      addressId: 5,
      createdAt: DateTime.now(),
    ),
  ];

  // Mock Events
  final List<Event> _mockEvents = [
    Event(
      id: 1,
      organizationId: 2,
      title: 'Bjelašnica hiking trip',
      description: 'Come join us on a hiking trip to Bjelašnica mountain.',
      start: DateTime.now().add(const Duration(days: 7)),
      end: DateTime.now().add(const Duration(days: 7, hours: 6)),
      locationId: 1,
      maxParticipants: 60,
      isFree: true,
      price: 0,
      eventStatusId: 1,
      activityTypeId: 1,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    Event(
      id: 2,
      organizationId: 1,
      title: 'Volleyball tournament',
      description: 'Annual volleyball tournament.',
      start: DateTime.now().add(const Duration(days: 14)),
      end: DateTime.now().add(const Duration(days: 14, hours: 8)),
      locationId: 2,
      maxParticipants: 150,
      isFree: false,
      price: 20,
      eventStatusId: 1,
      activityTypeId: 2,
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
    Event(
      id: 3,
      organizationId: 3,
      title: 'Tech Talk: Flutter Development',
      description: 'Learn about modern mobile development with Flutter.',
      start: DateTime.now().subtract(const Duration(days: 2)),
      end: DateTime.now().subtract(const Duration(days: 2)).add(const Duration(hours: 3)),
      locationId: 3,
      maxParticipants: 80,
      isFree: true,
      price: 0,
      eventStatusId: 3,
      activityTypeId: 3,
      createdAt: DateTime.now().subtract(const Duration(days: 14)),
    ),
    Event(
      id: 4,
      organizationId: 4,
      title: 'Basketball training session',
      description: 'Weekly training session for intermediate players.',
      start: DateTime.now(),
      end: DateTime.now().add(const Duration(hours: 2)),
      locationId: 4,
      maxParticipants: 30,
      isFree: true,
      price: 0,
      eventStatusId: 2,
      activityTypeId: 2,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Event(
      id: 5,
      organizationId: 5,
      title: 'Art Exhibition Opening',
      description: 'Opening night of our new exhibition featuring local artists.',
      start: DateTime.now().add(const Duration(days: 21)),
      end: DateTime.now().add(const Duration(days: 21, hours: 4)),
      locationId: 5,
      maxParticipants: 100,
      isFree: true,
      price: 0,
      eventStatusId: 1,
      activityTypeId: 4,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    Event(
      id: 6,
      organizationId: 2,
      title: 'Jahorina ski trip',
      description: 'Weekend ski trip to Jahorina. All skill levels welcome.',
      start: DateTime.now().add(const Duration(days: 30)),
      end: DateTime.now().add(const Duration(days: 32)),
      locationId: 6,
      maxParticipants: 50,
      isFree: false,
      price: 150,
      eventStatusId: 1,
      activityTypeId: 1,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  // Mock Categories
  final List<Category> _mockCategories = [
    Category(id: 1, name: 'Sports', description: 'Sports activities and clubs'),
    Category(id: 2, name: 'Volleyball', description: 'Volleyball clubs and events'),
    Category(id: 3, name: 'Hiking', description: 'Hiking and outdoor activities'),
    Category(id: 4, name: 'Technology', description: 'Tech meetups and workshops'),
    Category(id: 5, name: 'Basketball', description: 'Basketball clubs and training'),
    Category(id: 6, name: 'Art & Culture', description: 'Art exhibitions and cultural events'),
    Category(id: 7, name: 'Music', description: 'Music events and concerts'),
    Category(id: 8, name: 'Education', description: 'Educational workshops and seminars'),
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
            id: 0,
            username: 'admin',
            email: email,
            firstName: 'Admin',
            lastName: 'User',
            createdAt: DateTime.now(),
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
    int pageSize = 10,
    String? search,
    String? sortBy,
  }) async {
    await _simulateDelay();

    var users = List<User>.from(_mockUsers);

    // Filter by search
    if (search != null && search.isNotEmpty) {
      users = users.where((u) =>
        u.fullName.toLowerCase().contains(search.toLowerCase()) ||
        u.email.toLowerCase().contains(search.toLowerCase())
      ).toList();
    }

    // Sort
    if (sortBy != null) {
      switch (sortBy) {
        case 'name':
          users.sort((a, b) => a.fullName.compareTo(b.fullName));
          break;
        case 'email':
          users.sort((a, b) => a.email.compareTo(b.email));
          break;
      }
    }

    // Paginate
    final total = users.length;
    final totalPages = (total / pageSize).ceil();
    final start = (page - 1) * pageSize;
    final end = start + pageSize > total ? total : start + pageSize;
    final paginatedUsers = start < total ? users.sublist(start, end) : <User>[];

    return ApiResponse(
      success: true,
      data: PaginatedResponse(
        items: paginatedUsers,
        totalCount: total,
        page: page,
        pageSize: pageSize,
      ),
      statusCode: 200,
    );
  }

  Future<ApiResponse<User>> getUserById(int id) async {
    await _simulateDelay();

    final user = _mockUsers.firstWhere(
      (u) => u.id == id,
      orElse: () => _mockUsers.first,
    );

    return ApiResponse(success: true, data: user, statusCode: 200);
  }

  Future<ApiResponse<void>> deleteUser(int id) async {
    await _simulateDelay();
    _mockUsers.removeWhere((u) => u.id == id);
    return ApiResponse(success: true, statusCode: 204);
  }

  // ORGANIZATIONS
  Future<ApiResponse<PaginatedResponse<Organization>>> getOrganizations({
    int page = 1,
    int pageSize = 10,
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
      }
    }

    final total = orgs.length;
    final start = (page - 1) * pageSize;
    final end = start + pageSize > total ? total : start + pageSize;
    final paginatedOrgs = start < total ? orgs.sublist(start, end) : <Organization>[];

    return ApiResponse(
      success: true,
      data: PaginatedResponse(
        items: paginatedOrgs,
        totalCount: total,
        page: page,
        pageSize: pageSize,
      ),
      statusCode: 200,
    );
  }

  Future<ApiResponse<Organization>> getOrganizationById(int id) async {
    await _simulateDelay();

    final org = _mockOrganizations.firstWhere(
      (o) => o.id == id,
      orElse: () => _mockOrganizations.first,
    );

    return ApiResponse(success: true, data: org, statusCode: 200);
  }

  Future<ApiResponse<void>> deleteOrganization(int id) async {
    await _simulateDelay();
    _mockOrganizations.removeWhere((o) => o.id == id);
    return ApiResponse(success: true, statusCode: 204);
  }

  // EVENTS
  Future<ApiResponse<PaginatedResponse<Event>>> getEvents({
    int page = 1,
    int pageSize = 10,
    String? search,
    String? sortBy,
    int? eventStatusId,
    DateTime? startDate,
  }) async {
    await _simulateDelay();

    var events = List<Event>.from(_mockEvents);

    if (search != null && search.isNotEmpty) {
      events = events.where((e) =>
        e.title.toLowerCase().contains(search.toLowerCase())
      ).toList();
    }

    if (eventStatusId != null) {
      events = events.where((e) => e.eventStatusId == eventStatusId).toList();
    }

    if (sortBy != null) {
      switch (sortBy) {
        case 'title':
          events.sort((a, b) => a.title.compareTo(b.title));
          break;
        case 'start':
          events.sort((a, b) => a.start.compareTo(b.start));
          break;
      }
    }

    final total = events.length;
    final start = (page - 1) * pageSize;
    final end = start + pageSize > total ? total : start + pageSize;
    final paginatedEvents = start < total ? events.sublist(start, end) : <Event>[];

    return ApiResponse(
      success: true,
      data: PaginatedResponse(
        items: paginatedEvents,
        totalCount: total,
        page: page,
        pageSize: pageSize,
      ),
      statusCode: 200,
    );
  }

  Future<ApiResponse<Event>> getEventById(int id) async {
    await _simulateDelay();

    final event = _mockEvents.firstWhere(
      (e) => e.id == id,
      orElse: () => _mockEvents.first,
    );

    return ApiResponse(success: true, data: event, statusCode: 200);
  }

  Future<ApiResponse<void>> deleteEvent(int id) async {
    await _simulateDelay();
    _mockEvents.removeWhere((e) => e.id == id);
    return ApiResponse(success: true, statusCode: 204);
  }

  // CATEGORIES
  Future<ApiResponse<PaginatedResponse<Category>>> getCategories({
    int page = 1,
    int pageSize = 10,
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
      }
    }

    final total = categories.length;
    final start = (page - 1) * pageSize;
    final end = start + pageSize > total ? total : start + pageSize;
    final paginatedCategories = start < total ? categories.sublist(start, end) : <Category>[];

    return ApiResponse(
      success: true,
      data: PaginatedResponse(
        items: paginatedCategories,
        totalCount: total,
        page: page,
        pageSize: pageSize,
      ),
      statusCode: 200,
    );
  }

  Future<ApiResponse<Category>> getCategoryById(int id) async {
    await _simulateDelay();

    final category = _mockCategories.firstWhere(
      (c) => c.id == id,
      orElse: () => _mockCategories.first,
    );

    return ApiResponse(success: true, data: category, statusCode: 200);
  }

  Future<ApiResponse<Category>> createCategory(String name, String? description) async {
    await _simulateDelay();

    final newCategory = Category(
      id: _mockCategories.length + 1,
      name: name,
      description: description,
    );
    _mockCategories.add(newCategory);

    return ApiResponse(success: true, data: newCategory, statusCode: 201);
  }

  Future<ApiResponse<Category>> updateCategory(int id, String name, String? description) async {
    await _simulateDelay();

    final index = _mockCategories.indexWhere((c) => c.id == id);
    if (index != -1) {
      _mockCategories[index] = _mockCategories[index].copyWith(
        name: name,
        description: description,
      );
      return ApiResponse(success: true, data: _mockCategories[index], statusCode: 200);
    }

    return ApiResponse(success: false, message: 'Category not found', statusCode: 404);
  }

  Future<ApiResponse<void>> deleteCategory(int id) async {
    await _simulateDelay();
    _mockCategories.removeWhere((c) => c.id == id);
    return ApiResponse(success: true, statusCode: 204);
  }
}
