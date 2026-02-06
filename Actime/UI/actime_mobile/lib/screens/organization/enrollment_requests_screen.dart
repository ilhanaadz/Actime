import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../constants/constants.dart';
import '../../models/models.dart';
import '../../services/services.dart';

class EnrollmentRequestsScreen extends StatefulWidget {
  final String organizationId;

  const EnrollmentRequestsScreen({
    super.key,
    required this.organizationId,
  });

  @override
  State<EnrollmentRequestsScreen> createState() =>
      _EnrollmentRequestsScreenState();
}

class _EnrollmentRequestsScreenState extends State<EnrollmentRequestsScreen> {
  final _organizationService = OrganizationService();

  List<Membership> _pendingEnrollments = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadEnrollments();
  }

  Future<void> _loadEnrollments() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _organizationService.getOrganizationEnrollments(
        widget.organizationId,
        status: EnrollmentStatus.pending,
      );

      if (!mounted) return;

      setState(() {
        if (response.success && response.data != null) {
          _pendingEnrollments = response.data!.data;
        }
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Error loading requests';
        _isLoading = false;
      });
    }
  }

  Future<void> _approveEnrollment(Membership membership) async {
    final response = await _organizationService.approveEnrollment(membership.id.toString());
    if (response.success) {
      _loadEnrollments();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Zahtjev je uspješno odobren'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _rejectEnrollment(Membership membership) async {
    final response = await _organizationService.rejectEnrollment(membership.id.toString());
    if (response.success) {
      _loadEnrollments();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Zahtjev je uspješno odbijen'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
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
        title: const Text(
          'Enrollment requests',
          style: TextStyle(
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
              onPressed: _loadEnrollments,
              child: const Text('Try again'),
            ),
          ],
        ),
      );
    }

    if (_pendingEnrollments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 48, color: AppColors.textMuted),
            const SizedBox(height: 16),
            Text(
              'No pending requests',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadEnrollments,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _pendingEnrollments.length,
        itemBuilder: (context, index) {
          final membership = _pendingEnrollments[index];
          return _buildEnrollmentRequestCard(membership);
        },
      ),
    );
  }

  Widget _buildEnrollmentRequestCard(Membership membership) {
    final user = membership.user;
    final dateFormat = DateFormat('dd.MM.yyyy.');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.name ?? 'Unknown',
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
                    user?.email ?? '',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      'Student',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '22 years',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  dateFormat.format(membership.createdAt),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          // Action buttons
          Column(
            children: [
              _buildActionButton(
                icon: Icons.check,
                color: Colors.green,
                onTap: () => _approveEnrollment(membership),
              ),
              const SizedBox(height: 8),
              _buildActionButton(
                icon: Icons.close,
                color: Colors.red,
                onTap: () => _rejectEnrollment(membership),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 2),
        ),
        child: Icon(
          icon,
          color: color,
          size: 20,
        ),
      ),
    );
  }
}
