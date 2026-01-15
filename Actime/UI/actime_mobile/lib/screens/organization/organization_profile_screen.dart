import 'package:flutter/material.dart';
import '../../constants/constants.dart';
import '../../components/info_row.dart';
import '../../components/circle_icon_container.dart';
import 'edit_organization_profile_screen.dart';
import '../events/events_list_screen.dart';

class OrganizationProfileScreen extends StatelessWidget {
  const OrganizationProfileScreen({super.key});

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
            icon: const Icon(Icons.person_outline, color: AppColors.primary),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.spacingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleIconContainer(
                icon: Icons.sports_volleyball,
                iconColor: AppColors.orange,
                size: 120,
                iconSize: 60,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingLarge),
            ProfileField(
              label: 'Name',
              value: 'Student',
              hasEdit: true,
              onEditTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EditOrganizationProfileScreen()),
                );
              },
            ),
            const SizedBox(height: AppDimensions.spacingDefault),
            const ProfileField(label: 'Category', value: 'Volleyball'),
            const SizedBox(height: AppDimensions.spacingDefault),
            const ProfileField(label: 'Phone', value: '+12027953213'),
            const SizedBox(height: AppDimensions.spacingDefault),
            const ProfileField(label: 'Address', value: '1894 Arlington Avenue'),
            const SizedBox(height: AppDimensions.spacingDefault),
            const ProfileField(label: 'E-mail', value: 'club@volleyball.com'),
            const SizedBox(height: AppDimensions.spacingDefault),
            const ProfileField(
              label: 'About us',
              value: 'Practice yoga postures while learning about how yoga can be used to manage stress, improve the mind-body connection, and increase strength and flexibility.',
              isMultiline: true,
            ),
            const SizedBox(height: AppDimensions.spacingXLarge),
            _buildNavigationItems(context),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationItems(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildNavItem(
          icon: Icons.event_outlined,
          label: 'My events',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const EventsListScreen()),
            );
          },
        ),
        _buildNavItem(
          icon: Icons.photo_library_outlined,
          label: 'Gallery',
        ),
        _buildNavItem(
          icon: Icons.people_outline,
          label: 'People',
        ),
      ],
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(height: AppDimensions.spacingXSmall),
          Text(
            label,
            style: const TextStyle(color: AppColors.primary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
