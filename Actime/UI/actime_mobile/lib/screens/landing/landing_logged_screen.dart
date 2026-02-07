import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../components/app_bar_component.dart';
import '../../components/bottom_nav_user.dart';
import '../../components/event_card.dart';
import '../../constants/constants.dart';
import '../../models/models.dart';
import '../../services/organization_service.dart';
import '../../services/event_service.dart';
import '../../services/image_service.dart';
import '../../services/favorite_service.dart';
import '../../services/signalr_service.dart';
import '../user/favorites_screen.dart';
import '../user/user_profile_screen.dart';
import '../clubs/clubs_list_screen.dart';
import '../clubs/club_detail_screen.dart';
import '../events/events_list_screen.dart';
import '../events/event_detail_screen.dart';
import '../notifications/notifications_screen.dart';

class LandingPageLogged extends StatefulWidget {
  const LandingPageLogged({super.key});

  @override
  State<LandingPageLogged> createState() => _LandingPageLoggedState();
}

class _LandingPageLoggedState extends State<LandingPageLogged> {
  final OrganizationService _organizationService = OrganizationService();
  final EventService _eventService = EventService();
  final FavoriteService _favoriteService = FavoriteService();
  final SignalRService _signalRService = SignalRService();

  List<Organization> _clubs = [];
  List<Event> _events = [];
  Set<String> _favoriteClubIds = {};
  Set<String> _favoriteEventIds = {};
  bool _isLoading = true;

  StreamSubscription<SignalRNotification>? _notificationSubscription;

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadFavorites();
    _setupNotificationListener();
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    super.dispose();
  }

  void _setupNotificationListener() {
    _notificationSubscription = _signalRService.notificationStream.listen((
      notification,
    ) {
      if (mounted) {
        _showNotificationSnackbar(notification);
      }
    });
  }

  void _showNotificationSnackbar(SignalRNotification notification) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(notification.message, style: const TextStyle(fontSize: 12)),
          ],
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Pogledaj',
          textColor: Colors.white,
          onPressed: () => _navigateToNotifications(),
        ),
      ),
    );
  }

  void _navigateToNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NotificationsScreen()),
    );
  }

  Future<void> _loadFavorites() async {
    final favoriteClubs = await _favoriteService.getFavoriteClubs();
    final favoriteEvents = await _favoriteService.getFavoriteEvents();
    if (mounted) {
      setState(() {
        _favoriteClubIds = favoriteClubs.map((c) => c.id).toSet();
        _favoriteEventIds = favoriteEvents.map((e) => e.id).toSet();
      });
    }
  }

  Future<void> _toggleClubFavorite(Organization club) async {
    final isFavorite = await _favoriteService.toggleClubFavorite(club);
    if (mounted) {
      setState(() {
        if (isFavorite) {
          _favoriteClubIds.add(club.id);
        } else {
          _favoriteClubIds.remove(club.id);
        }
      });
    }
  }

  Future<void> _toggleEventFavorite(Event event) async {
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

  Future<void> _loadData() async {
    try {
      final clubsResponse = await _organizationService.getOrganizations(
        perPage: 2,
      );
      final recommendedResponse = await _eventService.getRecommendedEvents(
        top: 2,
      );
      if (mounted) {
        setState(() {
          if (clubsResponse.success && clubsResponse.data != null) {
            _clubs = clubsResponse.data!.data;
          }
          if (recommendedResponse.success && recommendedResponse.data != null) {
            _events = recommendedResponse.data!;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToClubDetail(Organization club) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ClubDetailScreen(organizationId: club.id, isLoggedIn: true),
      ),
    );
  }

  void _navigateToEventDetail(Event event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            EventDetailScreen(eventId: event.id, isLoggedIn: true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: ActimeAppBar(
        showFavorite: true,
        showNotifications: true,
        onNotificationTap: _navigateToNotifications,
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Clubs & Organizations',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_forward,
                            color: AppColors.primary,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ClubsListScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: _clubs.isEmpty
                          ? [
                              const Expanded(
                                child: Center(
                                  child: Text(
                                    'No clubs available',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                              ),
                            ]
                          : _clubs.asMap().entries.map((entry) {
                              final index = entry.key;
                              final club = entry.value;
                              return Expanded(
                                child: Row(
                                  children: [
                                    if (index > 0) const SizedBox(width: 16),
                                    Expanded(child: _buildClubCard(club)),
                                  ],
                                ),
                              );
                            }).toList(),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Recommended events',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_forward,
                            color: AppColors.primary,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const EventsListScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  if (_events.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(
                        child: Text(
                          'No events available',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: _events.map((event) => EventCard(
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
                          onTap: () => _navigateToEventDetail(event),
                          onFavoriteTap: () => _toggleEventFavorite(event),
                        )).toList(),
                      ),
                    ),
                ],
              ),
            ),
      bottomNavigationBar: const BottomNavUser(currentIndex: -1),
    );
  }

  Widget _buildClubCard(Organization club) {
    final isFavorite = _favoriteClubIds.contains(club.id);

    return GestureDetector(
      onTap: () => _navigateToClubDetail(club),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: AppColors.borderLight,
                      backgroundImage: club.logoUrl != null
                          ? NetworkImage(club.logoUrl!)
                          : null,
                      child: club.logoUrl == null
                          ? Icon(
                              _getCategoryIcon(club.categoryName),
                              size: 25,
                              color: _getCategoryColor(club.categoryName),
                            )
                          : null,
                    ),
                  ],
                ),
                Positioned(
                  top: -4,
                  right: -4,
                  child: GestureDetector(
                    onTap: () => _toggleClubFavorite(club),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        size: 16,
                        color: isFavorite
                            ? AppColors.primary
                            : Colors.grey.shade400,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              club.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              club.categoryName ?? 'Club',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${club.membersCount} members',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.person_outline, size: 14, color: Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }


  IconData _getCategoryIcon(String? category) {
    switch (category?.toLowerCase()) {
      case 'football':
      case 'fudbal':
        return Icons.sports_soccer;
      case 'basketball':
      case 'košarka':
        return Icons.sports_basketball;
      case 'volleyball':
      case 'odbojka':
        return Icons.sports_volleyball;
      case 'tennis':
      case 'tenis':
        return Icons.sports_tennis;
      case 'hiking':
      case 'planinarenje':
        return Icons.hiking;
      case 'swimming':
      case 'plivanje':
        return Icons.pool;
      default:
        return Icons.sports;
    }
  }

  Color _getCategoryColor(String? category) {
    switch (category?.toLowerCase()) {
      case 'football':
      case 'fudbal':
        return Colors.green;
      case 'basketball':
      case 'košarka':
        return Colors.orange;
      case 'volleyball':
      case 'odbojka':
        return Colors.blue;
      case 'tennis':
      case 'tenis':
        return Colors.yellow.shade700;
      case 'hiking':
      case 'planinarenje':
        return Colors.brown;
      case 'swimming':
      case 'plivanje':
        return Colors.cyan;
      default:
        return Colors.teal;
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd.MM.yyyy.').format(date);
  }
}
