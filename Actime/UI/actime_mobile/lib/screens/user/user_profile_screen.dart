import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../components/info_row.dart';
import '../../components/actime_button.dart';
import '../../components/event_card.dart';
import '../../components/confirmation_dialog.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

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
          'Profile',
          style: TextStyle(
            color: AppColors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.spacingLarge),
          child: Column(
            children: [
              _buildProfilePicture(),
              const SizedBox(height: AppSizes.spacingLarge),
              const Text(
                'John Doe',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppSizes.spacingXLarge),
              const ProfileInfoRow(icon: Icons.email_outlined, text: 'john.doe@email.com'),
              const SizedBox(height: AppSizes.spacingDefault),
              const ProfileInfoRow(icon: Icons.phone_outlined, text: '+387 62 123 456'),
              const SizedBox(height: AppSizes.spacingDefault),
              const ProfileInfoRow(icon: Icons.cake_outlined, text: '25 years old'),
              const SizedBox(height: AppSizes.spacingDefault),
              const ProfileInfoRow(icon: Icons.school_outlined, text: 'Student'),
              const SizedBox(height: AppSizes.spacingXLarge),
              _buildMyClubsSection(),
              const SizedBox(height: AppSizes.spacingXLarge),
              ActimeOutlinedButton(
                label: 'Logout',
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
          child: Icon(Icons.person, size: 50, color: AppColors.textMuted),
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
      padding: const EdgeInsets.all(AppSizes.spacingDefault),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusLarge),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'My Clubs',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSizes.spacingDefault),
          ClubItemSmall(
            name: 'Student',
            sport: 'Volleyball',
            icon: Icons.sports_volleyball,
            iconColor: AppColors.orange,
          ),
          const SizedBox(height: AppSizes.spacingMedium),
          ClubItemSmall(
            name: 'Velež',
            sport: 'Football',
            icon: Icons.sports_soccer,
            iconColor: AppColors.red,
          ),
        ],
      ),
    );
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    final confirmed = await ConfirmationDialog.showLogout(context: context);
    if (confirmed == true) {
      // Navigate to login
    }
  }
}
