import 'package:flutter/material.dart';
import '../../constants/constants.dart';
import '../../components/info_row.dart';
import '../../components/circle_icon_container.dart';
import '../../models/models.dart';
import '../../services/services.dart';
import 'edit_organization_profile_screen.dart';
import '../../components/bottom_nav_org.dart';
import '../auth/sign_in_screen.dart';

class OrganizationProfileScreen extends StatefulWidget {
  final String? organizationId;

  const OrganizationProfileScreen({super.key, this.organizationId});

  @override
  State<OrganizationProfileScreen> createState() => _OrganizationProfileScreenState();
}

class _OrganizationProfileScreenState extends State<OrganizationProfileScreen> {
  final _organizationService = OrganizationService();
  final _authService = AuthService();

  Organization? _organization;
  bool _isLoading = true;
  String? _error;

  String get _organizationId {
    // For organization users, get the organization ID from auth response
    if (widget.organizationId != null) {
      return widget.organizationId!;
    }
    // If logged in as organization, use organization.id
    if (_authService.isOrganization && _authService.currentAuth?.organization?.id != null) {
      return _authService.currentAuth!.organization!.id;
    }
    // Fallback to user id
    return _authService.currentUser?.id ?? '1';
  }

  @override
  void initState() {
    super.initState();
    _loadOrganization();
  }

  Future<void> _loadOrganization() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _organizationService.getOrganizationById(_organizationId);

      if (!mounted) return;

      if (response.success && response.data != null) {
        setState(() {
          _organization = response.data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response.message ?? 'Greska pri ucitavanju';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Doslo je do greske';
        _isLoading = false;
      });
    }
  }

  Future<void> _showLogoutDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Odjava',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: const Text(
          'Da li ste sigurni da se želite odjaviti?',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              backgroundColor: Colors.grey.shade200,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Ne',
              style: TextStyle(color: Colors.black87),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Da',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (result == true) {
      await _authService.logout();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const SignInScreen()),
        (route) => false,
      );
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
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
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
            icon: const Icon(Icons.logout, color: AppColors.primary),
            onPressed: _showLogoutDialog,
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavOrg(
        currentIndex: -1, // Profile is not in bottom nav
        organizationId: _organizationId,
      ),
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
              onPressed: _loadOrganization,
              child: const Text('Pokusaj ponovo'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.spacingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: CircleIconContainer(
              icon: _getCategoryIcon(_organization?.categoryName),
              iconColor: AppColors.orange,
              size: 120,
              iconSize: 60,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingLarge),
          ProfileField(
            label: 'Name',
            value: _organization?.name ?? '-',
            hasEdit: true,
            onEditTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditOrganizationProfileScreen(
                    organizationId: _organizationId,
                  ),
                ),
              ).then((_) => _loadOrganization());
            },
          ),
          const SizedBox(height: AppDimensions.spacingDefault),
          ProfileField(
            label: 'Category',
            value: _organization?.categoryName ?? '-',
          ),
          const SizedBox(height: AppDimensions.spacingDefault),
          ProfileField(
            label: 'Phone',
            value: _organization?.phone ?? '-',
          ),
          const SizedBox(height: AppDimensions.spacingDefault),
          ProfileField(
            label: 'Address',
            value: _organization?.address ?? '-',
          ),
          const SizedBox(height: AppDimensions.spacingDefault),
          ProfileField(
            label: 'E-mail',
            value: _organization?.email ?? '-',
          ),
          const SizedBox(height: AppDimensions.spacingDefault),
          ProfileField(
            label: 'About us',
            value: _organization?.description ?? '-',
            isMultiline: true,
          ),
        ],
      ),
    );
  }
}
