import 'package:flutter/material.dart';
import '../components/admin_layout.dart';
import '../components/pagination_widget.dart';
import '../components/search_sort_header.dart';
import '../components/event_filter_tabs.dart';
import '../components/delete_confirmation_dialog.dart';
import '../services/services.dart';
import '../models/models.dart';

class AdminEventsScreen extends StatefulWidget {
  const AdminEventsScreen({super.key});

  @override
  State<AdminEventsScreen> createState() => _AdminEventsScreenState();
}

class _AdminEventsScreenState extends State<AdminEventsScreen> {
  final _searchController = TextEditingController();
  final _eventService = EventService();

  int _currentPage = 1;
  int _totalPages = 1;
  String _selectedFilter = 'All';
  String _sortBy = 'Start';
  DateTime? _filterDate;
  bool _isLoading = true;
  String? _error;
  List<Event> _events = [];

  @override
  void initState() {
    super.initState();
    _loadEvents();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (_searchController.text.isEmpty || _searchController.text.length >= 2) {
      setState(() => _currentPage = 1);
      _loadEvents();
    }
  }

  int? _getStatusFilter() {
    switch (_selectedFilter) {
      case 'Pending':
        return 1;
      case 'Upcoming':
        return 2;
      case 'In Progress':
        return 3;
      case 'Completed':
        return 4;
      case 'Cancelled':
        return 5;
      case 'Postponed':
        return 6;
      case 'Rescheduled':
        return 7;
      default:
        return null;
    }
  }

  Future<void> _loadEvents() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _eventService.getEvents(
        page: _currentPage,
        perPage: 10,
        search: _searchController.text.isNotEmpty ? _searchController.text : null,
        sortBy: _sortBy,
        eventStatusId: _getStatusFilter(),
        startDate: _filterDate,
      );

      if (!mounted) return;

      if (response.success && response.data != null) {
        setState(() {
          _events = response.data!.data;
          _totalPages = response.data!.lastPage;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response.message ?? 'Failed to load events';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Connection error';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteEvent(Event event) async {
    final result = await DeleteConfirmationDialog.show(
      context: context,
      title: 'Delete Event',
      message: 'Are you sure you want to delete "${event.name}"? This action cannot be undone.',
    );

    if (result != true || !mounted) return;

    setState(() => _isLoading = true);

    try {
      final response = await _eventService.deleteEvent(event.id);

      if (!mounted) return;

      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Event "${event.name}" deleted successfully')),
        );
        _loadEvents();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Failed to delete event'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Connection error'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isLoading = false);
      }
    }
  }

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
                value: 'Start',
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, size: 18),
                    SizedBox(width: 12),
                    Text('Sort by Date'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'Title',
                child: Row(
                  children: [
                    Icon(Icons.sort_by_alpha, size: 18),
                    SizedBox(width: 12),
                    Text('Sort by Name'),
                  ],
                ),
              ),
            ],
            onSortSelected: (value) {
              setState(() { 
                _sortBy = value;
                _currentPage = 1;
              });
              _loadEvents();
            },
            additionalActions: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_filterDate != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Chip(
                      label: Text(
                        '${_filterDate!.day}/${_filterDate!.month}/${_filterDate!.year}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () {
                        setState(() => _filterDate = null);
                        _loadEvents();
                      },
                    ),
                  ),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: _showCompactDatePicker,
                  color: const Color(0xFF0D7C8C),
                  tooltip: 'Filter by date',
                ),
              ],
            ),
          ),

          // Filter Tabs
          EventFilterTabs(
            selectedFilter: _selectedFilter,
            onFilterChanged: (filter) {
              setState(() => _selectedFilter = filter);
              _loadEvents();
            },
          ),

          // Events List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? _buildErrorState()
                    : _events.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.all(24),
                            itemCount: _events.length,
                            itemBuilder: (context, index) =>
                                _buildEventCard(_events[index]),
                          ),
          ),

          // Pagination at bottom
          if (!_isLoading && _error == null && _events.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: PaginationWidget(
                currentPage: _currentPage,
                totalPages: _totalPages,
                onPageChanged: (page) {
                  setState(() => _currentPage = page);
                  _loadEvents();
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            _error!,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadEvents,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            _searchController.text.isNotEmpty
                ? 'No events found for "${_searchController.text}"'
                : _selectedFilter != 'All'
                    ? 'No $_selectedFilter events found'
                    : 'No events found',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(Event event) {
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
          // Event image or avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF0D7C8C).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: event.image != null
                ? ClipOval(
                    child: Image.network(
                      event.image!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Center(
                        child: Icon(Icons.event, color: Color(0xFF0D7C8C)),
                      ),
                    ),
                  )
                : const Center(
                    child: Icon(Icons.event, color: Color(0xFF0D7C8C)),
                  ),
          ),

          const SizedBox(width: 16),

          // Event Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Organization and Status
                Row(
                  children: [
                    if (event.organizationName != null)
                      Text(
                        event.organizationName!,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    const SizedBox(width: 8),
                    _buildStatusBadge(event.status),
                  ],
                ),

                const SizedBox(height: 4),

                if (event.createdAt != null)
                  Text(
                    'Event published ${_getTimeAgo(event.createdAt!)}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),

                const SizedBox(height: 12),

                // Event Title
                Text(
                  event.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),

                if (event.description != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    event.description!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                const SizedBox(height: 16),

                // Event Details
                Row(
                  children: [
                    if (event.startDate != null)
                      _buildEventDetail(
                        Icons.calendar_today,
                        '${event.startDate!.day} ${_getMonthName(event.startDate!.month)}',
                      ),
                    if (event.startDate != null) const SizedBox(width: 24),
                    if (event.startDate != null)
                      _buildEventDetail(
                        Icons.access_time,
                        '${event.startDate!.hour}:${event.startDate!.minute.toString().padLeft(2, '0')}',
                      ),
                    if (event.location != null) ...[
                      const SizedBox(width: 24),
                      _buildEventDetail(Icons.location_on, event.location!),
                    ],
                    const SizedBox(width: 24),
                    _buildEventDetail(
                      Icons.people,
                      '${event.participantsCount} participants',
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // Delete Icon
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _deleteEvent(event),
            color: Colors.red[400],
            tooltip: 'Delete event',
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(EventStatus status) {
    Color bgColor;
    String label;

    switch (status) {
      case EventStatus.pending:
        bgColor = Colors.orange;
        label = 'Pending';
        break;
      case EventStatus.upcoming:
        bgColor = const Color(0xFF0D7C8C);
        label = 'Upcoming';
        break;
      case EventStatus.inProgress:
        bgColor = Colors.green;
        label = 'In Progress';
        break;
      case EventStatus.completed:
        bgColor = Colors.grey;
        label = 'Completed';
        break;
      case EventStatus.cancelled:
        bgColor = Colors.red;
        label = 'Cancelled';
        break;
      case EventStatus.postponed:
        bgColor = Colors.amber;
        label = 'Postponed';
        break;
      case EventStatus.rescheduled:
        bgColor = Colors.blue;
        label = 'Rescheduled';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else {
      return 'Just now';
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
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

  Future<void> _showCompactDatePicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _filterDate ?? DateTime.now(),
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
      setState(() => _filterDate = picked);
      _loadEvents();
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }
}
