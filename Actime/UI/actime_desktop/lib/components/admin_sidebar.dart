import 'package:flutter/material.dart';

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
      width: 250,
      color: Colors.white,
      child: Column(
        children: [
          // Logo Section
          Container(
            padding: const EdgeInsets.all(24),
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF0D7C8C),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'Actime',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),

          // Welcome Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome back, Mr. Administrator',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Hello, Admin! Check out what\'s next',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
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
            padding: const EdgeInsets.all(16),
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
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF0D7C8C).withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isActive ? const Color(0xFF0D7C8C) : Colors.grey[600],
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                color: isActive ? const Color(0xFF0D7C8C) : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
