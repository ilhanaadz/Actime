import 'dart:async';
import 'package:flutter/material.dart';
import '../../constants/constants.dart';
import '../../components/info_row.dart';
import '../../components/circle_icon_container.dart';
import '../../components/notification_badge.dart';
import '../../components/actime_button.dart';
import '../../models/models.dart';
import '../../services/services.dart';
import 'edit_organization_profile_screen.dart';
import '../../components/bottom_nav_org.dart';
import '../auth/sign_in_screen.dart';
import '../notifications/notifications_screen.dart';
import '../user/change_password_screen.dart';

class OrganizationProfileScreen extends StatefulWidget {
  final String? organizationId;

  const OrganizationProfileScreen({super.key, this.organizationId});

  @override
  State<OrganizationProfileScreen> createState() =>
      _OrganizationProfileScreenState();
}

class _OrganizationProfileScreenState extends State<OrganizationProfileScreen> {
  final _organizationService = OrganizationService();
  final _authService = AuthService();
  final _signalRService = SignalRService();

  Organization? _organization;
  bool _isLoading = true;
  String? _error;


  String get _organizationId {
    // Priority 1: If logged in as organization, use organization.id from auth
    if (_authService.isOrganization &&
        _authService.currentAuth?.organization?.id != null) {
      return _authService.currentAuth!.organization!.id;
    }
    // Priority 2: Use organizationId parameter if provided (for viewing other organizations)
    if (widget.organizationId != null) {
      return widget.organizationId!;
    }
    // Fallback - should not reach here in normal flow
    return '1';
  }

  @override
  void initState() {
    super.initState();
    _loadOrganization();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadOrganization() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _organizationService.getOrganizationById(
        _organizationId,
      );

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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Odjava',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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
            child: const Text('Ne', style: TextStyle(color: Colors.black87)),
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
            child: const Text('Da', style: TextStyle(color: Colors.white)),
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
            child: Stack(
              children: [
                CircleAvatar(
                  key: ValueKey(_organization?.logoUrl ?? 'no-logo'),
                  radius: 50,
                  backgroundColor: AppColors.borderLight,
                  backgroundImage: _organization?.logoUrl != null
                      ? NetworkImage(_organization!.logoUrl!)
                      : null,
                  child: _organization?.logoUrl == null
                      ? Icon(Icons.groups, size: 50, color: AppColors.textMuted)
                      : null,
                ),
              ],
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
          ProfileField(label: 'Phone', value: _organization?.phone ?? '-'),
          const SizedBox(height: AppDimensions.spacingDefault),
          ProfileField(label: 'Address', value: _organization?.address ?? '-'),
          const SizedBox(height: AppDimensions.spacingDefault),
          ProfileField(label: 'E-mail', value: _organization?.email ?? '-'),
          const SizedBox(height: AppDimensions.spacingDefault),
          ProfileField(
            label: 'About us',
            value: _organization?.description ?? '-',
            isMultiline: true,
          ),
          const SizedBox(height: AppDimensions.spacingXLarge),
          ActimeOutlinedButton(
            label: 'Promijeni lozinku',
            icon: Icons.lock_outline,
            borderColor: AppColors.primary,
            textColor: AppColors.primary,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChangePasswordScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: AppDimensions.spacingDefault),
          ActimeOutlinedButton(
            label: 'Obriši nalog',
            icon: Icons.delete_forever_outlined,
            borderColor: AppColors.red,
            textColor: AppColors.red,
            onPressed: _showDeleteAccountDialog,
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteAccountDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Obriši nalog'),
        content: const Text(
          'Da li ste sigurni da želite trajno obrisati nalog vaše organizacije?\n\n'
          'Ova akcija je nepovratna i svi podaci organizacije će biti obrisani.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Odustani'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.red),
            child: const Text('Obriši nalog'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );

      try {
        final response = await _authService.deleteMyAccount();

        if (!mounted) return;

        // Close loading dialog
        Navigator.pop(context);

        if (response.success) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const SignInScreen()),
            (route) => false,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message ?? 'Greška pri brisanju naloga'),
              backgroundColor: AppColors.red,
            ),
          );
        }
      } catch (e) {
        if (!mounted) return;

        // Close loading dialog
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Došlo je do greške pri brisanju naloga'),
            backgroundColor: AppColors.red,
          ),
        );
      }
    }
  }
}
