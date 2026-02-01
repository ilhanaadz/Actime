import 'package:flutter/material.dart';
import '../../constants/constants.dart';
import '../../components/app_bar_component.dart';
import '../../components/bottom_nav_user.dart';
import 'user_profile_screen.dart';
import '../../models/models.dart';
import '../../services/services.dart';
import '../clubs/club_detail_screen.dart';
import '../events/event_detail_screen.dart';
import '../landing/landing_logged_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final _favoriteService = FavoriteService();

  List<Organization> _favoriteClubs = [];
  List<Event> _favoriteEvents = [];
  bool _isLoading = true;
  int _selectedTab = 0; // 0 = Clubs, 1 = Events

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final clubs = await _favoriteService.getFavoriteClubs();
      final events = await _favoriteService.getFavoriteEvents();

      if (!mounted) return;

      setState(() {
        _favoriteClubs = clubs;
        _favoriteEvents = events;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleClubFavorite(Organization club) async {
    await _favoriteService.removeClubFromFavorites(club.id);
    await _loadFavorites();
  }

  Future<void> _toggleEventFavorite(Event event) async {
    await _favoriteService.removeEventFromFavorites(event.id);
    await _loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: ActimeAppBar(
        showFavorite: true,
        onLogoTap: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LandingPageLogged()),
          );
        },
        onFavoriteTap: () {},
        onProfileTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const UserProfileScreen()),
          );
        },
      ),
      body: Column(
        children: [
          // Tab buttons
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: _buildTabButton('Clubs', 0),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTabButton('Events', 1),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavUser(currentIndex: -1),
    );
  }

  Widget _buildTabButton(String label, int index) {
    final isActive = _selectedTab == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isActive ? AppColors.primary : Colors.grey.shade300,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isActive ? Colors.white : Colors.grey,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_selectedTab == 0) {
      return _buildClubsList();
    } else {
      return _buildEventsList();
    }
  }

  Widget _buildClubsList() {
    if (_favoriteClubs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 48, color: AppColors.textMuted),
            const SizedBox(height: AppDimensions.spacingDefault),
            Text(
              'Nemate omiljenih klubova',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFavorites,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _favoriteClubs.length,
        itemBuilder: (context, index) {
          final club = _favoriteClubs[index];
          return _buildClubCard(club);
        },
      ),
    );
  }

  Widget _buildEventsList() {
    if (_favoriteEvents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 48, color: AppColors.textMuted),
            const SizedBox(height: AppDimensions.spacingDefault),
            Text(
              'Nemate omiljenih dogadaja',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFavorites,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _favoriteEvents.length,
        itemBuilder: (context, index) {
          final event = _favoriteEvents[index];
          return _buildEventCard(event);
        },
      ),
    );
  }

  Widget _buildClubCard(Organization club) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ClubDetailScreen(organizationId: club.id),
          ),
        ).then((_) => _loadFavorites());
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            // Club logo/icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                shape: BoxShape.circle,
              ),
              child: club.logo != null
                  ? ClipOval(
                      child: Image.network(
                        club.logo!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildClubIcon(club.categoryName);
                        },
                      ),
                    )
                  : _buildClubIcon(club.categoryName),
            ),
            const SizedBox(width: 16),
            // Club info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    club.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    club.categoryName ?? 'Klub',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            // Favorite button
            IconButton(
              icon: const Icon(Icons.favorite, color: AppColors.primary),
              onPressed: () => _toggleClubFavorite(club),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClubIcon(String? categoryName) {
    IconData icon;
    switch (categoryName?.toLowerCase()) {
      case 'sport':
        icon = Icons.sports_soccer;
        break;
      case 'kultura':
        icon = Icons.palette;
        break;
      case 'edukacija':
        icon = Icons.school;
        break;
      case 'zdravlje':
        icon = Icons.favorite;
        break;
      case 'muzika':
        icon = Icons.music_note;
        break;
      case 'tehnologija':
        icon = Icons.computer;
        break;
      default:
        icon = Icons.groups;
    }
    return Icon(icon, color: Colors.orange, size: 24);
  }

  Widget _buildEventCard(Event event) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetailScreen(eventId: event.id),
          ),
        ).then((_) => _loadFavorites());
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            // Event info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    event.activityTypeName ?? 'Dogadjaj',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            // Favorite button
            IconButton(
              icon: const Icon(Icons.favorite, color: AppColors.primary),
              onPressed: () => _toggleEventFavorite(event),
            ),
          ],
        ),
      ),
    );
  }
}
