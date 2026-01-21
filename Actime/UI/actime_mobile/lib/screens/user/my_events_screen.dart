import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../constants/constants.dart';
import '../../components/event_card.dart';
import '../../components/tab_button.dart';
import '../../components/app_bar_component.dart';
import '../../models/models.dart';
import '../../services/services.dart';
import '../../components/bottom_nav_user.dart';
import '../landing/landing_logged_screen.dart';
import '../events/event_detail_screen.dart';
import 'user_profile_screen.dart';
import 'favorites_screen.dart';

class MyEventsScreen extends StatefulWidget {
  const MyEventsScreen({super.key});

  @override
  State<MyEventsScreen> createState() => _MyEventsScreenState();
}

class _MyEventsScreenState extends State<MyEventsScreen> {
  final _userService = UserService();
  final _authService = AuthService();

  int _selectedTabIndex = 0;
  List<Event> _events = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        setState(() {
          _error = 'Niste prijavljeni';
          _isLoading = false;
        });
        return;
      }

      final response = await _userService.getUserEvents(
        currentUser.id,
        status: _selectedTabIndex == 0 ? EventStatus.upcoming : EventStatus.completed,
      );

      if (!mounted) return;

      if (response.success && response.data != null) {
        setState(() {
          _events = response.data!.data;
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

  @override
  Widget build(BuildContext context) {
    final currentUser = _authService.currentUser;

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
          _buildProfileHeader(currentUser),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingDefault),
            child: ActimeTabBar(
              tabs: const ['Nadolazeći', 'Prošli'],
              selectedIndex: _selectedTabIndex,
              onTabChanged: (index) {
                setState(() {
                  _selectedTabIndex = index;
                });
                _loadEvents();
              },
            ),
          ),
          const SizedBox(height: AppDimensions.spacingDefault),
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavUser(currentIndex: 2),
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
              _selectedTabIndex == 0
                  ? 'Nemate nadolazećih događaja'
                  : 'Nemate prošlih događaja',
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
            showFavorite: false,
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
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(User? user) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.spacingDefault),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.borderLight,
            child: Icon(Icons.person, size: 30, color: AppColors.textMuted),
          ),
          const SizedBox(width: AppDimensions.spacingDefault),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.name ?? 'Korisnik',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  user?.email ?? '',
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
