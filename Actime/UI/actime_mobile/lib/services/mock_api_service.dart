import 'dart:math';
import '../models/models.dart';
import 'event_service.dart' show Participant;

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
      role: UserRole.organization,
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
      role: UserRole.organization,
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
      userId: 100,
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
      userId: 101,
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
      userId: 102,
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
      userId: 103,
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
      userId: 104,
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
      userId: 105,
    ),
  ];

  /// Mock events
  final List<Event> _mockEvents = [
    Event(
      id: '1',
      title: 'Trening - Fudbal za početnike',
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
      activityTypeId: 1,
      activityTypeName: 'Sport',
      status: EventStatus.upcoming,
      isFeatured: true,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
    Event(
      id: '2',
      title: 'Planinarenje - Vrelo Bosne',
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
      activityTypeId: 1,
      activityTypeName: 'Sport',
      status: EventStatus.upcoming,
      isFeatured: true,
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
    Event(
      id: '3',
      title: 'Izložba - Sarajevski pejzaži',
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
      activityTypeId: 2,
      activityTypeName: 'Kultura',
      status: EventStatus.upcoming,
      createdAt: DateTime.now().subtract(const Duration(days: 14)),
    ),
    Event(
      id: '4',
      title: 'Flutter Meetup #15',
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
      activityTypeId: 3,
      activityTypeName: 'Edukacija',
      status: EventStatus.upcoming,
      isFeatured: true,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    Event(
      id: '5',
      title: 'Yoga u parku',
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
      activityTypeId: 4,
      activityTypeName: 'Zdravlje',
      status: EventStatus.upcoming,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    Event(
      id: '6',
      title: 'Foto-tura: Baščaršija',
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
      activityTypeId: 2,
      activityTypeName: 'Kultura',
      status: EventStatus.upcoming,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Event(
      id: '7',
      title: 'Hackathon 2024',
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
      activityTypeId: 3,
      activityTypeName: 'Edukacija',
      status: EventStatus.upcoming,
      isFeatured: true,
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
    ),
    Event(
      id: '8',
      title: 'Trening završen',
      description: 'Redovni fudbalski trening.',
      location: 'Sportska dvorana Skenderija',
      address: 'Terezije bb, Sarajevo',
      startDate: DateTime.now().subtract(const Duration(days: 5)),
      endDate: DateTime.now().subtract(const Duration(days: 5, hours: -2)),
      price: 0,
      participantsCount: 22,
      organizationId: '1',
      organizationName: 'FK Sarajevo Mladi',
      activityTypeId: 1,
      activityTypeName: 'Sport',
      status: EventStatus.completed,
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
    ),
    // Additional events for FK Sarajevo Mladi (org 1)
    Event(
      id: '9',
      title: 'Utakmica - FK Sarajevo vs FK Željezničar',
      description: 'Prijateljska utakmica omladinskih selekcija. Dođite i podržite naše mlade talente!',
      location: 'Stadion Koševo',
      address: 'Patriotske lige 35, Sarajevo',
      startDate: DateTime.now().add(const Duration(days: 8)),
      endDate: DateTime.now().add(const Duration(days: 8, hours: 2)),
      price: 5,
      currency: 'BAM',
      maxParticipants: 200,
      participantsCount: 85,
      organizationId: '1',
      organizationName: 'FK Sarajevo Mladi',
      activityTypeId: 1,
      activityTypeName: 'Sport',
      status: EventStatus.upcoming,
      isFeatured: true,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    Event(
      id: '10',
      title: 'Trening - Napredna grupa',
      description: 'Intenzivan trening za napredne igrače. Fokus na taktici i timskoj igri.',
      location: 'Sportska dvorana Skenderija',
      address: 'Terezije bb, Sarajevo',
      startDate: DateTime.now().add(const Duration(days: 4)),
      endDate: DateTime.now().add(const Duration(days: 4, hours: 2)),
      price: 0,
      maxParticipants: 20,
      participantsCount: 15,
      organizationId: '1',
      organizationName: 'FK Sarajevo Mladi',
      activityTypeId: 1,
      activityTypeName: 'Sport',
      status: EventStatus.upcoming,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Event(
      id: '11',
      title: 'Ljetni kamp - Fudbal',
      description: 'Trodnevni ljetni kamp za mlade fudbalere. Uključuje smještaj i hranu.',
      location: 'Sportski centar Vlašić',
      address: 'Vlašić, Travnik',
      startDate: DateTime.now().add(const Duration(days: 30)),
      endDate: DateTime.now().add(const Duration(days: 33)),
      price: 150,
      currency: 'BAM',
      maxParticipants: 40,
      participantsCount: 28,
      organizationId: '1',
      organizationName: 'FK Sarajevo Mladi',
      activityTypeId: 1,
      activityTypeName: 'Sport',
      status: EventStatus.upcoming,
      isFeatured: true,
      createdAt: DateTime.now().subtract(const Duration(days: 14)),
    ),
    Event(
      id: '12',
      title: 'Trening - Prošli tjedan',
      description: 'Redovni fudbalski trening.',
      location: 'Sportska dvorana Skenderija',
      address: 'Terezije bb, Sarajevo',
      startDate: DateTime.now().subtract(const Duration(days: 7)),
      endDate: DateTime.now().subtract(const Duration(days: 7, hours: -2)),
      price: 0,
      participantsCount: 19,
      organizationId: '1',
      organizationName: 'FK Sarajevo Mladi',
      activityTypeId: 1,
      activityTypeName: 'Sport',
      status: EventStatus.completed,
      createdAt: DateTime.now().subtract(const Duration(days: 17)),
    ),
    Event(
      id: '13',
      title: 'Mini turnir - U12',
      description: 'Mini turnir za uzrast do 12 godina.',
      location: 'Sportska dvorana Skenderija',
      address: 'Terezije bb, Sarajevo',
      startDate: DateTime.now().subtract(const Duration(days: 14)),
      endDate: DateTime.now().subtract(const Duration(days: 14, hours: -4)),
      price: 0,
      participantsCount: 32,
      organizationId: '1',
      organizationName: 'FK Sarajevo Mladi',
      activityTypeId: 1,
      activityTypeName: 'Sport',
      status: EventStatus.completed,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
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
    ),
    Category(
      id: '2',
      name: 'Kultura',
      description: 'Kulturni događaji i umjetnost',
      icon: 'palette',
      color: '#9C27B0',
      organizationsCount: 8,
      eventsCount: 30,
    ),
    Category(
      id: '3',
      name: 'Edukacija',
      description: 'Edukativni programi i radionice',
      icon: 'school',
      color: '#2196F3',
      organizationsCount: 15,
      eventsCount: 60,
    ),
    Category(
      id: '4',
      name: 'Zdravlje',
      description: 'Zdravlje i wellness aktivnosti',
      icon: 'favorite',
      color: '#F44336',
      organizationsCount: 6,
      eventsCount: 25,
    ),
    Category(
      id: '5',
      name: 'Muzika',
      description: 'Muzički događaji i koncerti',
      icon: 'music_note',
      color: '#FF9800',
      organizationsCount: 10,
      eventsCount: 35,
    ),
    Category(
      id: '6',
      name: 'Tehnologija',
      description: 'Tech meetupi i konferencije',
      icon: 'computer',
      color: '#607D8B',
      organizationsCount: 5,
      eventsCount: 20,
    ),
  ];

  /// Mock enrollments
  final List<Enrollment> _mockEnrollments = [
    // Pending enrollments for organization 1
    Enrollment(
      id: '1',
      userId: '3',
      organizationId: '1',
      message: 'Želim se pridružiti klubu jer volim fudbal. Imam 14 godina i treniram već 2 godine.',
      status: EnrollmentStatus.pending,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Enrollment(
      id: '2',
      userId: '4',
      organizationId: '1',
      message: 'Imam iskustva u fudbalu i želim trenirati sa vašim klubom.',
      status: EnrollmentStatus.pending,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Enrollment(
      id: '10',
      userId: '7',
      organizationId: '1',
      message: 'Želim se pridružiti klubu. Igram fudbal od malih nogu.',
      status: EnrollmentStatus.pending,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    Enrollment(
      id: '11',
      userId: '8',
      organizationId: '1',
      message: 'Zainteresovana sam za članstvo. Mogu li doći na probni trening?',
      status: EnrollmentStatus.pending,
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
    ),
    Enrollment(
      id: '12',
      userId: '5',
      organizationId: '1',
      message: 'Molim za članstvo. Preporučio me prijatelj koji je već član.',
      status: EnrollmentStatus.pending,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    // Approved enrollments for organization 1
    Enrollment(
      id: '3',
      userId: '1',
      organizationId: '1',
      status: EnrollmentStatus.approved,
      createdAt: DateTime.now().subtract(const Duration(days: 180)),
      reviewedAt: DateTime.now().subtract(const Duration(days: 179)),
    ),
    Enrollment(
      id: '4',
      userId: '2',
      organizationId: '1',
      status: EnrollmentStatus.approved,
      createdAt: DateTime.now().subtract(const Duration(days: 365)),
      reviewedAt: DateTime.now().subtract(const Duration(days: 364)),
    ),
    Enrollment(
      id: '5',
      userId: '6',
      organizationId: '1',
      status: EnrollmentStatus.approved,
      createdAt: DateTime.now().subtract(const Duration(days: 90)),
      reviewedAt: DateTime.now().subtract(const Duration(days: 89)),
    ),
    // Additional approved enrollments for organization 1
    Enrollment(
      id: '13',
      userId: '3',
      organizationId: '1',
      status: EnrollmentStatus.approved,
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
      reviewedAt: DateTime.now().subtract(const Duration(days: 44)),
    ),
    Enrollment(
      id: '14',
      userId: '4',
      organizationId: '1',
      status: EnrollmentStatus.approved,
      createdAt: DateTime.now().subtract(const Duration(days: 120)),
      reviewedAt: DateTime.now().subtract(const Duration(days: 119)),
    ),
    Enrollment(
      id: '15',
      userId: '7',
      organizationId: '1',
      status: EnrollmentStatus.approved,
      createdAt: DateTime.now().subtract(const Duration(days: 200)),
      reviewedAt: DateTime.now().subtract(const Duration(days: 199)),
    ),
    Enrollment(
      id: '16',
      userId: '8',
      organizationId: '1',
      status: EnrollmentStatus.approved,
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
      reviewedAt: DateTime.now().subtract(const Duration(days: 59)),
    ),
    // Approved enrollments for organization 2
    Enrollment(
      id: '6',
      userId: '6',
      organizationId: '2',
      message: 'Volim planinarenje i želim se pridružiti.',
      status: EnrollmentStatus.approved,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      reviewedAt: DateTime.now().subtract(const Duration(days: 4)),
    ),
    Enrollment(
      id: '7',
      userId: '1',
      organizationId: '2',
      status: EnrollmentStatus.approved,
      createdAt: DateTime.now().subtract(const Duration(days: 150)),
      reviewedAt: DateTime.now().subtract(const Duration(days: 149)),
    ),
    Enrollment(
      id: '8',
      userId: '3',
      organizationId: '2',
      status: EnrollmentStatus.approved,
      createdAt: DateTime.now().subtract(const Duration(days: 80)),
      reviewedAt: DateTime.now().subtract(const Duration(days: 79)),
    ),
    // Pending enrollments for organization 2
    Enrollment(
      id: '9',
      userId: '5',
      organizationId: '2',
      message: 'Želim se pridružiti planinarskom društvu. Imam opremu i iskustvo.',
      status: EnrollmentStatus.pending,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
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

    // Simulate password check (any password works for mock)
    if (password.isEmpty) {
      return ApiResponse.error('Unesite lozinku', statusCode: 400);
    }

    // Check if logging in as organization
    final org = _mockOrganizations.firstWhere(
      (o) => o.email == email,
      orElse: () => _mockOrganizations.first,
    );

    final isOrgLogin = _mockOrganizations.any((o) => o.email == email);

    if (isOrgLogin) {
      // Login as organization
      final authResponse = AuthResponse(
        id: org.userId?.toString() ?? '1',
        email: email,
        firstName: org.name.split(' ').first,
        lastName: org.name.split(' ').length > 1 ? org.name.split(' ').last : null,
        accessToken: 'mock_access_token_org_${DateTime.now().millisecondsSinceEpoch}',
        refreshToken: 'mock_refresh_token_org',
        expiresAt: DateTime.now().add(const Duration(days: 7)),
        roles: ['Organization'],
        requiresOrganizationSetup: false,
        organization: org,
      );
      return ApiResponse.success(authResponse);
    } else {
      // Login as regular user
      final authResponse = AuthResponse(
        id: '1',
        email: email,
        firstName: 'Amar',
        lastName: 'Hadžić',
        accessToken: 'mock_access_token_1_${DateTime.now().millisecondsSinceEpoch}',
        refreshToken: 'mock_refresh_token_1',
        expiresAt: DateTime.now().add(const Duration(days: 7)),
        roles: ['User'],
        requiresOrganizationSetup: false,
      );
      return ApiResponse.success(authResponse);
    }
  }

  /// Register
  Future<ApiResponse<AuthResponse>> register(RegisterRequest request) async {
    await _simulateDelay();

    final authResponse = AuthResponse(
      id: '${_mockUsers.length + 1}',
      email: request.email,
      firstName: null,
      lastName: null,
      accessToken: 'mock_access_token_new_${DateTime.now().millisecondsSinceEpoch}',
      refreshToken: 'mock_refresh_token_new',
      expiresAt: DateTime.now().add(const Duration(days: 7)),
      roles: request.isOrganization ? ['Organization'] : ['User'],
      requiresOrganizationSetup: request.isOrganization,
    );

    return ApiResponse.success(authResponse);
  }

  /// Get current user auth info
  Future<ApiResponse<AuthResponse>> getCurrentUserAuth() async {
    await _simulateDelay();

    // For mock, return first organization as logged-in org (if any)
    // In real scenario, this would check the actual logged-in user
    final org = _mockOrganizations.first;

    final authResponse = AuthResponse(
      id: org.userId?.toString() ?? '1',
      email: org.email,
      firstName: org.name.split(' ').first,
      lastName: org.name.split(' ').length > 1 ? org.name.split(' ').last : null,
      accessToken: 'mock_access_token_org_${DateTime.now().millisecondsSinceEpoch}',
      refreshToken: 'mock_refresh_token_org',
      expiresAt: DateTime.now().add(const Duration(days: 7)),
      roles: ['Organization'],
      requiresOrganizationSetup: false,
      organization: org,
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
      name: data['Name'] as String? ?? data['name'] as String? ?? _mockUsers[index].name,
      phone: data['Phone'] as String? ?? data['phone'] as String? ?? _mockUsers[index].phone,
      bio: data['Bio'] as String? ?? data['bio'] as String? ?? _mockUsers[index].bio,
      address: data['Address'] as String? ?? data['address'] as String? ?? _mockUsers[index].address,
      lastModifiedAt: DateTime.now(),
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
        case 'Name':
          filteredUsers.sort((a, b) => a.name.compareTo(b.name));
          break;
        case 'Email':
          filteredUsers.sort((a, b) => a.email.compareTo(b.email));
          break;
        case 'CreatedAt':
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
        case 'Name':
          filteredOrgs.sort((a, b) => a.name.compareTo(b.name));
          break;
        case 'MembersCount':
          filteredOrgs.sort((a, b) => b.membersCount.compareTo(a.membersCount));
          break;
        case 'EventsCount':
          filteredOrgs.sort((a, b) => b.eventsCount.compareTo(a.eventsCount));
          break;
        case 'CreatedAt':
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
      email: data['email'] as String? ?? '',
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
      name: data['Name'] as String? ?? data['name'] as String? ?? _mockOrganizations[index].name,
      description: data['Description'] as String? ?? data['description'] as String? ?? _mockOrganizations[index].description,
      phone: data['Phone'] as String? ?? data['phone'] as String? ?? _mockOrganizations[index].phone,
      email: data['Email'] as String? ?? data['email'] as String? ?? _mockOrganizations[index].email,
      address: data['Address'] as String? ?? data['address'] as String? ?? _mockOrganizations[index].address,
      lastModifiedAt: DateTime.now(),
    );

    return ApiResponse.success(updatedOrg);
  }

  // ==================== EVENT API ====================

  /// Get events (paginated)
  Future<ApiResponse<PaginatedResponse<Event>>> getEvents({
    int page = 1,
    int perPage = 10,
    String? search,
    String? activityTypeId,
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

    // Apply activity type filter
    if (activityTypeId != null && activityTypeId.isNotEmpty) {
      filteredEvents = filteredEvents.where((e) => e.activityTypeId == int.parse(activityTypeId)).toList();
    }

    // Apply organization filter (disabled for testing - show all events)
    // if (organizationId != null && organizationId.isNotEmpty) {
    //   filteredEvents = filteredEvents.where((e) => e.organizationId == organizationId).toList();
    // }

    // Apply status filter
    if (status != null) {
      filteredEvents = filteredEvents.where((e) => e.status == status).toList();
    }

    // Apply featured filter
    if (featured == true) {
      filteredEvents = filteredEvents.where((e) => e.isFeatured).toList();
    }

    // Apply sorting
    switch (sortBy ?? 'StartDate') {
      case 'Name':
        filteredEvents.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'StartDate':
        filteredEvents.sort((a, b) => a.startDate.compareTo(b.startDate));
        break;
      case 'ParticipantsCount':
        filteredEvents.sort((a, b) => b.participantsCount.compareTo(a.participantsCount));
        break;
      case 'CreatedAt':
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
      title: data['Title'] as String? ?? data['title'] as String,
      description: data['Description'] as String? ?? data['description'] as String?,
      location: data['Location'] as String? ?? data['location'] as String?,
      address: data['Address'] as String? ?? data['address'] as String?,
      startDate: DateTime.parse(data['Start'] as String? ?? data['startDate'] as String),
      endDate: data['End'] != null ? DateTime.parse(data['End'] as String) :
               data['endDate'] != null ? DateTime.parse(data['endDate'] as String) : null,
      price: (data['Price'] as num?)?.toDouble() ?? (data['price'] as num?)?.toDouble() ?? 0,
      maxParticipants: data['MaxParticipants'] as int? ?? data['maxParticipants'] as int?,
      organizationId: data['OrganizationId'] as String? ?? data['organizationId'] as String,
      organizationName: data['OrganizationName'] as String? ?? data['organizationName'] as String?,
      activityTypeId: data['ActivityTypeId'] as int? ?? data['activityTypeId'] as int?,
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
      title: data['Title'] as String? ?? data['title'] as String? ?? _mockEvents[index].title,
      description: data['Description'] as String? ?? data['description'] as String? ?? _mockEvents[index].description,
      location: data['Location'] as String? ?? data['location'] as String? ?? _mockEvents[index].location,
      address: data['Address'] as String? ?? data['address'] as String? ?? _mockEvents[index].address,
      price: (data['Price'] as num?)?.toDouble() ?? (data['price'] as num?)?.toDouble() ?? _mockEvents[index].price,
      maxParticipants: data['MaxParticipants'] as int? ?? data['maxParticipants'] as int? ?? _mockEvents[index].maxParticipants,
      lastModifiedAt: DateTime.now(),
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
        userName: user.name,
        userEmail: user.email,
        userPhone: user.phone,
        userAvatar: user.profileImageUrl,
        joinedAt: DateTime.now().subtract(Duration(days: _random.nextInt(7))),
        isPaid: _random.nextBool(),
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

  // ==================== PARTICIPATION API ====================

  /// Get organization event participations
  Future<ApiResponse<PaginatedResponse<EventParticipation>>> getOrganizationParticipations(
    String organizationId, {
    int page = 1,
    int perPage = 10,
  }) async {
    await _simulateDelay();

    // For testing: return all events (ignore organizationId filter)
    final orgEvents = _mockEvents.toList();

    final participations = orgEvents
        .map((e) => EventParticipation.fromEvent(e))
        .toList();

    // Sort by participants count descending
    participations.sort((a, b) => b.participantsCount.compareTo(a.participantsCount));

    // Calculate total participations
    final totalParticipations = participations.fold<int>(
      0,
      (sum, p) => sum + p.participantsCount,
    );

    return ApiResponse.success(PaginatedResponse(
      data: participations,
      currentPage: page,
      lastPage: 1,
      perPage: perPage,
      total: totalParticipations,
    ));
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

    // For testing: return all enrollments (ignore organizationId filter)
    var filteredEnrollments = _mockEnrollments.toList();

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
