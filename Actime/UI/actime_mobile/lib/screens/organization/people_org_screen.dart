import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../constants/constants.dart';
import '../../components/bottom_nav_org.dart';
import '../../models/models.dart';
import '../../services/services.dart';
import 'organization_profile_screen.dart';
import 'event_participants_detail_screen.dart';
import 'enrollment_requests_screen.dart';
import 'my_events_org_screen.dart';

class PeopleOrgScreen extends StatefulWidget {
  final String organizationId;

  const PeopleOrgScreen({super.key, required this.organizationId});

  @override
  State<PeopleOrgScreen> createState() => _PeopleOrgScreenState();
}

class _PeopleOrgScreenState extends State<PeopleOrgScreen> {
  final _organizationService = OrganizationService();

  int _selectedTab = 0; // 0 = Participations, 1 = Enrollments
  int _selectedTimeFilter = 0; // 0 = Events, 1 = Months, 2 = Years
  List<EventParticipation> _participations = [];
  List<Membership> _approvedEnrollments = [];
  List<Membership> _pendingEnrollments = [];
  int _totalParticipations = 0;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final participationsResponse = await _organizationService.getOrganizationParticipations(widget.organizationId);
      final approvedEnrollmentsResponse = await _organizationService.getOrganizationEnrollments(
        widget.organizationId,
        status: EnrollmentStatus.approved,
      );
      final pendingEnrollmentsResponse = await _organizationService.getOrganizationEnrollments(
        widget.organizationId,
        status: EnrollmentStatus.pending,
      );

      if (!mounted) return;

      setState(() {
        if (participationsResponse.success && participationsResponse.data != null) {
          _participations = participationsResponse.data!.data;
          _totalParticipations = participationsResponse.data!.total;
        }
        if (approvedEnrollmentsResponse.success && approvedEnrollmentsResponse.data != null) {
          _approvedEnrollments = approvedEnrollmentsResponse.data!.data;
        }
        if (pendingEnrollmentsResponse.success && pendingEnrollmentsResponse.data != null) {
          _pendingEnrollments = pendingEnrollmentsResponse.data!.data;
        }
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Greska pri ucitavanju podataka';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const Padding(
          padding: EdgeInsets.all(12.0),
          child: Text(
            'Actime',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        leadingWidth: 100,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: AppColors.primary),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OrganizationProfileScreen(
                    organizationId: widget.organizationId,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTabs(),
          const Divider(height: 1),
          Expanded(child: _buildContent()),
        ],
      ),
      bottomNavigationBar: BottomNavOrg(
        currentIndex: 2,
        organizationId: widget.organizationId,
      ),
    );
  }

  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(child: _buildTabButton('Participations', 0)),
          const SizedBox(width: 12),
          Expanded(child: _buildTabButton('Enrollments', 1)),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, int index) {
    final isActive = _selectedTab == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isActive ? AppColors.primary : Colors.grey.shade300,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isActive ? Colors.white : Colors.grey,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppColors.textMuted),
            const SizedBox(height: 16),
            Text(_error!, style: TextStyle(color: AppColors.textMuted)),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _loadData,
              child: const Text('Pokusaj ponovo'),
            ),
          ],
        ),
      );
    }

    if (_selectedTab == 0) {
      return _buildParticipationsTab();
    } else {
      return _buildEnrollmentsTab();
    }
  }

  Widget _buildParticipationsTab() {
    if (_participations.isEmpty) {
      return _buildEmptyParticipations();
    }

    return Column(
      children: [
        // Header with total count
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.people, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                '$_totalParticipations participations',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        // Time filters
        _buildTimeFilters(),
        const SizedBox(height: 8),
        // Participations list
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadData,
            color: AppColors.primary,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _participations.length,
              itemBuilder: (context, index) {
                final participation = _participations[index];
                return _buildParticipationCard(participation);
              },
            ),
          ),
        ),
        // Generate report button
        _buildGenerateReportButton(),
      ],
    );
  }

  Widget _buildEmptyParticipations() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.people_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              '0 participations',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your participations are currently empty.',
              style: TextStyle(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Add new event to get people informed.',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyEventsOrgScreen(
                      organizationId: widget.organizationId,
                    ),
                  ),
                );
              },
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Check out your events',
                    style: TextStyle(color: AppColors.primary),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward, size: 16, color: AppColors.primary),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildFilterChip('Events', 0),
          const SizedBox(width: 8),
          _buildFilterChip('Months', 1),
          const SizedBox(width: 8),
          _buildFilterChip('Years', 2),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, int index) {
    final isActive = _selectedTimeFilter == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTimeFilter = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? AppColors.primary : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? Colors.white : Colors.grey,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildParticipationCard(EventParticipation participation) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventParticipantsDetailScreen(
              eventId: participation.eventId,
              eventName: participation.eventName,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                participation.eventName,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.primary,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${participation.participantsCount}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnrollmentsTab() {
    return Column(
      children: [
        // Stats header
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.how_to_reg, size: 20, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    '${_approvedEnrollments.length} enrollments',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EnrollmentRequestsScreen(
                        organizationId: widget.organizationId,
                      ),
                    ),
                  ).then((_) => _loadData());
                },
                child: Row(
                  children: [
                    const Icon(Icons.pending_actions, size: 20, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      '${_pendingEnrollments.length} requests',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_forward, size: 16, color: AppColors.primary),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        // Column headers
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  'Individual',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  'Months',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  'Years',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Enrolled users list
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadData,
            color: AppColors.primary,
            child: _approvedEnrollments.isEmpty
                ? Center(
                    child: Text(
                      'No enrolled members yet',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _approvedEnrollments.length,
                    itemBuilder: (context, index) {
                      final enrollment = _approvedEnrollments[index];
                      return _buildEnrollmentCard(enrollment);
                    },
                  ),
          ),
        ),
        // Generate report button
        _buildGenerateReportButton(),
      ],
    );
  }

  Widget _buildEnrollmentCard(Membership membership) {
    final user = membership.user;
    final dateFormat = DateFormat('dd.MM.yyyy.');
    // Calculate months since enrollment
    final enrolledDate = membership.startDate ?? membership.createdAt;
    final monthsSinceEnrollment = DateTime.now().difference(enrolledDate).inDays ~/ 30;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              user?.name ?? 'Unknown',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.primary,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              monthsSinceEnrollment.toString(),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              dateFormat.format(enrolledDate),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenerateReportButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Generate report coming soon')),
          );
        },
        child: const Row(
          children: [
            Icon(Icons.description_outlined, size: 20, color: AppColors.primary),
            SizedBox(width: 8),
            Text(
              'Generate report',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
