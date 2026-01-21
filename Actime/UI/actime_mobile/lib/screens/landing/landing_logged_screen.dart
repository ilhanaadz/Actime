import 'package:flutter/material.dart';
import '../../components/app_bar_component.dart';
import '../../components/bottom_nav_user.dart';
import '../../constants/constants.dart';
import '../../models/models.dart';
import '../../services/organization_service.dart';
import '../../services/event_service.dart';
import '../user/favorites_screen.dart';
import '../user/user_profile_screen.dart';
import '../clubs/clubs_list_screen.dart';
import '../clubs/club_detail_screen.dart';
import '../events/events_list_screen.dart';
import '../events/event_detail_screen.dart';

class LandingPageLogged extends StatefulWidget {
  const LandingPageLogged({super.key});

  @override
  State<LandingPageLogged> createState() => _LandingPageLoggedState();
}

class _LandingPageLoggedState extends State<LandingPageLogged> {
  final OrganizationService _organizationService = OrganizationService();
  final EventService _eventService = EventService();
  List<Organization> _clubs = [];
  List<Event> _events = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final clubsResponse = await _organizationService.getOrganizations(perPage: 2);
      final eventsResponse = await _eventService.getEvents(perPage: 2);
      if (mounted) {
        setState(() {
          if (clubsResponse.success && clubsResponse.data != null) {
            _clubs = clubsResponse.data!.data;
          }
          if (eventsResponse.success && eventsResponse.data != null) {
            _events = eventsResponse.data!.data;
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
        builder: (context) => ClubDetailScreen(
          organizationId: club.id,
          isLoggedIn: true,
        ),
      ),
    );
  }

  void _navigateToEventDetail(Event event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventDetailScreen(
          eventId: event.id,
          isLoggedIn: true,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: ActimeAppBar(
        showFavorite: true,
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
                          icon: const Icon(Icons.arrow_forward, color: AppColors.primary),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ClubsListScreen()),
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
                                  child: Text('No clubs available', style: TextStyle(color: Colors.grey)),
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
                                    Expanded(
                                      child: _buildClubCard(club),
                                    ),
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
                          icon: const Icon(Icons.arrow_forward, color: AppColors.primary),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const EventsListScreen()),
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
                        child: Text('No events available', style: TextStyle(color: Colors.grey)),
                      ),
                    )
                  else
                    ..._events.map((event) => _buildEventCard(event)),
                ],
              ),
            ),
      bottomNavigationBar: const BottomNavUser(currentIndex: -1),
    );
  }

  Widget _buildClubCard(Organization club) {
    final icon = _getCategoryIcon(club.categoryName);
    final iconColor = _getCategoryColor(club.categoryName);

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
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 30),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Icon(Icons.favorite_border, size: 16, color: Colors.grey.shade400),
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
                Text('${club.membersCount} members', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(width: 4),
                const Icon(Icons.person_outline, size: 14, color: Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(Event event) {
    final icon = _getCategoryIcon(event.categoryName);

    return GestureDetector(
      onTap: () => _navigateToEventDetail(event),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.orange, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          event.formattedPrice,
                          style: const TextStyle(color: Colors.white, fontSize: 10),
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.favorite_border, size: 20, color: AppColors.primary),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.person_outline, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text('${event.participantsCount}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    event.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Text(
                      _formatDate(event.startDate),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.calendar_today, size: 12, color: Colors.grey),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      event.location ?? '',
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.location_on_outlined, size: 12, color: Colors.grey),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }
}
