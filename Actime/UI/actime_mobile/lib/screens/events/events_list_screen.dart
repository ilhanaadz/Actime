import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../constants/constants.dart';
import '../../components/app_bar_component.dart';
import '../../components/bottom_nav_user.dart';
import '../user/user_profile_screen.dart';
import '../../components/actime_text_field.dart';
import '../../components/event_card.dart';
import '../../models/models.dart';
import '../../services/services.dart';
import '../user/favorites_screen.dart';
import '../landing/landing_logged_screen.dart';
import 'event_detail_screen.dart';

class EventsListScreen extends StatefulWidget {
  const EventsListScreen({super.key});

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

  @override
  void initState() {
    super.initState();
    _loadEvents();
    _loadFavorites();
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _loadFavorites() async {
    final favorites = await _favoriteService.getFavoriteEvents();
    if (mounted) {
      setState(() {
        _favoriteEventIds = favorites.map((e) => e.id).toSet();
      });
    }
  }

  Future<void> _toggleFavorite(Event event) async {
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
        status: EventStatus.upcoming,
        sortBy: 'startDate',
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

  String _formatDate(DateTime date) {
    return DateFormat('dd.MM.yyyy.').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: ActimeAppBar(
        showFavorite: true,
        onLogoTap: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LandingPageLogged()),
          );
        },
        onFavoriteTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FavoritesScreen()),
          );
        },
        onProfileTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const UserProfileScreen()),
          );
        },
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingDefault),
            child: Row(
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
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today, color: AppColors.primary),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavUser(currentIndex: 0),
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
            icon: _getCategoryIcon(event.categoryName),
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
        builder: (context) => EventDetailScreen(eventId: event.id),
      ),
    );
  }
}
