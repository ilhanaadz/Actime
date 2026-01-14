import 'package:flutter/material.dart';
import '../components/admin_sidebar.dart';
import '../components/pagination_widget.dart';
import 'admin_dashboard_screen.dart';
import 'admin_organizations_screen.dart';
import 'admin_events_screen.dart';
import 'admin_users_screen.dart';
import 'admin_login_screen.dart';

class AdminCategoriesScreen extends StatefulWidget {
  const AdminCategoriesScreen({super.key});

  @override
  State<AdminCategoriesScreen> createState() => _AdminCategoriesScreenState();
}

class _AdminCategoriesScreenState extends State<AdminCategoriesScreen> {
  final _searchController = TextEditingController();
  int _currentPage = 1;
  final int _totalPages = 4;

  void _handleNavigation(String route) {
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
      case 'events':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminEventsScreen()),
        );
        break;
      case 'users':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminUsersScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Row(
        children: [
          AdminSidebar(
            currentRoute: 'categories',
            onNavigate: _handleNavigation,
          ),
          Expanded(
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(24),
                  color: Colors.white,
                  child: Row(
                    children: [
                      const Text(
                        'Categories',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add Category'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D7C8C),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Categories Table
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Table Header
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(color: Colors.grey[200]!),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Expanded(
                                      flex: 3,
                                      child: Text(
                                        'Name',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                    const Expanded(
                                      flex: 2,
                                      child: Text(
                                        'Organizations',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                    Container(width: 40),
                                  ],
                                ),
                              ),

                              // Table Rows
                              _buildCategoryRow('Volleyball', '3 organizations'),
                              _buildCategoryRow('Sports', '12 organizations'),
                              _buildCategoryRow('Hiking', '5 organizations'),
                              _buildCategoryRow('Swimming', '7 organizations'),
                              _buildCategoryRow('Basketball', '4 organizations'),
                              _buildCategoryRow('Football', '8 organizations'),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        PaginationWidget(
                          currentPage: _currentPage,
                          totalPages: _totalPages,
                          onPageChanged: (page) {
                            setState(() => _currentPage = page);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryRow(String name, String orgs) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        children: [
          // Name
          Expanded(
            flex: 3,
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),

          // Organizations
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Icon(Icons.apartment_outlined, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  orgs,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),

          // Edit Icon
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 20),
            onPressed: () {},
            color: Colors.grey[600],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
