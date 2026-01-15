import 'package:flutter/material.dart';
import '../../constants/constants.dart';
import '../../components/circle_icon_container.dart';
import '../../components/info_row.dart';
import '../../components/actime_button.dart';
import 'enrollment_application_screen.dart';

class ClubDetailScreen extends StatelessWidget {
  const ClubDetailScreen({super.key});

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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: AppDimensions.spacingLarge),
              _buildTitleSection(),
              const SizedBox(height: AppDimensions.spacingLarge),
              const InfoRow(icon: Icons.phone_outlined, text: '+12027953213'),
              const SizedBox(height: AppDimensions.spacingMedium),
              const InfoRow(icon: Icons.email_outlined, text: 'club@volleyball.com'),
              const SizedBox(height: AppDimensions.spacingMedium),
              const InfoRow(icon: Icons.location_on_outlined, text: '1894 Arlington Avenue'),
              const SizedBox(height: AppDimensions.spacingLarge),
              _buildAboutSection(),
              const SizedBox(height: AppDimensions.spacingXLarge),
              ActimePrimaryButton(
                label: 'Enrollment application',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const EnrollmentApplicationScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        CircleIconContainer.xLarge(
          icon: Icons.sports_volleyball,
          iconColor: AppColors.orange,
        ),
        const SizedBox(width: AppDimensions.spacingDefault),
        Stack(
          children: [
            CircleIconContainer.xLarge(
              icon: Icons.sports_volleyball,
              iconColor: AppColors.grey,
              backgroundColor: AppColors.inputBackground,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: CircleBadge(icon: Icons.add),
            ),
          ],
        ),
        const Spacer(),
        Row(
          children: [
            const Text(
              '89',
              style: TextStyle(
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
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Student',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: AppDimensions.spacingXSmall),
            Text(
              'Volleyball',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.favorite_border, color: AppColors.primary),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildAboutSection() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: AppDimensions.spacingMedium),
        Text(
          'Practice yoga postures while learning about how yoga can be used to manage stress, improve the mind-body connection, and increase strength and flexibility.',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textPrimary,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
