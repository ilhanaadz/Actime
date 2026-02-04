import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../constants/constants.dart';
import '../../components/app_bar_component.dart';
import '../../components/bottom_nav_user.dart';
import '../../components/bottom_nav.dart';
import '../user/user_profile_screen.dart';
import '../../components/actime_text_field.dart';
import '../../components/event_card.dart';
import '../../models/models.dart';
import '../../services/services.dart';
import '../../services/image_service.dart';
import '../user/favorites_screen.dart';
import '../landing/landing_logged_screen.dart';
import '../landing/landing_not_logged_screen.dart';
import '../auth/sign_in_screen.dart';
import '../notifications/notifications_screen.dart';
import 'event_detail_screen.dart';

class EventsListScreen extends StatefulWidget {
  final bool isLoggedIn;

  const EventsListScreen({super.key, this.isLoggedIn = true});

  @override
  State<EventsListScreen> createState() => _EventsListScreenState();
}

class _EventsListScreenState extends State<EventsListScreen> {
  final _eventService = EventService();
  final _favoriteService = FavoriteService();
  final _searchController = TextEditingController();

  List<Event> _events = [];
  Set<String> _favoriteEventIds = {};
  bool _isLoading = true;
  String? _error;
  int _currentPage = 1;
  int _totalPages = 1;
  EventStatus? _selectedStatus;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _loadEvents();
    if (widget.isLoggedIn) {
      _loadFavorites();
    }
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _loadFavorites() async {
    if (!widget.isLoggedIn) return;
    final favorites = await _favoriteService.getFavoriteEvents();
    if (mounted) {
      setState(() {
        _favoriteEventIds = favorites.map((e) => e.id).toSet();
      });
    }
  }

  Future<void> _toggleFavorite(Event event) async {
    if (!widget.isLoggedIn) {
      // Redirect to login
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SignInScreen()),
      );
      return;
    }
    final isFavorite = await _favoriteService.toggleEventFavorite(event);
    if (mounted) {
      setState(() {
        if (isFavorite) {
          _favoriteEventIds.add(event.id);
        } else {
          _favoriteEventIds.remove(event.id);
        }
      });
    }
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
        _currentPage = 1;
        _loadEvents();
      }
    });
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
        status: _selectedStatus,
        sortBy: 'Start',
      );

      if (!mounted) return;

      if (response.success && response.data != null) {
        var events = response.data!.data;

        // Apply date range filter client-side if needed
        if (_startDate != null) {
          events = events.where((e) =>
            e.startDate.isAfter(_startDate!) ||
            e.startDate.isAtSameMomentAs(_startDate!)
          ).toList();
        }
        if (_endDate != null) {
          events = events.where((e) =>
            e.startDate.isBefore(_endDate!) ||
            e.startDate.isAtSameMomentAs(_endDate!)
          ).toList();
        }

        setState(() {
          _events = events;
          _totalPages = response.data!.lastPage;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response.message ?? 'Greška pri učitavanju događaja';
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

  void _showStatusFilter() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        padding: const EdgeInsets.all(AppDimensions.spacingDefault),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filtriraj po statusu',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingDefault),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildStatusOption('Svi događaji', null),
                    _buildStatusOption(EventStatus.pending.displayName, EventStatus.pending),
                    _buildStatusOption(EventStatus.upcoming.displayName, EventStatus.upcoming),
                    _buildStatusOption(EventStatus.inProgress.displayName, EventStatus.inProgress),
                    _buildStatusOption(EventStatus.completed.displayName, EventStatus.completed),
                    _buildStatusOption(EventStatus.cancelled.displayName, EventStatus.cancelled),
                    _buildStatusOption(EventStatus.postponed.displayName, EventStatus.postponed),
                    _buildStatusOption(EventStatus.rescheduled.displayName, EventStatus.rescheduled),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusOption(String label, EventStatus? status) {
    final isSelected = _selectedStatus == status;
    return ListTile(
      title: Text(label),
      leading: status != null
          ? Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: status.color,
                shape: BoxShape.circle,
              ),
            )
          : null,
      trailing: isSelected ? const Icon(Icons.check, color: AppColors.primary) : null,
      onTap: () {
        setState(() {
          _selectedStatus = status;
        });
        _loadEvents();
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
      _loadEvents();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: ActimeAppBar(
        showFavorite: widget.isLoggedIn,
        showNotifications: widget.isLoggedIn,
        onLogoTap: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => widget.isLoggedIn
                  ? const LandingPageLogged()
                  : const LandingPageNotLogged(),
            ),
          );
        },
        onNotificationTap: widget.isLoggedIn
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                );
              }
            : null,
        onFavoriteTap: widget.isLoggedIn
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FavoritesScreen()),
                );
              }
            : null,
        onProfileTap: () {
          if (widget.isLoggedIn) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const UserProfileScreen()),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SignInScreen()),
            );
          }
        },
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingDefault),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ActimeSearchField(
                        hintText: 'Pretraži događaje...',
                        controller: _searchController,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spacingMedium),
                    IconButton(
                      icon: const Icon(Icons.tune, color: AppColors.primary),
                      onPressed: _showStatusFilter,
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.calendar_today,
                        color: (_startDate != null || _endDate != null)
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      ),
                      onPressed: _showDateRangePicker,
                    ),
                  ],
                ),
                if (_startDate != null || _endDate != null)
                  Padding(
                    padding: const EdgeInsets.only(top: AppDimensions.spacingSmall),
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
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              setState(() {
                                _startDate = null;
                                _endDate = null;
                              });
                              _loadEvents();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
      bottomNavigationBar: widget.isLoggedIn
          ? const BottomNavUser(currentIndex: 0)
          : const BottomNav(currentIndex: 0),
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
              onPressed: _loadEvents,
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
              'Nema pronađenih događaja',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadEvents,
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
            isFavorite: _favoriteEventIds.contains(event.id),
            onTap: () => _navigateToDetail(context, event),
            onFavoriteTap: () => _toggleFavorite(event),
          );
        },
      ),
    );
  }

  void _navigateToDetail(BuildContext context, Event event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventDetailScreen(
          eventId: event.id,
          isLoggedIn: widget.isLoggedIn,
        ),
      ),
    );
  }
}
