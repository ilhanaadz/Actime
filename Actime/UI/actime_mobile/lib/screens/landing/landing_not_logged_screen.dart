import 'package:actime_mobile/constants/app_colors.dart';
import 'package:flutter/material.dart';
import '../../components/app_bar_component.dart';
import '../../components/bottom_nav.dart';
import '../../models/models.dart';
import '../../services/organization_service.dart';
import '../../services/event_service.dart';
import '../../services/image_service.dart';
import '../auth/sign_in_screen.dart';
import '../events/events_list_screen.dart';
import '../events/event_detail_screen.dart';
import '../clubs/clubs_list_screen.dart';
import '../clubs/club_detail_screen.dart';

class LandingPageNotLogged extends StatefulWidget {
  const LandingPageNotLogged({super.key});

  @override
  State<LandingPageNotLogged> createState() => _LandingPageNotLoggedState();
}

class _LandingPageNotLoggedState extends State<LandingPageNotLogged> {
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
      final eventsResponse = await _eventService.getEvents(perPage: 3);
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
          isLoggedIn: false,
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
          isLoggedIn: false,
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
        showNotifications: false,
        onProfileTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SignInScreen()),
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
                            color: Color(0xFF0D7C8C),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward, color: Color(0xFF0D7C8C)),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ClubsListScreen(isLoggedIn: false),
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
                          'Join our popular events',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0D7C8C),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward, color: Color(0xFF0D7C8C)),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const EventsListScreen(isLoggedIn: false),
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
                        child: Text('No events available', style: TextStyle(color: Colors.grey)),
                      ),
                    )
                  else
                    ..._events.map((event) => _buildEventCard(event)),
                ],
              ),
            ),
      bottomNavigationBar: const BottomNav(currentIndex: -1),
    );
  }

  Widget _buildClubCard(Organization club) {
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
                CircleAvatar(
                  radius: 25,
                  backgroundColor: AppColors.borderLight,
                  backgroundImage: club.logoUrl != null
                      ? NetworkImage(club.logoUrl!)
                      : null,
                  child: club.logoUrl == null
                      ? Icon(_getCategoryIcon(club.categoryName), size: 25, color: _getCategoryColor(club.categoryName))
                      : null,
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
    final icon = Icons.event;
    final logoUrl = ImageService().getFullImageUrl(event.organizationLogoUrl);

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
              child: logoUrl.isNotEmpty
                  ? ClipOval(
                      child: Image.network(
                        logoUrl,
                        fit: BoxFit.cover,
                        width: 50,
                        height: 50,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(icon, color: Colors.orange, size: 24);
                        },
                      ),
                    )
                  : Icon(icon, color: Colors.orange, size: 24),
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
                          color: const Color(0xFF0D7C8C),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          event.formattedPrice,
                          style: const TextStyle(color: Colors.white, fontSize: 10),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: event.status.color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: event.status.color, width: 1),
                        ),
                        child: Text(
                          event.status.displayName,
                          style: TextStyle(color: event.status.color, fontSize: 10, fontWeight: FontWeight.w500),
                        ),
                      ),
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
                      color: Color(0xFF0D7C8C),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
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
