import 'package:flutter/material.dart';
import '../../constants/constants.dart';
import '../../models/models.dart';
import '../../services/services.dart';

class PeriodParticipantsScreen extends StatefulWidget {
  final String organizationId;
  final String periodType; // 'month', 'year', 'enrollment-month', 'enrollment-year'
  final int? month;
  final int? year;
  final String periodName;

  const PeriodParticipantsScreen({
    super.key,
    required this.organizationId,
    required this.periodType,
    this.month,
    this.year,
    required this.periodName,
  });

  @override
  State<PeriodParticipantsScreen> createState() => _PeriodParticipantsScreenState();
}

class _PeriodParticipantsScreenState extends State<PeriodParticipantsScreen> {
  final _organizationService = OrganizationService();
  final _pdfReportService = PdfReportService();

  List<User> _participants = [];
  bool _isLoading = true;
  bool _isGeneratingReport = false;
  String? _error;
  String? _organizationName;
  String? _organizationLogoUrl;

  @override
  void initState() {
    super.initState();
    _loadParticipants();
  }

  Future<void> _loadParticipants() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      ApiResponse<List<User>> response;

      if (widget.periodType == 'month' && widget.month != null) {
        response = await _organizationService.getParticipantsByMonth(
          widget.organizationId,
          widget.month!,
        );
      } else if (widget.periodType == 'year' && widget.year != null) {
        response = await _organizationService.getParticipantsByYear(
          widget.organizationId,
          widget.year!,
        );
      } else if (widget.periodType == 'enrollment-month' && widget.month != null) {
        response = await _organizationService.getMembersByMonth(
          widget.organizationId,
          widget.month!,
        );
      } else if (widget.periodType == 'enrollment-year' && widget.year != null) {
        response = await _organizationService.getMembersByYear(
          widget.organizationId,
          widget.year!,
        );
      } else {
        throw Exception('Invalid period type');
      }

      if (!mounted) return;

      if (response.success && response.data != null) {
        setState(() {
          _participants = response.data!;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response.message ?? 'Failed to load participants';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _generateReport() async {
    setState(() => _isGeneratingReport = true);

    try {
      // Fetch organization details if not already loaded
      if (_organizationName == null) {
        final orgResponse = await _organizationService.getOrganizationById(widget.organizationId);
        if (orgResponse.success && orgResponse.data != null) {
          _organizationName = orgResponse.data!.name;
          _organizationLogoUrl = orgResponse.data!.logoUrl;
        } else {
          throw Exception('Failed to load organization details');
        }
      }

      final response = await _pdfReportService.generatePeriodParticipantsReport(
        organizationName: _organizationName!,
        periodName: widget.periodName,
        organizationLogoUrl: _organizationLogoUrl,
        participants: _participants,
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.periodName,
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
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
              onPressed: _loadParticipants,
              child: const Text('Try again'),
            ),
          ],
        ),
      );
    }

    if (_participants.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.people_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No ${_getLabel()} found',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.people, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                '${_participants.length} ${_getLabel()}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        // Participants list
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadParticipants,
            color: AppColors.primary,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _participants.length,
              itemBuilder: (context, index) {
                final participant = _participants[index];
                return _buildParticipantCard(participant);
              },
            ),
          ),
        ),
        // Generate report button
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Colors.grey.shade200)),
          ),
          child: ElevatedButton.icon(
            onPressed: _isGeneratingReport ? null : _generateReport,
            icon: _isGeneratingReport
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.picture_as_pdf),
            label: Text(_isGeneratingReport ? 'Generisanje...' : 'Generiši izvještaj'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildParticipantCard(User participant) {
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
          // Avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            backgroundImage: participant.profileImageUrl != null && participant.profileImageUrl!.isNotEmpty
                ? NetworkImage(participant.profileImageUrl!)
                : null,
            child: participant.profileImageUrl == null || participant.profileImageUrl!.isEmpty
                ? Text(
                    participant.name.isNotEmpty ? participant.name[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  participant.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
                if (participant.email.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    participant.email,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getLabel() {
    if (widget.periodType.startsWith('enrollment')) {
      return 'members';
    }
    return 'participants';
  }
}
