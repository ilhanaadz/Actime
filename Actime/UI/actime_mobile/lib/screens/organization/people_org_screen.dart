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
import 'period_participants_screen.dart';

class PeopleOrgScreen extends StatefulWidget {
  final String organizationId;

  const PeopleOrgScreen({super.key, required this.organizationId});

  @override
  State<PeopleOrgScreen> createState() => _PeopleOrgScreenState();
}

class _PeopleOrgScreenState extends State<PeopleOrgScreen> {
  final _organizationService = OrganizationService();
  final _pdfReportService = PdfReportService();

  int _selectedTab = 0; // 0 = Participations, 1 = Enrollments
  int _selectedParticipationView = 0; // 0 = Events, 1 = Months, 2 = Years
  int _selectedEnrollmentView = 0; // 0 = Individual, 1 = Months, 2 = Years
  List<EventParticipation> _participations = [];
  List<ParticipationByMonth> _participationsByMonth = [];
  List<ParticipationByYear> _participationsByYear = [];
  List<Membership> _approvedEnrollments = [];
  List<EnrollmentByMonth> _enrollmentsByMonth = [];
  List<EnrollmentByYear> _enrollmentsByYear = [];
  List<Membership> _pendingEnrollments = [];
  bool _isLoading = true;
  bool _isGeneratingReport = false;
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
      final participationsByMonthResponse = await _organizationService.getOrganizationParticipationsByMonth(widget.organizationId);
      final participationsByYearResponse = await _organizationService.getOrganizationParticipationsByYear(widget.organizationId);
      final approvedEnrollmentsResponse = await _organizationService.getOrganizationEnrollments(
        widget.organizationId,
        status: EnrollmentStatus.approved,
      );
      final enrollmentsByMonthResponse = await _organizationService.getOrganizationEnrollmentsByMonth(widget.organizationId);
      final enrollmentsByYearResponse = await _organizationService.getOrganizationEnrollmentsByYear(widget.organizationId);
      final pendingEnrollmentsResponse = await _organizationService.getOrganizationEnrollments(
        widget.organizationId,
        status: EnrollmentStatus.pending,
      );

      if (!mounted) return;

