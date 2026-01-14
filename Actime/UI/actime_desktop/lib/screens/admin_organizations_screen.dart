import 'package:flutter/material.dart';
import '../components/admin_sidebar.dart';
import '../components/pagination_widget.dart';
import 'admin_dashboard_screen.dart';
import 'admin_users_screen.dart';
import 'admin_events_screen.dart';
import 'admin_categories_screen.dart';
import 'admin_login_screen.dart';

class AdminOrganizationsScreen extends StatefulWidget {
  const AdminOrganizationsScreen({super.key});

  @override
  State<AdminOrganizationsScreen> createState() => _AdminOrganizationsScreenState();
}

class _AdminOrganizationsScreenState extends State<AdminOrganizationsScreen> {
  final _searchController = TextEditingController();
  int? _selectedOrgIndex;
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
      backgroundColor: const Color(0xFFF5F5F5),
      body: Row(
        children: [
          AdminSidebar(
            currentRoute: 'organizations',
            onNavigate: _handleNavigation,
          ),
          
          Expanded(
            child: _selectedOrgIndex == null 
                ? _buildOrganizationsList() 
                : _buildOrganizationDetail(),
          ),
        ],
      ),
    );
  }

  Widget _buildOrganizationsList() {
    return Column(
      children: [
        // Search Header
        Container(
          padding: const EdgeInsets.all(24),
          color: Colors.white,
          child: Row(
            children: [
              const Text(
                'Organizations',
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
        
        // Organizations List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: 3,
            itemBuilder: (context, index) => _buildOrganizationCard(index),
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
    );
  }

  Widget _buildOrganizationCard(int index) {
    return GestureDetector(
      onTap: () => setState(() => _selectedOrgIndex = index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo
            Container(
              width: 80,
              height: 80,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.sports_volleyball,
                color: Colors.orange,
                size: 40,
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Organization Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Student',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0D7C8C),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.event, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            '13 events',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 4),
                  const Text(
                    'Volleyball',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    '+12027953213',
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '1894 Arlington Avenue',
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'club@volleyball.com',
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  Text(
                    'Volleyball is a team sport in which two teams of six players are separated by a net. Each team tries to score points by grounding a ball on the other team\'s court under organized rules.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  Row(
                    children: [
                      const Icon(Icons.people, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        '89 members',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 16),
            
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.emoji_events,
                color: Colors.grey,
                size: 30,
              ),
            ),
            
            const SizedBox(width: 8),
            
            Icon(Icons.more_vert, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildOrganizationDetail() {
    return Container(
      color: const Color(0xFFF5F5F5),
      child: Column(
        children: [
          // Detail Header with Close Button
          Container(
            padding: const EdgeInsets.all(24),
            color: Colors.white,
            child: Row(
              children: [
                const Text(
                  'Organization Details',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() => _selectedOrgIndex = null),
                  tooltip: 'Close',
                ),
              ],
            ),
          ),
          
          // Organization Detail Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main Info Card
                  Container(
                    padding: const EdgeInsets.all(24),
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
                        // Main Logo
                        Container(
                          width: 120,
                          height: 120,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.orange[50],
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.sports_volleyball,
                            color: Colors.orange,
                            size: 70,
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Organization Name
                        const Text(
                          'Student',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0D7C8C),
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        Text(
                          'Volleyball',
                          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Contact Info Cards
                        Row(
                          children: [
                            Expanded(
                              child: _buildContactCard('+12027953213', Icons.phone),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildContactCard('1894 Arlington Avenue', Icons.location_on),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 12),
                        
                        _buildContactCard('club@volleyball.com', Icons.email),
                        
                        const SizedBox(height: 24),
                        
                        // Stats
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildStatItem(Icons.event, '13 events'),
                            const SizedBox(width: 32),
                            _buildStatItem(Icons.people, '89 members'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // About Section
                  Container(
                    padding: const EdgeInsets.all(24),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'About',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Volleyball is a team sport in which two teams of six players are separated by a net. Each team tries to score points by grounding a ball on the other team\'s court under organized rules.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Gallery Section
                  Container(
                    padding: const EdgeInsets.all(24),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Gallery',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(Icons.image, color: Colors.grey[400], size: 60),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                children: [
                                  AspectRatio(
                                    aspectRatio: 1,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(Icons.image, color: Colors.grey[400], size: 30),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  AspectRatio(
                                    aspectRatio: 1,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(Icons.image, color: Colors.grey[400], size: 30),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                children: [
                                  AspectRatio(
                                    aspectRatio: 1,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(Icons.image, color: Colors.grey[400], size: 30),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  AspectRatio(
                                    aspectRatio: 1,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(Icons.image, color: Colors.grey[400], size: 30),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Events Section
                  Container(
                    padding: const EdgeInsets.all(24),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Events',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildEventItem('Bjelašnica hiking trip', '11.10.2022', '205 participants'),
                        _buildEventItem('Volleyball tournament', '21.12.2022', '31 participants'),
                        _buildEventItem('Training session', '15.11.2022', '45 participants'),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Delete Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _showDeleteDialog(context);
                      },
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text('Delete Organization'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildEventItem(String title, String date, String participants) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.event, color: Colors.orange, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  '$date • $participants',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Delete Organization'),
        content: const Text('Are you sure you want to delete this organization? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _selectedOrgIndex = null);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Organization deleted')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
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
