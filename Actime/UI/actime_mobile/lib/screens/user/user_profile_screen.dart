import 'package:flutter/material.dart';
import '../../constants/constants.dart';
import '../../components/actime_button.dart';
import '../../components/event_card.dart';
import '../../components/info_row.dart';
import '../../components/confirmation_dialog.dart';
import '../../models/models.dart';
import '../../services/services.dart';
import '../auth/sign_in_screen.dart';
import 'edit_user_profile_screen.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _authService = AuthService();
  final _userService = UserService();

  User? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() => _isLoading = true);

    try {
      final response = await _userService.getCurrentUser();

      if (!mounted) return;

      if (response.success && response.data != null) {
        setState(() {
          _user = response.data;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
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
                MaterialPageRoute(builder: (context) => const EditUserProfileScreen()),
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
                    _buildProfilePicture(),
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
                    if (_user?.phone != null && _user!.phone!.isNotEmpty) ...[
                      const SizedBox(height: AppDimensions.spacingDefault),
                      ProfileInfoRow(
                        icon: Icons.phone_outlined,
                        text: _user!.phone!,
                      ),
                    ],
                    if (_user?.bio != null && _user!.bio!.isNotEmpty) ...[
                      const SizedBox(height: AppDimensions.spacingDefault),
                      ProfileInfoRow(
                        icon: Icons.info_outlined,
                        text: _user!.bio!,
                      ),
                    ],
                    const SizedBox(height: AppDimensions.spacingDefault),
                    ProfileInfoRow(
                      icon: Icons.event,
                      text: '${_user?.eventsCount ?? 0} događaja',
                    ),
                    const SizedBox(height: AppDimensions.spacingDefault),
                    ProfileInfoRow(
                      icon: Icons.groups,
                      text: '${_user?.organizationsCount ?? 0} klubova',
                    ),
                    const SizedBox(height: AppDimensions.spacingXLarge),
                    _buildMyClubsSection(),
                    const SizedBox(height: AppDimensions.spacingXLarge),
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

  Widget _buildProfilePicture() {
    return Stack(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: AppColors.borderLight,
          backgroundImage: _user?.avatar != null ? NetworkImage(_user!.avatar!) : null,
          child: _user?.avatar == null
              ? Icon(Icons.person, size: 50, color: AppColors.textMuted)
              : null,
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.camera_alt, size: 16, color: AppColors.white),
          ),
        ),
      ],
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
          if (_user?.organizationsCount == 0)
            Text(
              'Niste član nijednog kluba',
              style: TextStyle(color: AppColors.textMuted),
            )
          else ...[
            ClubItemSmall(
              name: 'Planinarsko društvo',
              sport: 'Sport',
              icon: Icons.hiking,
              iconColor: AppColors.orange,
            ),
            const SizedBox(height: AppDimensions.spacingMedium),
            ClubItemSmall(
              name: 'IT Hub Sarajevo',
              sport: 'Edukacija',
              icon: Icons.computer,
              iconColor: AppColors.primary,
            ),
          ],
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
