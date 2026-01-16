import 'dart:math';
import '../models/models.dart';

/// Mock API service for development and testing
/// Simulates API responses with realistic data
class MockApiService {
  static final MockApiService _instance = MockApiService._internal();
  factory MockApiService() => _instance;
  MockApiService._internal();

  final Random _random = Random();

  /// Simulate network delay
  Future<void> _simulateDelay() async {
    await Future.delayed(Duration(milliseconds: 300 + _random.nextInt(500)));
  }

  // ==================== MOCK DATA ====================

  /// Mock users
  final List<User> _mockUsers = [
    User(
      id: '1',
      name: 'Amar Hadžić',
      email: 'amar.hadzic@email.com',
      phone: '+387 61 123 456',
      bio: 'Ljubitelj sporta i outdoor aktivnosti',
      role: UserRole.user,
      organizationsCount: 3,
      eventsCount: 12,
      createdAt: DateTime.now().subtract(const Duration(days: 180)),
    ),
    User(
      id: '2',
      name: 'Emina Kovačević',
      email: 'emina.kovacevic@email.com',
      phone: '+387 62 234 567',
      bio: 'Organizatorica kulturnih događaja',
      role: UserRole.organizer,
      organizationsCount: 2,
      eventsCount: 25,
      createdAt: DateTime.now().subtract(const Duration(days: 365)),
    ),
    User(
      id: '3',
      name: 'Mirza Begović',
      email: 'mirza.begovic@email.com',
      phone: '+387 63 345 678',
      role: UserRole.user,
      organizationsCount: 5,
      eventsCount: 8,
      createdAt: DateTime.now().subtract(const Duration(days: 90)),
    ),
    User(
      id: '4',
      name: 'Lejla Mujić',
      email: 'lejla.mujic@email.com',
      phone: '+387 61 456 789',
      role: UserRole.user,
      organizationsCount: 2,
      eventsCount: 15,
      createdAt: DateTime.now().subtract(const Duration(days: 120)),
    ),
    User(
      id: '5',
      name: 'Dino Huseinović',
      email: 'dino.huseinovic@email.com',
      phone: '+387 62 567 890',
      role: UserRole.organizer,
      organizationsCount: 1,
      eventsCount: 30,
      createdAt: DateTime.now().subtract(const Duration(days: 200)),
    ),
    User(
      id: '6',
      name: 'Amra Salihović',
      email: 'amra.salihovic@email.com',
      role: UserRole.user,
      organizationsCount: 4,
      eventsCount: 6,
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
    ),
    User(
      id: '7',
      name: 'Kenan Mehmedović',
      email: 'kenan.mehmedovic@email.com',
      phone: '+387 63 678 901',
      role: UserRole.user,
      organizationsCount: 2,
      eventsCount: 10,
      createdAt: DateTime.now().subtract(const Duration(days: 150)),
    ),
    User(
      id: '8',
      name: 'Selma Karić',
      email: 'selma.karic@email.com',
      role: UserRole.user,
      organizationsCount: 3,
      eventsCount: 20,
      createdAt: DateTime.now().subtract(const Duration(days: 240)),
    ),
  ];

