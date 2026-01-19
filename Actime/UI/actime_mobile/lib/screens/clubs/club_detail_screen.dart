import 'package:flutter/material.dart';
import '../../constants/constants.dart';
import '../../components/circle_icon_container.dart';
import '../../components/info_row.dart';
import '../../components/actime_button.dart';
import '../../models/models.dart';
import '../../services/services.dart';
import '../auth/sign_in_screen.dart';
import 'enrollment_application_screen.dart';

class ClubDetailScreen extends StatefulWidget {
  final String organizationId;
  final bool isLoggedIn;

  const ClubDetailScreen({
    super.key,
    required this.organizationId,
    this.isLoggedIn = true,
  });

  @override
  State<ClubDetailScreen> createState() => _ClubDetailScreenState();
}

class _ClubDetailScreenState extends State<ClubDetailScreen> {
  final _organizationService = OrganizationService();
  final _userService = UserService();

  Organization? _organization;
  bool _isLoading = true;
  bool _isCancelling = false;
  String? _error;

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
      final response = await _organizationService.getOrganizationById(
        widget.organizationId,
      );

      if (!mounted) return;

      if (response.success && response.data != null) {
        setState(() {
          _organization = response.data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response.message ?? 'Greška pri učitavanju kluba';
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

  Future<void> _handleCancelMembership() async {
    if (_organization == null) return;

    setState(() => _isCancelling = true);

    try {
      // Note: This requires the enrollment ID, which we'd need from the API
      // For now, we'll use the organization ID as a placeholder
      final response = await _userService.cancelMembership(_organization!.id);

      if (!mounted) return;

      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Članstvo je uspješno otkazano.'),
            backgroundColor: Colors.green,
          ),
        );
        // Refresh organization data
        _loadOrganization();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Greška pri otkazivanju članstva'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Došlo je do greške. Pokušajte ponovo.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isCancelling = false);
      }
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

  Color _getCategoryColor(String? categoryName) {
    switch (categoryName?.toLowerCase()) {
      case 'sport':
        return AppColors.red;
      case 'kultura':
        return Colors.purple;
      case 'edukacija':
        return Colors.blue;
      case 'zdravlje':
        return AppColors.red;
      case 'muzika':
        return AppColors.orange;
      case 'tehnologija':
        return Colors.grey;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.black),
          onPressed: () => Navigator.pop(context),
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
            const SizedBox(height: AppDimensions.spacingDefault),
            Text(
              _error!,
              style: TextStyle(color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spacingDefault),
            TextButton(
              onPressed: _loadOrganization,
              child: const Text('Pokušaj ponovo'),
            ),
          ],
        ),
      );
    }

    if (_organization == null) {
      return const Center(
        child: Text('Klub nije pronađen'),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: AppDimensions.spacingLarge),
            _buildTitleSection(),
            const SizedBox(height: AppDimensions.spacingLarge),
            if (_organization!.phone != null && _organization!.phone!.isNotEmpty)
              InfoRow(icon: Icons.phone_outlined, text: _organization!.phone!),
            if (_organization!.phone != null && _organization!.phone!.isNotEmpty)
              const SizedBox(height: AppDimensions.spacingMedium),
            if (_organization!.email != null && _organization!.email!.isNotEmpty)
              InfoRow(icon: Icons.email_outlined, text: _organization!.email!),
            if (_organization!.email != null && _organization!.email!.isNotEmpty)
              const SizedBox(height: AppDimensions.spacingMedium),
            if (_organization!.address != null && _organization!.address!.isNotEmpty)
              InfoRow(icon: Icons.location_on_outlined, text: _organization!.address!),
            if (_organization!.address != null && _organization!.address!.isNotEmpty)
              const SizedBox(height: AppDimensions.spacingMedium),
            InfoRow(
              icon: Icons.event,
              text: '${_organization!.eventsCount} događaja',
            ),
            const SizedBox(height: AppDimensions.spacingLarge),
            _buildAboutSection(),
            const SizedBox(height: AppDimensions.spacingXLarge),
            _buildMembershipButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        CircleIconContainer.xLarge(
          icon: _getCategoryIcon(_organization!.categoryName),
          iconColor: _getCategoryColor(_organization!.categoryName),
        ),
        const SizedBox(width: AppDimensions.spacingDefault),
        if (_organization!.isVerified)
          Stack(
            children: [
              CircleIconContainer.xLarge(
                icon: Icons.verified,
                iconColor: AppColors.primary,
                backgroundColor: AppColors.inputBackground,
              ),
            ],
          ),
        const Spacer(),
        Row(
          children: [
            Text(
              _organization!.membersCount.toString(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: AppDimensions.spacingXSmall),
            const Icon(Icons.person_outline, size: 18, color: AppColors.textSecondary),
          ],
        ),
      ],
    );
  }

  Widget _buildTitleSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _organization!.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppDimensions.spacingXSmall),
              Text(
                _organization!.categoryName ?? 'Klub',
                style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.favorite_border, color: AppColors.primary),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildAboutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'O klubu',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingMedium),
        Text(
          _organization!.description ?? 'Nema opisa za ovaj klub.',
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textPrimary,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildMembershipButton() {
    if (_isCancelling) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    // Not logged in - show button that redirects to login
    if (!widget.isLoggedIn) {
      return ActimePrimaryButton(
        label: 'Prijava za članstvo',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SignInScreen()),
          );
        },
      );
    }

    // Already a member - show cancel button
    if (_organization!.isMember) {
      return ActimeOutlinedButton(
        label: 'Otkaži članstvo',
        onPressed: _handleCancelMembership,
      );
    }

    // Not a member - show join button
    return ActimePrimaryButton(
      label: 'Prijava za članstvo',
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EnrollmentApplicationScreen(
              organizationId: _organization!.id,
              organizationName: _organization!.name,
            ),
          ),
        ).then((_) => _loadOrganization());
      },
    );
  }
}
