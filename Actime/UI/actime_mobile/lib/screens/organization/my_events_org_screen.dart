import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../constants/constants.dart';
import '../../components/event_card.dart';
import '../../components/tab_button.dart';
import '../../components/circle_icon_container.dart';
import '../../models/models.dart';
import '../../services/services.dart';
import 'create_event_screen.dart';
import 'edit_event_screen.dart';

class MyEventsOrgScreen extends StatefulWidget {
  final String organizationId;

  const MyEventsOrgScreen({super.key, required this.organizationId});

  @override
  State<MyEventsOrgScreen> createState() => _MyEventsOrgScreenState();
}

class _MyEventsOrgScreenState extends State<MyEventsOrgScreen> {
  final _eventService = EventService();
  final _organizationService = OrganizationService();

  int _selectedTabIndex = 0;
  List<Event> _events = [];
  Organization? _organization;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load organization and events in parallel
      final orgResponse = await _organizationService.getOrganizationById(widget.organizationId);
      final eventsResponse = await _eventService.getOrganizationEvents(
        widget.organizationId,
        status: _selectedTabIndex == 0 ? EventStatus.upcoming : EventStatus.completed,
      );

      if (!mounted) return;

      if (orgResponse.success && orgResponse.data != null) {
        _organization = orgResponse.data;
      }

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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Moji događaji',
          style: TextStyle(
            color: AppColors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.primary),
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
          ),
        ],
      ),
      body: Column(
        children: [
          _buildOrganizationHeader(),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingDefault),
            child: ActimeTabBar(
              tabs: const ['Aktivni', 'Prošli'],
              selectedIndex: _selectedTabIndex,
              onTabChanged: (index) {
                setState(() {
                  _selectedTabIndex = index;
                });
                _loadData();
              },
            ),
          ),
          const SizedBox(height: AppDimensions.spacingDefault),
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
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
              _selectedTabIndex == 0
                  ? 'Nemate aktivnih događaja'
                  : 'Nemate prošlih događaja',
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
            icon: _getCategoryIcon(event.categoryName),
            showFavorite: false,
            showEditButton: true,
            showDeleteButton: true,
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

  Widget _buildOrganizationHeader() {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.spacingDefault),
      child: Row(
        children: [
          CircleIconContainer.large(
            icon: _getCategoryIcon(_organization?.categoryName),
            iconColor: AppColors.orange,
          ),
          const SizedBox(width: AppDimensions.spacingDefault),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _organization?.name ?? 'Organizacija',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  _organization?.categoryName ?? 'Klub',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