  /// Mock organizations (clubs)
  final List<Organization> _mockOrganizations = [
    Organization(
      id: '1',
      name: 'FK Sarajevo Mladi',
      description: 'Omladinski fudbalski klub za mlade talente. Treniramo 3 puta sedmično i učestvujemo u lokalnim ligama.',
      phone: '+387 33 123 456',
      email: 'fk.sarajevo.mladi@email.com',
      address: 'Sportska dvorana Skenderija, Sarajevo',
      website: 'www.fksarajevomladi.ba',
      categoryId: '1',
      categoryName: 'Sport',
      membersCount: 45,
      eventsCount: 12,
      isVerified: true,
      status: OrganizationStatus.active,
      createdAt: DateTime.now().subtract(const Duration(days: 730)),
    ),
    Organization(
      id: '2',
      name: 'Planinarsko društvo Bjelašnica',
      description: 'Organiziramo izlete, pohode i planinarenja na prekrasne bosanske planine.',
      phone: '+387 33 234 567',
      email: 'pd.bjel@email.com',
      address: 'Maršala Tita 50, Sarajevo',
      categoryId: '1',
      categoryName: 'Sport',
      membersCount: 120,
      eventsCount: 35,
      isVerified: true,
      status: OrganizationStatus.active,
      createdAt: DateTime.now().subtract(const Duration(days: 1095)),
    ),
    Organization(
      id: '3',
      name: 'Kulturni centar Mostar',
      description: 'Promovišemo kulturu i umjetnost kroz izložbe, koncerte i radionice.',
      phone: '+387 36 345 678',
      email: 'kc.mostar@email.com',
      address: 'Stari most 1, Mostar',
      categoryId: '2',
      categoryName: 'Kultura',
      membersCount: 80,
      eventsCount: 50,
      isVerified: true,
      status: OrganizationStatus.active,
      createdAt: DateTime.now().subtract(const Duration(days: 500)),
    ),
    Organization(
      id: '4',
      name: 'IT Hub Sarajevo',
      description: 'Zajednica programera i IT entuzijasta. Organizujemo meetupe, hackathone i radionice.',
      phone: '+387 33 456 789',
      email: 'info@ithub.ba',
      address: 'Hamdije Kreševljakovića 3, Sarajevo',
      website: 'www.ithub.ba',
      categoryId: '3',
      categoryName: 'Edukacija',
      membersCount: 250,
      eventsCount: 45,
      isVerified: true,
      status: OrganizationStatus.active,
      createdAt: DateTime.now().subtract(const Duration(days: 365)),
    ),
    Organization(
      id: '5',
      name: 'Yoga Studio Zen',
      description: 'Prakticiramo jogu i meditaciju u opuštenom okruženju. Časovi za sve nivoe.',
      phone: '+387 61 567 890',
      email: 'yoga.zen@email.com',
      address: 'Ferhadija 15, Sarajevo',
      categoryId: '4',
      categoryName: 'Zdravlje',
      membersCount: 60,
      eventsCount: 100,
      isVerified: false,
      status: OrganizationStatus.active,
      createdAt: DateTime.now().subtract(const Duration(days: 200)),
    ),
    Organization(
      id: '6',
      name: 'Foto klub Objektiv',
      description: 'Klub za ljubitelje fotografije. Organizujemo foto-ture i izložbe.',
      phone: '+387 33 678 901',
      email: 'foto.objektiv@email.com',
      address: 'Titova 10, Sarajevo',
      categoryId: '2',
      categoryName: 'Kultura',
      membersCount: 35,
      eventsCount: 20,
      isVerified: false,
      status: OrganizationStatus.active,
      createdAt: DateTime.now().subtract(const Duration(days: 150)),
    ),
  ];

