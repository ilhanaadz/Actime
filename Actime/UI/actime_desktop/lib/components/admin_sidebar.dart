import 'package:flutter/material.dart';
import '../constants/constants.dart';

class AdminSidebar extends StatelessWidget {
  final String currentRoute;
  final Function(String) onNavigate;

  const AdminSidebar({
    super.key,
    required this.currentRoute,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppDimensions.sidebarWidth,
      color: AppColors.surface,
      child: Column(
        children: [
          // Logo Section
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingXL),
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingL,
                vertical: AppDimensions.paddingS,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
              ),
              child: const Text(
                'Actime',
                style: TextStyle(
                  color: AppColors.textOnPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),

          // Welcome Section
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingXL,
              vertical: AppDimensions.paddingS,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back, Mr. Administrator',
                  style: AppTextStyles.heading4.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingXS),
                Text(
                  'Hello, Admin! Check out what\'s next',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppDimensions.spacingXL),

          // Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
              children: [
                _buildNavItem(
                  icon: Icons.dashboard_outlined,
                  label: 'Dashboard',
                  route: 'dashboard',
                ),
                _buildNavItem(
                  icon: Icons.people_outline,
                  label: 'Users',
                  route: 'users',
                ),
                _buildNavItem(
                  icon: Icons.apartment_outlined,
                  label: 'Organizations',
                  route: 'organizations',
                ),
                _buildNavItem(
                  icon: Icons.event_outlined,
                  label: 'Events',
                  route: 'events',
                ),
                _buildNavItem(
                  icon: Icons.category_outlined,
                  label: 'Categories',
                  route: 'categories',
                ),
              ],
            ),
          ),

          // Sign Out
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            child: _buildNavItem(
              icon: Icons.logout,
              label: 'Sign out',
              route: 'logout',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required String route,
  }) {
    final isActive = currentRoute == route;

    return InkWell(
      onTap: () => onNavigate(route),
      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppDimensions.spacingXS),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingL,
          vertical: AppDimensions.paddingM,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: AppDimensions.iconM,
              color: isActive ? AppColors.primary : AppColors.grey600,
            ),
            const SizedBox(width: AppDimensions.spacingM),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                color: isActive ? AppColors.primary : AppColors.grey700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
