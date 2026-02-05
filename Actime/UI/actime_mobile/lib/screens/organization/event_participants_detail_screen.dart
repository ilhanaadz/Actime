import 'package:flutter/material.dart';
import '../../constants/constants.dart';
import '../../models/models.dart';
import '../../services/services.dart';

class EventParticipantsDetailScreen extends StatefulWidget {
  final String eventId;
  final String eventName;
  final String? organizationId;

  const EventParticipantsDetailScreen({
    super.key,
    required this.eventId,
    required this.eventName,
    this.organizationId,
  });

  @override
  State<EventParticipantsDetailScreen> createState() =>
      _EventParticipantsDetailScreenState();
}

class _EventParticipantsDetailScreenState
    extends State<EventParticipantsDetailScreen> {
  final _eventService = EventService();
  final _pdfReportService = PdfReportService();
  final _organizationService = OrganizationService();

  List<User> _participants = [];
  bool _isLoading = true;
  bool _isGeneratingReport = false;
  String? _error;
  String? _organizationId;
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
      final response = await _eventService.getEventParticipants(widget.eventId);

      if (!mounted) return;

      setState(() {
        if (response.success && response.data != null) {
          _participants = response.data!;
        }
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Error loading participants';
        _isLoading = false;
      });
    }
  }

  Future<void> _generateReport() async {
    if (widget.organizationId == null) {
      _showErrorSnackbar('Organization information not available');
      return;
    }

    setState(() => _isGeneratingReport = true);

    try {
      // Fetch organization details if not already loaded
      if (_organizationName == null) {
        final orgResponse = await _organizationService.getOrganizationById(widget.organizationId!);
        if (orgResponse.success && orgResponse.data != null) {
          _organizationName = orgResponse.data!.name;
          _organizationLogoUrl = orgResponse.data!.logoUrl;
        } else {
          throw Exception('Failed to load organization details');
        }
      }

      final response = await _pdfReportService.generateEventParticipantsReport(
        organizationName: _organizationName!,
        eventName: widget.eventName,
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
          icon: const Icon(Icons.close, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.eventName,
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: _buildContent(),
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
            Icon(Icons.people_outline, size: 48, color: AppColors.textMuted),
            const SizedBox(height: 16),
            Text(
              'No participants yet',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadParticipants,
            color: AppColors.primary,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _participants.length,
              itemBuilder: (context, index) {
                final participant = _participants[index];
                return _buildParticipantCard(participant);
              },
            ),
          ),
        ),
        // Generate report button
        if (widget.organizationId != null)
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
    final user = participant;

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
          CircleAvatar(
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            radius: 20,
            child: Text(
              user.name.isNotEmpty == true ? user.name[0].toUpperCase() : '?',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name.isNotEmpty == true ? user.name : 'Unknown',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    user.email.isNotEmpty == true ? user.email : '',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
