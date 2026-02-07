import 'package:flutter/material.dart';
import '../constants/constants.dart';
import '../services/services.dart';
import 'admin_sidebar.dart';
import '../screens/admin_dashboard_screen.dart';
import '../screens/admin_organizations_screen.dart';
import '../screens/admin_users_screen.dart';
import '../screens/admin_events_screen.dart';
import '../screens/admin_categories_screen.dart';
import '../screens/admin_login_screen.dart';

class AdminLayout extends StatefulWidget {
  final String currentRoute;
  final Widget child;

  const AdminLayout({
    super.key,
    required this.currentRoute,
    required this.child,
  });

  @override
  State<AdminLayout> createState() => _AdminLayoutState();
}

class _AdminLayoutState extends State<AdminLayout> {
  final _authService = AuthService();
  bool _isCheckingAuth = true;

  @override
  void initState() {
    super.initState();
    _checkAdminAccess();
  }

  Future<void> _checkAdminAccess() async {
    try {
      final isAuthenticated = await _authService.isAuthenticated();

      if (!mounted) return;

      if (!isAuthenticated) {
        _redirectToLogin();
        return;
      }

      final currentUser = _authService.currentUser;

      if (currentUser == null) {
        final refreshResponse = await _authService.refreshToken();

        if (!mounted) return;

        if (!refreshResponse.success || refreshResponse.data == null) {
          _redirectToLogin();
          return;
        }

        if (!refreshResponse.data!.isAdmin) {
          await _authService.logout();
          _redirectToLogin();
          return;
        }
      }

      setState(() {
        _isCheckingAuth = false;
      });
    } catch (e) {
      if (mounted) {
        _redirectToLogin();
      }
    }
  }

  void _redirectToLogin() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const AdminLoginScreen()),
      (route) => false,
    );
  }

  Future<void> _handleNavigation(BuildContext context, String route) async {
    if (route == 'logout') {
      await _authService.logout();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const AdminLoginScreen()),
        (route) => false,
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
    if (_isCheckingAuth) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          AdminSidebar(
            currentRoute: widget.currentRoute,
            onNavigate: (route) => _handleNavigation(context, route),
          ),
          Expanded(
            child: widget.child,
          ),
        ],
      ),
    );
  }
}
