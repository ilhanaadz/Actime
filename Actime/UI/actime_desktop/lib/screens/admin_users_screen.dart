import 'package:flutter/material.dart';
import '../components/admin_sidebar.dart';
import '../components/pagination_widget.dart';
import 'admin_dashboard_screen.dart';
import 'admin_organizations_screen.dart';
import 'admin_events_screen.dart';
import 'admin_categories_screen.dart';
import 'admin_login_screen.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
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
      backgroundColor: const Color(0xFFF5F5F5),
      body: Row(
        children: [
          AdminSidebar(
            currentRoute: 'users',
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
                        'Users',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: 350,
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search...',
                            prefixIcon: const Icon(Icons.search, color: Color(0xFF0D7C8C)),
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Users Table
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
                                    const SizedBox(width: 60),
                                    const Expanded(
                                      flex: 2,
                                      child: Text(
                                        'First Name',
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
                                        'Last Name',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                    const Expanded(
                                      flex: 3,
                                      child: Text(
                                        'Email Address',
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
                              _buildUserRow('Furkan Cürek', 'furkancurek@outlook.com', '2 organizations'),
                              _buildUserRow('Armin Šišić', 'sisicarmin@gmail.com', '6 organizations'),
                              _buildUserRow('Test User', 'testuser@gmail.com', '1 organization'),
                              _buildUserRow('Another Cürek', 'anotherfurkan@gmail.com', '4 organizations'),
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

  Widget _buildUserRow(String name, String email, String orgs) {
    final nameParts = name.split(' ');
    final firstName = nameParts[0];
    final lastName = nameParts.length > 1 ? nameParts[1] : '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 40,
            height: 40,
            margin: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: const Color(0xFF0D7C8C).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                firstName[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0D7C8C),
                ),
              ),
            ),
          ),

          // First Name
          Expanded(
            flex: 2,
            child: Text(
              firstName,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),

          // Last Name
          Expanded(
            flex: 2,
            child: Text(
              lastName,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),

          // Email
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Icon(Icons.email_outlined, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  email,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
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

          // More Icon
          IconButton(
            icon: const Icon(Icons.more_vert, size: 20),
            onPressed: () {},
            color: Colors.grey[400],
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
