import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../constants/constants.dart';
import '../../components/bottom_nav_org.dart';
import '../../components/circle_icon_container.dart';
import '../../models/models.dart';
import '../../services/services.dart';

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
  Organization? _organization;
  List<User> _members = [];
  List<Enrollment> _enrollments = [];
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
      final orgResponse = await _organizationService.getOrganizationById(widget.organizationId);
      final membersResponse = await _organizationService.getOrganizationMembers(widget.organizationId);
      final enrollmentsResponse = await _organizationService.getOrganizationEnrollments(
        widget.organizationId,
        status: EnrollmentStatus.pending,
      );

      if (!mounted) return;

      setState(() {
        if (orgResponse.success && orgResponse.data != null) {
          _organization = orgResponse.data;
        }
        if (membersResponse.success && membersResponse.data != null) {
          _members = membersResponse.data!.data;
        }
        if (enrollmentsResponse.success && enrollmentsResponse.data != null) {
          _enrollments = enrollmentsResponse.data!.data;
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

  IconData _getCategoryIcon(String? categoryName) {
    switch (categoryName?.toLowerCase()) {
      case 'sport':
        return Icons.sports_soccer;
      case 'kultura':
        return Icons.palette;
      case 'edukacija':
        return Icons.school;
      case 'zdravlje':
        return Icons.favorite;
      case 'muzika':
        return Icons.music_note;
      case 'tehnologija':
        return Icons.computer;
      default:
        return Icons.groups;
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
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          _buildOrganizationHeader(),
          const Divider(height: 1),
          _buildTabs(),
          const SizedBox(height: 8),
          if (_selectedTab == 0) _buildTimeFilters(),
          Expanded(child: _buildContent()),
        ],
      ),
      bottomNavigationBar: BottomNavOrg(
        currentIndex: 2,
        organizationId: widget.organizationId,
      ),
    );
  }

  Widget _buildOrganizationHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleIconContainer.large(
            icon: _getCategoryIcon(_organization?.categoryName),
            iconColor: AppColors.orange,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _organization?.name ?? 'Organizacija',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  _organization?.categoryName ?? 'Klub',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Text(
                '${_organization?.membersCount ?? 0}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.person_outline, size: 16, color: Colors.grey),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
    final enrollmentCount = _enrollments.length;

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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: isActive ? Colors.white : Colors.grey,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              if (index == 1 && enrollmentCount > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.white : AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$enrollmentCount',
                    style: TextStyle(
                      fontSize: 10,
                      color: isActive ? AppColors.primary : Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
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
      return _buildParticipationsList();
    } else {
      return _buildEnrollmentsList();
    }
  }

  Widget _buildParticipationsList() {
    if (_members.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 48, color: AppColors.textMuted),
            const SizedBox(height: 16),
            Text(
              '0 participations',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your participations are currently empty.',
              style: TextStyle(color: AppColors.textMuted),
            ),
            const SizedBox(height: 8),
            Text(
              'Add new event to get people informed.',
              style: TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () {},
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
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
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _members.length,
        itemBuilder: (context, index) {
          final member = _members[index];
          return _buildParticipationCard(member, 125 - index * 10);
        },
      ),
    );
  }

  Widget _buildParticipationCard(User member, int participationCount) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey.shade200,
            child: Text(
              member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
              style: const TextStyle(color: AppColors.primary),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  member.email,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '$participationCount',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnrollmentsList() {
    if (_enrollments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.how_to_reg_outlined, size: 48, color: AppColors.textMuted),
            const SizedBox(height: 16),
            Text(
              'No pending enrollments',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppColors.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.how_to_reg, size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  '${_enrollments.length} requests',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _enrollments.length,
              itemBuilder: (context, index) {
                final enrollment = _enrollments[index];
                return _buildEnrollmentCard(enrollment);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnrollmentCard(Enrollment enrollment) {
    final user = enrollment.user;
    final dateFormat = DateFormat('dd.MM.yyyy');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey.shade200,
            child: Text(
              user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : '?',
              style: const TextStyle(color: AppColors.primary),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.name ?? 'Nepoznat',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  user?.email ?? '',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 4),
                Text(
                  dateFormat.format(enrollment.createdAt),
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.check_circle, color: Colors.green),
                onPressed: () => _approveEnrollment(enrollment),
              ),
              IconButton(
                icon: const Icon(Icons.cancel, color: Colors.red),
                onPressed: () => _rejectEnrollment(enrollment),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _approveEnrollment(Enrollment enrollment) async {
    final response = await _organizationService.approveEnrollment(enrollment.id);
    if (response.success) {
      _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Zahtjev odobren')),
        );
      }
    }
  }

  Future<void> _rejectEnrollment(Enrollment enrollment) async {
    final response = await _organizationService.rejectEnrollment(enrollment.id);
    if (response.success) {
      _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Zahtjev odbijen')),
        );
      }
    }
  }
}
