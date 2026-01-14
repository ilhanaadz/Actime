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
  String _selectedFilter = 'All'; // All, Active, Closed
  String _sortBy = 'date'; // date, name, participants

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
                      
                      // Search TextField
                      SizedBox(
                        width: 300,
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
                      
                      const SizedBox(width: 12),
                      
                      // Sort Dropdown
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.sort, color: Color(0xFF0D7C8C)),
                        tooltip: 'Sort',
                        offset: const Offset(0, 45),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        onSelected: (value) {
                          setState(() => _sortBy = value);
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'date',
                            child: Row(
                              children: [
                                Icon(Icons.calendar_today, size: 18),
                                SizedBox(width: 12),
                                Text('Sort by Date'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'name',
                            child: Row(
                              children: [
                                Icon(Icons.sort_by_alpha, size: 18),
                                SizedBox(width: 12),
                                Text('Sort by Name'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'participants',
                            child: Row(
                              children: [
                                Icon(Icons.people, size: 18),
                                SizedBox(width: 12),
                                Text('Sort by Participants'),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(width: 8),
                      
                      // Calendar Icon
                      IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () {
                          _showCompactDatePicker(context);
                        },
                        color: const Color(0xFF0D7C8C),
                        tooltip: 'Filter by date',
                      ),
                    ],
                  ),
                ),

                // Filter Tabs
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  color: Colors.white,
                  child: Row(
                    children: [
                      _buildFilterTab('All'),
                      const SizedBox(width: 8),
                      _buildFilterTab('Active'),
                      const SizedBox(width: 8),
                      _buildFilterTab('Closed'),
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

          // Delete Icon
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              _showDeleteEventDialog(context, 'Bjelašnica hiking trip');
            },
            color: Colors.red[400],
            tooltip: 'Delete event',
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

  void _showDeleteEventDialog(BuildContext context, String eventName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Delete Event'),
        content: Text('Are you sure you want to delete "$eventName"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Event "$eventName" deleted successfully')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String label) {
    final isSelected = _selectedFilter == label;
    return InkWell(
      onTap: () => setState(() => _selectedFilter = label),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0D7C8C) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF0D7C8C) : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? Colors.white : Colors.grey[700],
          ),
        ),
      ),
    );
  }

  Future<void> _showCompactDatePicker(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0D7C8C),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Filtered for ${picked.day}/${picked.month}/${picked.year}'),
        ),
      );
    }
  }

  Future<void> _showDateRangePicker(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0D7C8C),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Filtered from ${picked.start.day}/${picked.start.month}/${picked.start.year} to ${picked.end.day}/${picked.end.month}/${picked.end.year}',
          ),
        ),
      );
    }
  }
}