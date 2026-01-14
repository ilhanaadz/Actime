import 'package:flutter/material.dart';
import '../components/admin_sidebar.dart';
import '../components/pagination_widget.dart';
import 'admin_dashboard_screen.dart';
import 'admin_organizations_screen.dart';
import 'admin_users_screen.dart';
import 'admin_categories_screen.dart';
import 'admin_login_screen.dart';

class AdminEventsScreen extends StatefulWidget {
  const AdminEventsScreen({super.key});

  @override
  State<AdminEventsScreen> createState() => _AdminEventsScreenState();
}

class _AdminEventsScreenState extends State<AdminEventsScreen> {
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
      case 'users':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminUsersScreen()),
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
            currentRoute: 'events',
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
                        'Events',
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

                // Events List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(24),
                    itemCount: 3,
                    itemBuilder: (context, index) => _buildEventCard(index),
                  ),
                ),

                // Pagination
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: PaginationWidget(
                    currentPage: _currentPage,
                    totalPages: _totalPages,
                    onPageChanged: (page) {
                      setState(() => _currentPage = page);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF0D7C8C).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                'FC',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0D7C8C),
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Event Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name and Badge
                Row(
                  children: [
                    const Text(
                      'Furkan Cürek',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D7C8C),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Author',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                Text(
                  'Event published 28 days ago',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),

                const SizedBox(height: 12),

                // Event Title
                const Text(
                  'Bjelašnica hiking trip',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 8),

                // Event Description
                Text(
                  'Come join us on a hiking trip to Bjelašnica mountain. We will meet at the parking lot at 8am and start our hike at 8:30am. The hike will take approximately 4 hours. We will have a lunch break at the top of the mountain.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 16),

                // Event Details
                Row(
                  children: [
                    _buildEventDetail(Icons.calendar_today, '16 Dec'),
                    const SizedBox(width: 24),
                    _buildEventDetail(Icons.access_time, '9:00'),
                    const SizedBox(width: 24),
                    _buildEventDetail(Icons.location_on, 'Sarajevo'),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // More Icon
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
            color: Colors.grey[400],
          ),
        ],
      ),
    );
  }

  Widget _buildEventDetail(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
