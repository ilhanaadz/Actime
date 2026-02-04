import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../constants/constants.dart';
import '../../components/event_card.dart';
import '../../components/actime_text_field.dart';
import '../../models/models.dart';
import '../../services/services.dart';
import '../../services/image_service.dart';
import 'create_event_screen.dart';
import 'edit_event_screen.dart';
import '../../components/bottom_nav_org.dart';
import 'organization_profile_screen.dart';
import '../events/event_detail_screen.dart';

class MyEventsOrgScreen extends StatefulWidget {
  final String organizationId;

  const MyEventsOrgScreen({super.key, required this.organizationId});

  @override
  State<MyEventsOrgScreen> createState() => _MyEventsOrgScreenState();
}

class _MyEventsOrgScreenState extends State<MyEventsOrgScreen> {
  final _eventService = EventService();
  final _searchController = TextEditingController();

  List<Event> _events = [];
  bool _isLoading = true;
  String? _error;
  bool _showSearchField = false;
  String _sortBy = 'Start';
  bool _sortDescending = true;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    // Debounce search
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _loadData();
      }
    });
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final eventsResponse = await _eventService.getOrganizationEvents(
        widget.organizationId,
        search: _searchController.text.isNotEmpty ? _searchController.text : null,
        sortBy: _sortBy,
        sortDescending: _sortDescending,
        startDate: _startDate,
        endDate: _endDate,
      );

      if (!mounted) return;

      if (eventsResponse.success && eventsResponse.data != null) {
        setState(() {
          _events = eventsResponse.data!.data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = eventsResponse.message ?? 'Greška pri učitavanju događaja';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Došlo je do greške. Pokušajte ponovo.';
        _isLoading = false;
      });
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd.MM.yyyy.').format(date);
  }

  IconData _getCategoryIcon(String? categoryName) {
    switch (categoryName?.toLowerCase()) {
      case 'sport':
        return Icons.sports_soccer;
      case 'kultura':
        return Icons.palette;
      case 'edukacija':
        return Icons.school;
      case 'zdravlje':
        return Icons.favorite;
      case 'muzika':
        return Icons.music_note;
      case 'tehnologija':
        return Icons.computer;
      default:
        return Icons.event;
    }
  }

  Future<void> _showDeleteConfirmation(Event event) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Potvrda brisanja',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Da li ste sigurni da želite obrisati događaj "${event.name}"?',
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              backgroundColor: Colors.grey.shade200,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Ne',
              style: TextStyle(color: Colors.black87),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              backgroundColor: AppColors.red,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Da, obriši',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (result == true) {
      await _deleteEvent(event);
    }
  }

  Future<void> _deleteEvent(Event event) async {
    try {
      final response = await _eventService.deleteEvent(event.id);
      if (!mounted) return;

      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Događaj je uspješno obrisan')),
        );
        _loadData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.message ?? 'Greška pri brisanju')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Došlo je do greške')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Actime',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: AppColors.primary),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OrganizationProfileScreen(
                    organizationId: widget.organizationId,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchFilterRow(),
          const Divider(height: 1),
          const SizedBox(height: 16),
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateEventScreen(
                organizationId: widget.organizationId,
              ),
            ),
          ).then((_) => _loadData());
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: AppColors.white),
      ),
      bottomNavigationBar: BottomNavOrg(
        currentIndex: 0,
        organizationId: widget.organizationId,
      ),
    );
  }

  Widget _buildSearchFilterRow() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingDefault,
            vertical: AppDimensions.spacingSmall,
          ),
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  _showSearchField ? Icons.close : Icons.search,
                  color: _showSearchField ? AppColors.primary : AppColors.textSecondary,
                ),
                onPressed: () {
                  setState(() {
                    _showSearchField = !_showSearchField;
                    if (!_showSearchField) {
                      _searchController.clear();
                    }
                  });
                },
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.sort, color: AppColors.textSecondary),
                onPressed: _showSortOptions,
              ),
              IconButton(
                icon: Icon(
                  Icons.calendar_today_outlined,
                  color: (_startDate != null || _endDate != null) ? AppColors.primary : AppColors.textSecondary,
                ),
                onPressed: _showDateRangePicker,
              ),
            ],
          ),
        ),
        if (_showSearchField)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingDefault,
              vertical: AppDimensions.spacingSmall,
            ),
            child: ActimeSearchField(
              controller: _searchController,
              hintText: 'Pretraži događaje...',
            ),
          ),
        if (_startDate != null || _endDate != null)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingDefault,
              vertical: AppDimensions.spacingSmall,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingSmall,
                vertical: AppDimensions.spacingSmall,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _getDateRangeText(),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 16, color: AppColors.primary),
                    onPressed: () {
                      setState(() {
                        _startDate = null;
                        _endDate = null;
                      });
                      _loadData();
                    },
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  String _getDateRangeText() {
    final dateFormat = DateFormat('dd.MM.yyyy.');
    if (_startDate != null && _endDate != null) {
      return '${dateFormat.format(_startDate!)} - ${dateFormat.format(_endDate!)}';
    } else if (_startDate != null) {
      return 'Od ${dateFormat.format(_startDate!)}';
    } else if (_endDate != null) {
      return 'Do ${dateFormat.format(_endDate!)}';
    }
    return '';
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppDimensions.spacingDefault),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sortiraj po',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingDefault),
            _buildSortOption('Datum (najnoviji)', 'Start', true),
            _buildSortOption('Datum (najstariji)', 'Start', false),
            _buildSortOption('Naziv (A-Z)', 'Title', false),
            _buildSortOption('Naziv (Z-A)', 'Title', true),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(String label, String sortBy, bool descending) {
    final isSelected = _sortBy == sortBy && _sortDescending == descending;
    return ListTile(
      title: Text(label),
      trailing: isSelected ? const Icon(Icons.check, color: AppColors.primary) : null,
      onTap: () {
        setState(() {
          _sortBy = sortBy;
          _sortDescending = descending;
        });
        _loadData();
        Navigator.pop(context);
      },
    );
  }

  Future<void> _showDateRangePicker() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: (_startDate != null && _endDate != null)
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _loadData();
    }
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppColors.textMuted),
            const SizedBox(height: AppDimensions.spacingDefault),
            Text(
              _error!,
              style: TextStyle(color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spacingDefault),
            TextButton(
              onPressed: _loadData,
              child: const Text('Pokušaj ponovo'),
            ),
          ],
        ),
      );
    }

    if (_events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 48, color: AppColors.textMuted),
            const SizedBox(height: AppDimensions.spacingDefault),
            Text(
              'Nemate događaja',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingDefault),
        itemCount: _events.length,
        itemBuilder: (context, index) {
          final event = _events[index];
          return EventCard(
            title: event.name,
            price: event.formattedPrice,
            date: _formatDate(event.startDate),
            location: event.location ?? 'Nije određeno',
            participants: event.participantsCount.toString(),
            icon: Icons.event,
            imageUrl: ImageService().getFullImageUrl(event.organizationLogoUrl),
            statusText: event.status.displayName,
            statusColor: event.status.color,
            showFavorite: false,
            showEditButton: true,
            showDeleteButton: true,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EventDetailScreen(
                    eventId: event.id,
                    isLoggedIn: true,
                  ),
                ),
              );
            },
            onEditTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditEventScreen(eventId: event.id),
                ),
              ).then((_) => _loadData());
            },
            onDeleteTap: () => _showDeleteConfirmation(event),
          );
        },
      ),
    );
  }
}
