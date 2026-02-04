import 'package:flutter/material.dart';
import '../../constants/constants.dart';
import '../../components/actime_button.dart';
import '../../components/event_card.dart';
import '../../components/info_row.dart';
import '../../components/confirmation_dialog.dart';
import '../../models/models.dart';
import '../../services/services.dart';
import '../auth/sign_in_screen.dart';
import '../clubs/club_detail_screen.dart';
import 'edit_user_profile_screen.dart';
import 'change_password_screen.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen>
    with WidgetsBindingObserver {
  final _authService = AuthService();
  final _userService = UserService();

  User? _user;
  List<Enrollment> _memberships = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadUserProfile();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh data when app comes back to foreground
      _loadUserProfile();
    }
  }

  Future<void> _loadUserProfile() async {
    setState(() => _isLoading = true);

    try {
      final response = await _userService.getCurrentUser();

      if (!mounted) return;

      if (response.success && response.data != null) {
        setState(() {
          _user = response.data;
        });
        // Load user memberships
        await _loadMemberships();
      }

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMemberships() async {
    if (_user == null) return;

    try {
      final response = await _userService.getUserMemberships();

      if (!mounted) return;

      if (response.success && response.data != null) {
        setState(() {
          _memberships = response.data!.data;
        });
      }
    } catch (e) {
      // Silently fail - memberships are optional display
    }
  }

  Future<void> _handleLogout() async {
    await _authService.logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const SignInScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Profil',
          style: TextStyle(
            color: AppColors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditUserProfileScreen(),
                ),
              ).then((_) => _loadUserProfile());
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.spacingLarge),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: AppColors.borderLight,
                          backgroundImage: _user?.avatar != null
                              ? NetworkImage(_user!.avatar!)
                              : null,
                          child: _user?.avatar == null
                              ? Icon(
                                  Icons.person,
                                  size: 50,
                                  color: AppColors.textMuted,
                                )
                              : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.spacingLarge),
                    Text(
                      _user?.name ?? 'Korisnik',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingXLarge),
                    ProfileInfoRow(
                      icon: Icons.email_outlined,
                      text: _user?.email ?? '',
                    ),
                    if (_user?.bio != null && _user!.bio!.isNotEmpty) ...[
                      const SizedBox(height: AppDimensions.spacingDefault),
                      ProfileInfoRow(
                        icon: Icons.info_outlined,
                        text: _user!.bio!,
                      ),
                    ],
                    const SizedBox(height: AppDimensions.spacingXLarge),
                    _buildMyClubsSection(),
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
                      label: 'Odjavi se',
                      icon: Icons.logout,
                      borderColor: AppColors.red,
                      textColor: AppColors.red,
                      onPressed: () => _showLogoutDialog(context),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildMyClubsSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.spacingDefault),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Moji klubovi',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingDefault),
          if (_memberships.isEmpty)
            Text(
              'Niste član nijednog kluba',
              style: TextStyle(color: AppColors.textMuted),
            )
          else
            ..._memberships.map((membership) {
              final org = membership.organization;
              return Padding(
                padding: const EdgeInsets.only(
                  bottom: AppDimensions.spacingMedium,
                ),
                child: ClubItemSmall(
                  name: org?.name ?? 'Nepoznat klub',
                  sport: org?.categoryName ?? 'Klub',
                  imageUrl: org?.logoUrl,
                  onTap: org != null
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ClubDetailScreen(organizationId: org.id),
                            ),
                          );
                        }
                      : null,
                ),
              );
            }),
        ],
      ),
    );
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    final confirmed = await ConfirmationDialog.showLogout(context: context);
    if (confirmed == true) {
      _handleLogout();
    }
  }
}