      setState(() {
        if (participationsResponse.success && participationsResponse.data != null) {
          _participations = participationsResponse.data!;
        }
        if (participationsByMonthResponse.success && participationsByMonthResponse.data != null) {
          _participationsByMonth = participationsByMonthResponse.data!;
        }
        if (participationsByYearResponse.success && participationsByYearResponse.data != null) {
          _participationsByYear = participationsByYearResponse.data!;
        }
        if (approvedEnrollmentsResponse.success && approvedEnrollmentsResponse.data != null) {
          _approvedEnrollments = approvedEnrollmentsResponse.data!;
        }
        if (enrollmentsByMonthResponse.success && enrollmentsByMonthResponse.data != null) {
          _enrollmentsByMonth = enrollmentsByMonthResponse.data!;
        }
        if (enrollmentsByYearResponse.success && enrollmentsByYearResponse.data != null) {
          _enrollmentsByYear = enrollmentsByYearResponse.data!;
        }
        if (pendingEnrollmentsResponse.success && pendingEnrollmentsResponse.data != null) {
          _pendingEnrollments = pendingEnrollmentsResponse.data!;
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

  Future<void> _generateParticipationsReport() async {
    setState(() => _isGeneratingReport = true);

    try {
      // Fetch organization details for name/logo
      final orgResponse = await _organizationService.getOrganizationById(widget.organizationId);

      if (!orgResponse.success || orgResponse.data == null) {
        throw Exception('Failed to load organization details');
      }

      final org = orgResponse.data!;

      // Generate PDF
      final response = await _pdfReportService.generateParticipationsReport(
        organizationId: widget.organizationId,
        organizationName: org.name,
        organizationLogoUrl: org.logoUrl,
        participations: _participations,
        totalParticipations: _participations.length,
      );

      if (!mounted) return;

      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Izvještaj uspješno generisan'),
            backgroundColor: AppColors.primary,
          ),
        );
      } else {
        _showErrorSnackbar(response.message ?? 'Greška pri generisanju izvještaja');
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackbar('Greška: $e');
    } finally {
      if (mounted) {
        setState(() => _isGeneratingReport = false);
      }
    }
  }

  Future<void> _generateEnrollmentsReport() async {
    setState(() => _isGeneratingReport = true);

    try {
      final orgResponse = await _organizationService.getOrganizationById(widget.organizationId);

      if (!orgResponse.success || orgResponse.data == null) {
        throw Exception('Failed to load organization details');
      }

      final org = orgResponse.data!;

      final response = await _pdfReportService.generateEnrollmentsReport(
        organizationId: widget.organizationId,
        organizationName: org.name,
        organizationLogoUrl: org.logoUrl,
        enrollments: _approvedEnrollments,
      );

      if (!mounted) return;

      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Izvještaj uspješno generisan'),
            backgroundColor: AppColors.primary,
          ),
        );
      } else {
        _showErrorSnackbar(response.message ?? 'Greška pri generisanju izvještaja');
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackbar('Greška: $e');
    } finally {
      if (mounted) {
        setState(() => _isGeneratingReport = false);
      }
    }
  }

  void _handleGenerateReport() {
    if (_selectedTab == 0) {
      // Participations tab - check which view is selected
      switch (_selectedParticipationView) {
        case 0:
          _generateParticipationsReport();
          break;
        case 1:
          _generateParticipationsByMonthReport();
          break;
        case 2:
          _generateParticipationsByYearReport();
          break;
      }
    } else {
      _generateEnrollmentsReport();
    }
  }

  Future<void> _generateParticipationsByMonthReport() async {
    setState(() => _isGeneratingReport = true);

    try {
      final orgResponse = await _organizationService.getOrganizationById(widget.organizationId);

      if (!orgResponse.success || orgResponse.data == null) {
        throw Exception('Failed to load organization details');
      }

      final org = orgResponse.data!;

      final response = await _pdfReportService.generateParticipationsByMonthReport(
        organizationId: widget.organizationId,
        organizationName: org.name,
        organizationLogoUrl: org.logoUrl,
        participations: _participationsByMonth,
        totalParticipations: _participationsByMonth.length,
      );

      if (!mounted) return;

      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Izvještaj uspješno generisan'),
            backgroundColor: AppColors.primary,
          ),
        );
      } else {
        _showErrorSnackbar(response.message ?? 'Greška pri generisanju izvještaja');
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackbar('Greška: $e');
    } finally {
      if (mounted) {
        setState(() => _isGeneratingReport = false);
      }
    }
  }

  Future<void> _generateParticipationsByYearReport() async {
    setState(() => _isGeneratingReport = true);

    try {
      final orgResponse = await _organizationService.getOrganizationById(widget.organizationId);

      if (!orgResponse.success || orgResponse.data == null) {
        throw Exception('Failed to load organization details');
      }

      final org = orgResponse.data!;

      final response = await _pdfReportService.generateParticipationsByYearReport(
        organizationId: widget.organizationId,
        organizationName: org.name,
        organizationLogoUrl: org.logoUrl,
        participations: _participationsByYear,
        totalParticipations: _participationsByYear.length,
      );

      if (!mounted) return;

      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Izvještaj uspješno generisan'),
            backgroundColor: AppColors.primary,
          ),
        );
      } else {
        _showErrorSnackbar(response.message ?? 'Greška pri generisanju izvještaja');
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackbar('Greška: $e');
    } finally {
      if (mounted) {
        setState(() => _isGeneratingReport = false);
      }
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
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
    return Column(
      children: [
        // Sub-tabs for participation views
        _buildParticipationViewTabs(),
        const Divider(height: 1),
        // Content based on selected view
        Expanded(child: _buildParticipationViewContent()),
      ],
    );
  }

  Widget _buildParticipationViewTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(child: _buildParticipationViewTab('Events', 0)),
          const SizedBox(width: 8),
          Expanded(child: _buildParticipationViewTab('Months', 1)),
          const SizedBox(width: 8),
          Expanded(child: _buildParticipationViewTab('Years', 2)),
        ],
      ),
    );
  }

  Widget _buildParticipationViewTab(String label, int index) {
    final isActive = _selectedParticipationView == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedParticipationView = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? AppColors.primary : Colors.grey.shade300,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: isActive ? Colors.white : Colors.grey,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildParticipationViewContent() {
    switch (_selectedParticipationView) {
      case 0:
        return _buildEventsList();
      case 1:
        return _buildMonthsList();
      case 2:
        return _buildYearsList();
      default:
        return _buildEventsList();
    }
  }

  Widget _buildEventsList() {
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
                '${_participations.length} events',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
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

  Widget _buildMonthsList() {
    if (_participationsByMonth.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.calendar_month, size: 64, color: Colors.grey),
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
                'No participations data available.',
                style: TextStyle(color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // Header with total count
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.calendar_month, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                '${_participationsByMonth.length} months',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Months list
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadData,
            color: AppColors.primary,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _participationsByMonth.length,
              itemBuilder: (context, index) {
                final monthData = _participationsByMonth[index];
                return _buildMonthCard(monthData);
              },
            ),
          ),
        ),
        // Generate report button
        _buildGenerateReportButton(),
      ],
    );
  }

  Widget _buildYearsList() {
    if (_participationsByYear.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.date_range, size: 64, color: Colors.grey),
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
                'No participations data available.',
                style: TextStyle(color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // Header with total count
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.date_range, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                '${_participationsByYear.length} years',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Years list
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadData,
            color: AppColors.primary,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _participationsByYear.length,
              itemBuilder: (context, index) {
                final yearData = _participationsByYear[index];
                return _buildYearCard(yearData);
              },
            ),
          ),
        ),
        // Generate report button
        _buildGenerateReportButton(),
      ],
    );
  }

  Widget _buildMonthCard(ParticipationByMonth monthData) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PeriodParticipantsScreen(
              organizationId: widget.organizationId,
              periodType: 'month',
              month: monthData.month,
              periodName: monthData.monthName,
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
                monthData.monthName,
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
                '${monthData.participantsCount}',
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

  Widget _buildYearCard(ParticipationByYear yearData) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PeriodParticipantsScreen(
              organizationId: widget.organizationId,
              periodType: 'year',
              year: yearData.year,
              periodName: '${yearData.year}',
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
                '${yearData.year}',
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
                '${yearData.participantsCount}',
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

  Widget _buildParticipationCard(EventParticipation participation) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventParticipantsDetailScreen(
              eventId: participation.eventId,
              eventName: participation.eventName,
              organizationId: widget.organizationId,
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
        // Pending requests link
        Padding(
          padding: const EdgeInsets.all(16),
          child: GestureDetector(
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
                  '${_pendingEnrollments.length} pending requests',
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
        ),
        const Divider(height: 1),
        // Sub-tabs for enrollment views
        _buildEnrollmentViewTabs(),
        const Divider(height: 1),
        // Content based on selected view
        Expanded(child: _buildEnrollmentViewContent()),
      ],
    );
  }

  Widget _buildEnrollmentViewTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(child: _buildEnrollmentViewTab('Individual', 0)),
          const SizedBox(width: 8),
          Expanded(child: _buildEnrollmentViewTab('Months', 1)),
          const SizedBox(width: 8),
          Expanded(child: _buildEnrollmentViewTab('Years', 2)),
        ],
      ),
    );
  }

  Widget _buildEnrollmentViewTab(String label, int index) {
    final isActive = _selectedEnrollmentView == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedEnrollmentView = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? AppColors.primary : Colors.grey.shade300,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: isActive ? Colors.white : Colors.grey,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnrollmentViewContent() {
    switch (_selectedEnrollmentView) {
      case 0:
        return _buildIndividualEnrollmentsList();
      case 1:
        return _buildEnrollmentMonthsList();
      case 2:
        return _buildEnrollmentYearsList();
      default:
        return _buildIndividualEnrollmentsList();
    }
  }

  Widget _buildIndividualEnrollmentsList() {
    if (_approvedEnrollments.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.people_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                '0 members',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'No members enrolled yet.',
                style: TextStyle(color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
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
                '${_approvedEnrollments.length} members',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Members list
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadData,
            color: AppColors.primary,
            child: ListView.builder(
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

  Widget _buildEnrollmentMonthsList() {
    if (_enrollmentsByMonth.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.calendar_month, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                '0 enrollments',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'No enrollment data available.',
                style: TextStyle(color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // Header with total count
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.calendar_month, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                '${_enrollmentsByMonth.length} months',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Months list
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadData,
            color: AppColors.primary,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _enrollmentsByMonth.length,
              itemBuilder: (context, index) {
                final monthData = _enrollmentsByMonth[index];
                return _buildEnrollmentMonthCard(monthData);
              },
            ),
          ),
        ),
        // Generate report button
        _buildGenerateReportButton(),
      ],
    );
  }

  Widget _buildEnrollmentYearsList() {
    if (_enrollmentsByYear.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.date_range, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                '0 enrollments',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'No enrollment data available.',
                style: TextStyle(color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // Header with total count
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.date_range, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                '${_enrollmentsByYear.length} years',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Years list
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadData,
            color: AppColors.primary,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _enrollmentsByYear.length,
              itemBuilder: (context, index) {
                final yearData = _enrollmentsByYear[index];
                return _buildEnrollmentYearCard(yearData);
              },
            ),
          ),
        ),
        // Generate report button
        _buildGenerateReportButton(),
      ],
    );
  }

  Widget _buildEnrollmentMonthCard(EnrollmentByMonth monthData) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PeriodParticipantsScreen(
              organizationId: widget.organizationId,
              periodType: 'enrollment-month',
              month: monthData.month,
              periodName: monthData.monthName,
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
                monthData.monthName,
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
                '${monthData.membersCount}',
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

  Widget _buildEnrollmentYearCard(EnrollmentByYear yearData) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PeriodParticipantsScreen(
              organizationId: widget.organizationId,
              periodType: 'enrollment-year',
              year: yearData.year,
              periodName: '${yearData.year}',
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
                '${yearData.year}',
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
                '${yearData.membersCount}',
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

  Widget _buildEnrollmentCard(Membership membership) {
    final user = membership.user;
    final dateFormat = DateFormat('dd.MM.yyyy.');
    // Calculate months since enrollment
    final enrolledDate = membership.startDate ?? membership.createdAt;

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
        onTap: _isGeneratingReport ? null : _handleGenerateReport,
        child: Row(
          children: [
            if (_isGeneratingReport)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              )
            else
              const Icon(Icons.description_outlined, size: 20, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              _isGeneratingReport ? 'Generisanje izvještaja...' : 'Generate report',
              style: TextStyle(
                fontSize: 14,
                color: _isGeneratingReport ? AppColors.textMuted : AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