  /// Mock events
  final List<Event> _mockEvents = [
    Event(
      id: '1',
      name: 'Trening - Fudbal za početnike',
      description: 'Besplatan trening za sve koji žele naučiti osnove fudbala. Donesi sportsku opremu!',
      location: 'Sportska dvorana Skenderija',
      address: 'Terezije bb, Sarajevo',
      startDate: DateTime.now().add(const Duration(days: 2)),
      endDate: DateTime.now().add(const Duration(days: 2, hours: 2)),
      price: 0,
      maxParticipants: 30,
      participantsCount: 18,
      organizationId: '1',
      organizationName: 'FK Sarajevo Mladi',
      categoryId: '1',
      categoryName: 'Sport',
      status: EventStatus.upcoming,
      isFeatured: true,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
    Event(
      id: '2',
      name: 'Planinarenje - Vrelo Bosne',
      description: 'Lagana šetnja do Vrela Bosne. Idealno za početnike i porodice.',
      location: 'Vrelo Bosne',
      address: 'Ilidža, Sarajevo',
      startDate: DateTime.now().add(const Duration(days: 5)),
      price: 10,
      currency: 'BAM',
      maxParticipants: 50,
      participantsCount: 32,
      organizationId: '2',
      organizationName: 'Planinarsko društvo Bjelašnica',
      categoryId: '1',
      categoryName: 'Sport',
      status: EventStatus.upcoming,
      isFeatured: true,
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
    Event(
      id: '3',
      name: 'Izložba - Sarajevski pejzaži',
      description: 'Izložba fotografija i slika sarajevskih pejzaža lokalnih umjetnika.',
      location: 'Kulturni centar Mostar',
      address: 'Stari most 1, Mostar',
      startDate: DateTime.now().add(const Duration(days: 10)),
      endDate: DateTime.now().add(const Duration(days: 17)),
      price: 5,
      currency: 'BAM',
      participantsCount: 45,
      organizationId: '3',
      organizationName: 'Kulturni centar Mostar',
      categoryId: '2',
      categoryName: 'Kultura',
      status: EventStatus.upcoming,
      createdAt: DateTime.now().subtract(const Duration(days: 14)),
    ),
    Event(
      id: '4',
      name: 'Flutter Meetup #15',
      description: 'Mjesečni meetup Flutter developera. Tema: State management sa Riverpod.',
      location: 'IT Hub Sarajevo',
      address: 'Hamdije Kreševljakovića 3, Sarajevo',
      startDate: DateTime.now().add(const Duration(days: 7)),
      endDate: DateTime.now().add(const Duration(days: 7, hours: 3)),
      price: 0,
      maxParticipants: 40,
      participantsCount: 28,
      organizationId: '4',
      organizationName: 'IT Hub Sarajevo',
      categoryId: '3',
      categoryName: 'Edukacija',
      status: EventStatus.upcoming,
      isFeatured: true,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    Event(
      id: '5',
      name: 'Yoga u parku',
      description: 'Besplatna yoga sesija na otvorenom. Donesi svoju prostirku!',
      location: 'Veliki park',
      address: 'Veliki park, Sarajevo',
      startDate: DateTime.now().add(const Duration(days: 3)),
      endDate: DateTime.now().add(const Duration(days: 3, hours: 1, minutes: 30)),
      price: 0,
      maxParticipants: 25,
      participantsCount: 20,
      organizationId: '5',
      organizationName: 'Yoga Studio Zen',
      categoryId: '4',
      categoryName: 'Zdravlje',
      status: EventStatus.upcoming,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    Event(
      id: '6',
      name: 'Foto-tura: Baščaršija',
      description: 'Fotografska šetnja kroz Baščaršiju. Savjeti za street fotografiju.',
      location: 'Baščaršija',
      address: 'Sebilj, Sarajevo',
      startDate: DateTime.now().add(const Duration(days: 12)),
      price: 15,
      currency: 'BAM',
      maxParticipants: 15,
      participantsCount: 8,
      organizationId: '6',
      organizationName: 'Foto klub Objektiv',
      categoryId: '2',
      categoryName: 'Kultura',
      status: EventStatus.upcoming,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Event(
      id: '7',
      name: 'Hackathon 2024',
      description: '24-satni hackathon. Tema: Aplikacije za održivi razvoj.',
      location: 'IT Hub Sarajevo',
      address: 'Hamdije Kreševljakovića 3, Sarajevo',
      startDate: DateTime.now().add(const Duration(days: 20)),
      endDate: DateTime.now().add(const Duration(days: 21)),
      price: 20,
      currency: 'BAM',
      maxParticipants: 100,
      participantsCount: 65,
      organizationId: '4',
      organizationName: 'IT Hub Sarajevo',
      categoryId: '3',
      categoryName: 'Edukacija',
      status: EventStatus.upcoming,
      isFeatured: true,
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
    ),
    Event(
      id: '8',
      name: 'Trening završen',
      description: 'Redovni fudbalski trening.',
      location: 'Sportska dvorana Skenderija',
      address: 'Terezije bb, Sarajevo',
      startDate: DateTime.now().subtract(const Duration(days: 5)),
      endDate: DateTime.now().subtract(const Duration(days: 5, hours: -2)),
      price: 0,
      participantsCount: 22,
      organizationId: '1',
      organizationName: 'FK Sarajevo Mladi',
      categoryId: '1',
      categoryName: 'Sport',
      status: EventStatus.completed,
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
    ),
  ];

  /// Mock categories
  final List<Category> _mockCategories = [
    Category(
      id: '1',
      name: 'Sport',
      description: 'Sportske aktivnosti i klubovi',
      icon: 'sports_soccer',
      color: '#4CAF50',
      organizationsCount: 12,
      eventsCount: 45,
      createdAt: DateTime.now().subtract(const Duration(days: 365)),
    ),
    Category(
      id: '2',
      name: 'Kultura',
      description: 'Kulturni događaji i umjetnost',
      icon: 'palette',
      color: '#9C27B0',
      organizationsCount: 8,
      eventsCount: 30,
      createdAt: DateTime.now().subtract(const Duration(days: 365)),
    ),
    Category(
      id: '3',
      name: 'Edukacija',
      description: 'Edukativni programi i radionice',
      icon: 'school',
      color: '#2196F3',
      organizationsCount: 15,
      eventsCount: 60,
      createdAt: DateTime.now().subtract(const Duration(days: 365)),
    ),
    Category(
      id: '4',
      name: 'Zdravlje',
      description: 'Zdravlje i wellness aktivnosti',
      icon: 'favorite',
      color: '#F44336',
      organizationsCount: 6,
      eventsCount: 25,
      createdAt: DateTime.now().subtract(const Duration(days: 365)),
    ),
    Category(
      id: '5',
      name: 'Muzika',
      description: 'Muzički događaji i koncerti',
      icon: 'music_note',
      color: '#FF9800',
      organizationsCount: 10,
      eventsCount: 35,
      createdAt: DateTime.now().subtract(const Duration(days: 365)),
    ),
    Category(
      id: '6',
      name: 'Tehnologija',
      description: 'Tech meetupi i konferencije',
      icon: 'computer',
      color: '#607D8B',
      organizationsCount: 5,
      eventsCount: 20,
      createdAt: DateTime.now().subtract(const Duration(days: 365)),
    ),
  ];

  /// Mock enrollments
  final List<Enrollment> _mockEnrollments = [
    Enrollment(
      id: '1',
      userId: '3',
      organizationId: '1',
      message: 'Želim se pridružiti klubu jer volim fudbal.',
      status: EnrollmentStatus.pending,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Enrollment(
      id: '2',
      userId: '4',
      organizationId: '1',
      message: 'Imam iskustva u fudbalu i želim trenirati.',
      status: EnrollmentStatus.pending,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Enrollment(
      id: '3',
      userId: '6',
      organizationId: '2',
      message: 'Volim planinarenje i želim se pridružiti.',
      status: EnrollmentStatus.approved,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      reviewedAt: DateTime.now().subtract(const Duration(days: 4)),
    ),
  ];

  /// Mock user memberships (approved enrollments for current user)
  List<Enrollment> get _mockUserMemberships => [
    Enrollment(
      id: 'm1',
      userId: '1',
      organizationId: '1',
      status: EnrollmentStatus.approved,
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
      reviewedAt: DateTime.now().subtract(const Duration(days: 59)),
    ),
    Enrollment(
      id: 'm2',
      userId: '1',
      organizationId: '5',
      status: EnrollmentStatus.approved,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      reviewedAt: DateTime.now().subtract(const Duration(days: 29)),
    ),
  ];

  // ==================== AUTH API ====================

  /// Login
  Future<ApiResponse<AuthResponse>> login(String email, String password) async {
    await _simulateDelay();

    // Find user by email
    final user = _mockUsers.firstWhere(
      (u) => u.email.toLowerCase() == email.toLowerCase(),
      orElse: () => _mockUsers.first,
    );

    // Simulate password check (any password works for mock)
    if (password.isEmpty) {
      return ApiResponse.error('Unesite lozinku', statusCode: 400);
    }

    final authResponse = AuthResponse(
      user: user,
      accessToken: 'mock_access_token_${user.id}_${DateTime.now().millisecondsSinceEpoch}',
      refreshToken: 'mock_refresh_token_${user.id}',
      expiresAt: DateTime.now().add(const Duration(days: 7)),
    );

    return ApiResponse.success(authResponse);
  }

  /// Register
  Future<ApiResponse<AuthResponse>> register(RegisterRequest request) async {
    await _simulateDelay();

    // Check if email already exists
    final exists = _mockUsers.any(
      (u) => u.email.toLowerCase() == request.email.toLowerCase(),
    );

    if (exists) {
      return ApiResponse.error('Email već postoji', statusCode: 400);
    }

    final newUser = User(
      id: '${_mockUsers.length + 1}',
      name: request.name,
      email: request.email,
      phone: request.phone,
      role: request.role,
      createdAt: DateTime.now(),
    );

    final authResponse = AuthResponse(
      user: newUser,
      accessToken: 'mock_access_token_${newUser.id}_${DateTime.now().millisecondsSinceEpoch}',
      refreshToken: 'mock_refresh_token_${newUser.id}',
      expiresAt: DateTime.now().add(const Duration(days: 7)),
    );

    return ApiResponse.success(authResponse);
  }

  // ==================== USER API ====================

  /// Get current user profile
  Future<ApiResponse<User>> getCurrentUser() async {
    await _simulateDelay();
    return ApiResponse.success(_mockUsers.first);
  }

  /// Get user by ID
  Future<ApiResponse<User>> getUserById(String id) async {
    await _simulateDelay();

    final user = _mockUsers.firstWhere(
      (u) => u.id == id,
      orElse: () => _mockUsers.first,
    );

    return ApiResponse.success(user);
  }

  /// Update user profile
  Future<ApiResponse<User>> updateUser(String id, Map<String, dynamic> data) async {
    await _simulateDelay();

    final index = _mockUsers.indexWhere((u) => u.id == id);
    if (index == -1) {
      return ApiResponse.error('Korisnik nije pronađen', statusCode: 404);
    }

    final updatedUser = _mockUsers[index].copyWith(
      name: data['name'] as String? ?? _mockUsers[index].name,
      phone: data['phone'] as String? ?? _mockUsers[index].phone,
      bio: data['bio'] as String? ?? _mockUsers[index].bio,
      address: data['address'] as String? ?? _mockUsers[index].address,
      updatedAt: DateTime.now(),
    );

    return ApiResponse.success(updatedUser);
  }

  /// Get users (paginated)
  Future<ApiResponse<PaginatedResponse<User>>> getUsers({
    int page = 1,
    int perPage = 10,
    String? search,
    String? sortBy,
  }) async {
    await _simulateDelay();

    var filteredUsers = List<User>.from(_mockUsers);

    // Apply search filter
    if (search != null && search.isNotEmpty) {
      final searchLower = search.toLowerCase();
      filteredUsers = filteredUsers
          .where((u) =>
              u.name.toLowerCase().contains(searchLower) ||
              u.email.toLowerCase().contains(searchLower))
          .toList();
    }

    // Apply sorting
    if (sortBy != null) {
      switch (sortBy) {
        case 'name':
          filteredUsers.sort((a, b) => a.name.compareTo(b.name));
          break;
        case 'email':
          filteredUsers.sort((a, b) => a.email.compareTo(b.email));
          break;
        case 'createdAt':
          filteredUsers.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          break;
      }
    }

    // Calculate pagination
    final total = filteredUsers.length;
    final lastPage = (total / perPage).ceil();
    final startIndex = (page - 1) * perPage;
    final endIndex = startIndex + perPage;

    final paginatedData = filteredUsers.sublist(
      startIndex.clamp(0, total),
      endIndex.clamp(0, total),
    );

    return ApiResponse.success(PaginatedResponse(
      data: paginatedData,
      currentPage: page,
      lastPage: lastPage == 0 ? 1 : lastPage,
      perPage: perPage,
      total: total,
    ));
  }

  // ==================== ORGANIZATION API ====================

  /// Get organizations (paginated)
  Future<ApiResponse<PaginatedResponse<Organization>>> getOrganizations({
    int page = 1,
    int perPage = 10,
    String? search,
    String? categoryId,
    String? sortBy,
  }) async {
    await _simulateDelay();

    var filteredOrgs = List<Organization>.from(_mockOrganizations);

    // Apply search filter
    if (search != null && search.isNotEmpty) {
      final searchLower = search.toLowerCase();
      filteredOrgs = filteredOrgs
          .where((o) =>
              o.name.toLowerCase().contains(searchLower) ||
              (o.description?.toLowerCase().contains(searchLower) ?? false))
          .toList();
    }

    // Apply category filter
    if (categoryId != null && categoryId.isNotEmpty) {
      filteredOrgs = filteredOrgs.where((o) => o.categoryId == categoryId).toList();
    }

    // Apply sorting
    if (sortBy != null) {
      switch (sortBy) {
        case 'name':
          filteredOrgs.sort((a, b) => a.name.compareTo(b.name));
          break;
        case 'membersCount':
          filteredOrgs.sort((a, b) => b.membersCount.compareTo(a.membersCount));
          break;
        case 'eventsCount':
          filteredOrgs.sort((a, b) => b.eventsCount.compareTo(a.eventsCount));
          break;
        case 'createdAt':
          filteredOrgs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          break;
      }
    }

    // Calculate pagination
    final total = filteredOrgs.length;
    final lastPage = (total / perPage).ceil();
    final startIndex = (page - 1) * perPage;
    final endIndex = startIndex + perPage;

    final paginatedData = filteredOrgs.sublist(
      startIndex.clamp(0, total),
      endIndex.clamp(0, total),
    );

    return ApiResponse.success(PaginatedResponse(
      data: paginatedData,
      currentPage: page,
      lastPage: lastPage == 0 ? 1 : lastPage,
      perPage: perPage,
      total: total,
    ));
  }

  /// Get organization by ID
  Future<ApiResponse<Organization>> getOrganizationById(String id) async {
    await _simulateDelay();

    final org = _mockOrganizations.firstWhere(
      (o) => o.id == id,
      orElse: () => _mockOrganizations.first,
    );

    return ApiResponse.success(org);
  }

  /// Get organization members
  Future<ApiResponse<PaginatedResponse<User>>> getOrganizationMembers(
    String organizationId, {
    int page = 1,
    int perPage = 10,
  }) async {
    await _simulateDelay();

    // Return subset of users as members
    final members = _mockUsers.take(5).toList();

    return ApiResponse.success(PaginatedResponse(
      data: members,
      currentPage: page,
      lastPage: 1,
      perPage: perPage,
      total: members.length,
    ));
  }

  /// Create organization
  Future<ApiResponse<Organization>> createOrganization(Map<String, dynamic> data) async {
    await _simulateDelay();

    final newOrg = Organization(
      id: '${_mockOrganizations.length + 1}',
      name: data['name'] as String,
      description: data['description'] as String?,
      phone: data['phone'] as String?,
      email: data['email'] as String?,
      address: data['address'] as String?,
      categoryId: data['categoryId'] as String?,
      createdAt: DateTime.now(),
    );

    return ApiResponse.success(newOrg);
  }

  /// Update organization
  Future<ApiResponse<Organization>> updateOrganization(
    String id,
    Map<String, dynamic> data,
  ) async {
    await _simulateDelay();

    final index = _mockOrganizations.indexWhere((o) => o.id == id);
    if (index == -1) {
      return ApiResponse.error('Organizacija nije pronađena', statusCode: 404);
    }

    final updatedOrg = _mockOrganizations[index].copyWith(
      name: data['name'] as String? ?? _mockOrganizations[index].name,
      description: data['description'] as String? ?? _mockOrganizations[index].description,
      phone: data['phone'] as String? ?? _mockOrganizations[index].phone,
      email: data['email'] as String? ?? _mockOrganizations[index].email,
      address: data['address'] as String? ?? _mockOrganizations[index].address,
      updatedAt: DateTime.now(),
    );

    return ApiResponse.success(updatedOrg);
  }

  // ==================== EVENT API ====================

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
    await _simulateDelay();

    var filteredEvents = List<Event>.from(_mockEvents);

    // Apply search filter
    if (search != null && search.isNotEmpty) {
      final searchLower = search.toLowerCase();
      filteredEvents = filteredEvents
          .where((e) =>
              e.name.toLowerCase().contains(searchLower) ||
              (e.description?.toLowerCase().contains(searchLower) ?? false) ||
              (e.location?.toLowerCase().contains(searchLower) ?? false))
          .toList();
    }

    // Apply category filter
    if (categoryId != null && categoryId.isNotEmpty) {
      filteredEvents = filteredEvents.where((e) => e.categoryId == categoryId).toList();
    }

    // Apply organization filter
    if (organizationId != null && organizationId.isNotEmpty) {
      filteredEvents = filteredEvents.where((e) => e.organizationId == organizationId).toList();
    }

    // Apply status filter
    if (status != null) {
      filteredEvents = filteredEvents.where((e) => e.status == status).toList();
    }

    // Apply featured filter
    if (featured == true) {
      filteredEvents = filteredEvents.where((e) => e.isFeatured).toList();
    }

    // Apply sorting
    switch (sortBy ?? 'startDate') {
      case 'name':
        filteredEvents.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'startDate':
        filteredEvents.sort((a, b) => a.startDate.compareTo(b.startDate));
        break;
      case 'participantsCount':
        filteredEvents.sort((a, b) => b.participantsCount.compareTo(a.participantsCount));
        break;
      case 'createdAt':
        filteredEvents.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }

    // Calculate pagination
    final total = filteredEvents.length;
    final lastPage = (total / perPage).ceil();
    final startIndex = (page - 1) * perPage;
    final endIndex = startIndex + perPage;

    final paginatedData = filteredEvents.sublist(
      startIndex.clamp(0, total),
      endIndex.clamp(0, total),
    );

    return ApiResponse.success(PaginatedResponse(
      data: paginatedData,
      currentPage: page,
      lastPage: lastPage == 0 ? 1 : lastPage,
      perPage: perPage,
      total: total,
    ));
  }

  /// Get event by ID
  Future<ApiResponse<Event>> getEventById(String id) async {
    await _simulateDelay();

    final event = _mockEvents.firstWhere(
      (e) => e.id == id,
      orElse: () => _mockEvents.first,
    );

    return ApiResponse.success(event);
  }

  /// Get user's events (registered events)
  Future<ApiResponse<PaginatedResponse<Event>>> getUserEvents(
    String userId, {
    int page = 1,
    int perPage = 10,
    EventStatus? status,
  }) async {
    await _simulateDelay();

    // Return upcoming events as user's events
    var userEvents = _mockEvents.where((e) => e.status == EventStatus.upcoming).toList();

    if (status != null) {
      userEvents = userEvents.where((e) => e.status == status).toList();
    }

    return ApiResponse.success(PaginatedResponse(
      data: userEvents.take(perPage).toList(),
      currentPage: page,
      lastPage: 1,
      perPage: perPage,
      total: userEvents.length,
    ));
  }

  /// Get user's event history
  Future<ApiResponse<PaginatedResponse<Event>>> getUserEventHistory(
    String userId, {
    int page = 1,
    int perPage = 10,
  }) async {
    await _simulateDelay();

    // Return completed events as history
    final historyEvents = _mockEvents.where((e) => e.status == EventStatus.completed).toList();

    return ApiResponse.success(PaginatedResponse(
      data: historyEvents.take(perPage).toList(),
      currentPage: page,
      lastPage: 1,
      perPage: perPage,
      total: historyEvents.length,
    ));
  }

  /// Create event
  Future<ApiResponse<Event>> createEvent(Map<String, dynamic> data) async {
    await _simulateDelay();

    final newEvent = Event(
      id: '${_mockEvents.length + 1}',
      name: data['name'] as String,
      description: data['description'] as String?,
      location: data['location'] as String?,
      address: data['address'] as String?,
      startDate: DateTime.parse(data['startDate'] as String),
      endDate: data['endDate'] != null ? DateTime.parse(data['endDate'] as String) : null,
      price: (data['price'] as num?)?.toDouble(),
      maxParticipants: data['maxParticipants'] as int?,
      organizationId: data['organizationId'] as String,
      organizationName: data['organizationName'] as String?,
      categoryId: data['categoryId'] as String?,
      status: EventStatus.upcoming,
      createdAt: DateTime.now(),
    );

    return ApiResponse.success(newEvent);
  }

  /// Update event
  Future<ApiResponse<Event>> updateEvent(String id, Map<String, dynamic> data) async {
    await _simulateDelay();

    final index = _mockEvents.indexWhere((e) => e.id == id);
    if (index == -1) {
      return ApiResponse.error('Događaj nije pronađen', statusCode: 404);
    }

    final updatedEvent = _mockEvents[index].copyWith(
      name: data['name'] as String? ?? _mockEvents[index].name,
      description: data['description'] as String? ?? _mockEvents[index].description,
      location: data['location'] as String? ?? _mockEvents[index].location,
      address: data['address'] as String? ?? _mockEvents[index].address,
      price: (data['price'] as num?)?.toDouble() ?? _mockEvents[index].price,
      maxParticipants: data['maxParticipants'] as int? ?? _mockEvents[index].maxParticipants,
      updatedAt: DateTime.now(),
    );

    return ApiResponse.success(updatedEvent);
  }

  /// Delete event
  Future<ApiResponse<void>> deleteEvent(String id) async {
    await _simulateDelay();
    return ApiResponse.success(null, message: 'Događaj je uspješno obrisan');
  }

  /// Join event
  Future<ApiResponse<void>> joinEvent(String eventId) async {
    await _simulateDelay();
    return ApiResponse.success(null, message: 'Uspješno ste se prijavili na događaj');
  }

  /// Leave event
  Future<ApiResponse<void>> leaveEvent(String eventId) async {
    await _simulateDelay();
    return ApiResponse.success(null, message: 'Uspješno ste se odjavili sa događaja');
  }

  /// Get event participants
  Future<ApiResponse<PaginatedResponse<Participant>>> getEventParticipants(
    String eventId, {
    int page = 1,
    int perPage = 10,
  }) async {
    await _simulateDelay();

    final participants = _mockUsers.take(5).map((user) {
      return Participant(
        id: 'p_${user.id}',
        userId: user.id,
        eventId: eventId,
        user: user,
        status: ParticipantStatus.registered,
        joinedAt: DateTime.now().subtract(Duration(days: _random.nextInt(7))),
      );
    }).toList();

    return ApiResponse.success(PaginatedResponse(
      data: participants,
      currentPage: page,
      lastPage: 1,
      perPage: perPage,
      total: participants.length,
    ));
  }

  // ==================== CATEGORY API ====================

  /// Get categories
  Future<ApiResponse<PaginatedResponse<Category>>> getCategories({
    int page = 1,
    int perPage = 20,
    String? search,
  }) async {
    await _simulateDelay();

    var filteredCategories = List<Category>.from(_mockCategories);

    if (search != null && search.isNotEmpty) {
      final searchLower = search.toLowerCase();
      filteredCategories = filteredCategories
          .where((c) => c.name.toLowerCase().contains(searchLower))
          .toList();
    }

    return ApiResponse.success(PaginatedResponse(
      data: filteredCategories,
      currentPage: page,
      lastPage: 1,
      perPage: perPage,
      total: filteredCategories.length,
    ));
  }

  /// Get category by ID
  Future<ApiResponse<Category>> getCategoryById(String id) async {
    await _simulateDelay();

    final category = _mockCategories.firstWhere(
      (c) => c.id == id,
      orElse: () => _mockCategories.first,
    );

    return ApiResponse.success(category);
  }

  // ==================== ENROLLMENT API ====================

  /// Get organization enrollments
  Future<ApiResponse<PaginatedResponse<Enrollment>>> getOrganizationEnrollments(
    String organizationId, {
    int page = 1,
    int perPage = 10,
    EnrollmentStatus? status,
  }) async {
    await _simulateDelay();

    var filteredEnrollments = _mockEnrollments
        .where((e) => e.organizationId == organizationId)
        .toList();

    if (status != null) {
      filteredEnrollments = filteredEnrollments.where((e) => e.status == status).toList();
    }

    // Add user data to enrollments
    final enrichedEnrollments = filteredEnrollments.map((enrollment) {
      final user = _mockUsers.firstWhere(
        (u) => u.id == enrollment.userId,
        orElse: () => _mockUsers.first,
      );
      return enrollment.copyWith(user: user);
    }).toList();

    return ApiResponse.success(PaginatedResponse(
      data: enrichedEnrollments,
      currentPage: page,
      lastPage: 1,
      perPage: perPage,
      total: enrichedEnrollments.length,
    ));
  }

  /// Create enrollment (apply to join organization)
  Future<ApiResponse<Enrollment>> createEnrollment({
    required String organizationId,
    String? message,
  }) async {
    await _simulateDelay();

    final enrollment = Enrollment(
      id: '${_mockEnrollments.length + 1}',
      userId: _mockUsers.first.id,
      organizationId: organizationId,
      message: message,
      status: EnrollmentStatus.pending,
      createdAt: DateTime.now(),
    );

    return ApiResponse.success(enrollment);
  }

  /// Approve enrollment
  Future<ApiResponse<Enrollment>> approveEnrollment(String id) async {
    await _simulateDelay();

    final index = _mockEnrollments.indexWhere((e) => e.id == id);
    if (index == -1) {
      return ApiResponse.error('Prijava nije pronađena', statusCode: 404);
    }

    final updatedEnrollment = _mockEnrollments[index].copyWith(
      status: EnrollmentStatus.approved,
      reviewedAt: DateTime.now(),
    );

    return ApiResponse.success(updatedEnrollment);
  }

  /// Get user memberships (approved enrollments with organization data)
  Future<ApiResponse<PaginatedResponse<Enrollment>>> getUserMemberships(
    String userId, {
    int page = 1,
    int perPage = 10,
  }) async {
    await _simulateDelay();

    // Get memberships and enrich with organization data
    final enrichedMemberships = _mockUserMemberships.map((membership) {
      final org = _mockOrganizations.firstWhere(
        (o) => o.id == membership.organizationId,
        orElse: () => _mockOrganizations.first,
      );
      return membership.copyWith(organization: org);
    }).toList();

    return ApiResponse.success(PaginatedResponse(
      data: enrichedMemberships,
      currentPage: page,
      lastPage: 1,
      perPage: perPage,
      total: enrichedMemberships.length,
    ));
  }

  /// Cancel membership
  Future<ApiResponse<void>> cancelMembership(String enrollmentId) async {
    await _simulateDelay();
    return ApiResponse.success(null, message: 'Članstvo je uspješno otkazano');
  }

  /// Reject enrollment
  Future<ApiResponse<Enrollment>> rejectEnrollment(String id, {String? reason}) async {
    await _simulateDelay();

    final index = _mockEnrollments.indexWhere((e) => e.id == id);
    if (index == -1) {
      return ApiResponse.error('Prijava nije pronađena', statusCode: 404);
    }

    final updatedEnrollment = _mockEnrollments[index].copyWith(
      status: EnrollmentStatus.rejected,
      reviewedAt: DateTime.now(),
      rejectionReason: reason,
    );

    return ApiResponse.success(updatedEnrollment);
  }
}
