import 'package:flutter/material.dart';
import '../../constants/constants.dart';
import '../../models/models.dart';
import '../../services/services.dart';

class EnrollmentApplicationsScreen extends StatefulWidget {
  final String organizationId;

  const EnrollmentApplicationsScreen({
    super.key,
    required this.organizationId,
  });

  @override
  State<EnrollmentApplicationsScreen> createState() => _EnrollmentApplicationsScreenState();
}

class _EnrollmentApplicationsScreenState extends State<EnrollmentApplicationsScreen> {
  final _organizationService = OrganizationService();

  List<Enrollment> _enrollments = [];
  Organization? _organization;
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
      final enrollmentsResponse = await _organizationService.getOrganizationEnrollments(
        widget.organizationId,
        status: EnrollmentStatus.pending,
      );

      if (!mounted) return;

      if (orgResponse.success && orgResponse.data != null) {
        _organization = orgResponse.data;
      }

      if (enrollmentsResponse.success && enrollmentsResponse.data != null) {
        setState(() {
          _enrollments = enrollmentsResponse.data!.data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = enrollmentsResponse.message ?? 'Greška pri učitavanju prijava';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Došlo je do greške. Pokušajte ponovo.';
        _isLoading = false;
      });
    }
  }

  Future<void> _approveEnrollment(Enrollment enrollment) async {
    try {
      final response = await _organizationService.approveEnrollment(enrollment.id);

      if (!mounted) return;

      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${enrollment.user?.name ?? 'Korisnik'} je prihvaćen'),
            backgroundColor: Colors.green,
          ),
        );
        _loadData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Greška pri prihvatanju'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Došlo je do greške'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _rejectEnrollment(Enrollment enrollment) async {
    try {
      final response = await _organizationService.rejectEnrollment(enrollment.id);

      if (!mounted) return;

      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${enrollment.user?.name ?? 'Korisnik'} je odbijen'),
            backgroundColor: Colors.orange,
          ),
        );
        _loadData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Greška pri odbijanju'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Došlo je do greške'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return 'prije ${difference.inDays} dana';
    } else if (difference.inHours > 0) {
      return 'prije ${difference.inHours} sati';
    } else {
      return 'upravo';
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
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Prijave za članstvo',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildOrganizationHeader(),
          const Divider(),
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildOrganizationHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.groups, color: AppColors.primary, size: 30),
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${_enrollments.length} na čekanju',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.orange,
              ),
            ),
          ),
        ],
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
            const SizedBox(height: AppDimensions.spacingDefault),
            Text(
              _error!,
              style: TextStyle(color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spacingDefault),
            TextButton(
              onPressed: _loadData,
              child: const Text('Pokušaj ponovo'),
            ),
          ],
        ),
      );
    }

    if (_enrollments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 48, color: AppColors.textMuted),
            const SizedBox(height: AppDimensions.spacingDefault),
            Text(
              'Nema prijava na čekanju',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _enrollments.length,
        itemBuilder: (context, index) {
          final enrollment = _enrollments[index];
          return _buildApplicationCard(enrollment);
        },
      ),
    );
  }

  Widget _buildApplicationCard(Enrollment enrollment) {
    final user = enrollment.user;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.grey.shade300,
                child: Icon(Icons.person, color: Colors.grey.shade600),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.name ?? 'Korisnik',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      user?.email ?? '',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Text(
                _getTimeAgo(enrollment.createdAt),
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),

          if (enrollment.message != null && enrollment.message!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                enrollment.message!,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
              ),
            ),
          ],

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _showRejectDialog(enrollment),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.red.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Odbij',
                    style: TextStyle(color: Colors.red.shade700),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _showAcceptDialog(enrollment),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Prihvati',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAcceptDialog(Enrollment enrollment) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Prihvati prijavu'),
          content: Text('Jeste li sigurni da želite prihvatiti prijavu korisnika ${enrollment.user?.name ?? ''}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Odustani', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _approveEnrollment(enrollment);
              },
              child: const Text('Prihvati', style: TextStyle(color: AppColors.primary)),
            ),
          ],
        );
      },
    );
  }

  void _showRejectDialog(Enrollment enrollment) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Odbij prijavu'),
          content: Text('Jeste li sigurni da želite odbiti prijavu korisnika ${enrollment.user?.name ?? ''}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Odustani', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _rejectEnrollment(enrollment);
              },
              child: const Text('Odbij', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
