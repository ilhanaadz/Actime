import 'package:flutter/material.dart';
import '../components/admin_layout.dart';
import '../components/pagination_widget.dart';
import '../components/search_sort_header.dart';
import '../components/event_filter_tabs.dart';
import '../components/delete_confirmation_dialog.dart';

class AdminEventsScreen extends StatefulWidget {
  const AdminEventsScreen({super.key});

  @override
  State<AdminEventsScreen> createState() => _AdminEventsScreenState();
}

class _AdminEventsScreenState extends State<AdminEventsScreen> {
  final _searchController = TextEditingController();
  int _currentPage = 1;
  final int _totalPages = 4;
  String _selectedFilter = 'All';
  String _sortBy = 'date';

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      currentRoute: 'events',
      child: Column(
              children: [
                // Header with Search, Sort, and Calendar
                SearchSortHeader(
                  title: 'Events',
                  searchController: _searchController,
                  sortItems: [
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
                  onSortSelected: (value) {
                    setState(() => _sortBy = value);
                  },
                  additionalActions: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: _showCompactDatePicker,
                    color: const Color(0xFF0D7C8C),
                    tooltip: 'Filter by date',
                  ),
                ),

                // Filter Tabs
                EventFilterTabs(
                  selectedFilter: _selectedFilter,
                  onFilterChanged: (filter) {
                    setState(() => _selectedFilter = filter);
                  },
                ),

                // Events List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(24),
                    itemCount: 3,
                    itemBuilder: (context, index) => _buildEventCard(index),
                  ),
                ),

                // Pagination at bottom
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
            onPressed: () => _showDeleteEventDialog('Bjelašnica hiking trip'),
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

  Future<void> _showDeleteEventDialog(String eventName) async {
    final result = await DeleteConfirmationDialog.show(
      context: context,
      title: 'Delete Event',
      message: 'Are you sure you want to delete "$eventName"? This action cannot be undone.',
    );
    
    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Event "$eventName" deleted successfully')),
      );
    }
  }

  Future<void> _showCompactDatePicker() async {
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
    
    if (picked != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Filtered for ${picked.day}/${picked.month}/${picked.year}'),
        ),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}