import 'package:flutter/material.dart';
import '../constants/constants.dart';
import 'admin_sidebar.dart';
import '../screens/admin_dashboard_screen.dart';
import '../screens/admin_organizations_screen.dart';
import '../screens/admin_users_screen.dart';
import '../screens/admin_events_screen.dart';
import '../screens/admin_categories_screen.dart';
import '../screens/admin_login_screen.dart';

class AdminLayout extends StatelessWidget {
  final String currentRoute;
  final Widget child;

  const AdminLayout({
    super.key,
    required this.currentRoute,
    required this.child,
  });

  void _handleNavigation(BuildContext context, String route) {
    if (route == 'logout') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AdminLoginScreen()),
      );
      return;
    }

    switch (route) {
      case 'dashboard':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
        );
        break;
      case 'organizations':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminOrganizationsScreen()),
        );
        break;
      case 'users':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminUsersScreen()),
        );
        break;
      case 'events':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminEventsScreen()),
        );
        break;
      case 'categories':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminCategoriesScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          AdminSidebar(
            currentRoute: currentRoute,
            onNavigate: (route) => _handleNavigation(context, route),
          ),
          Expanded(
            child: child,
          ),
        ],
      ),
    );
  }
}
