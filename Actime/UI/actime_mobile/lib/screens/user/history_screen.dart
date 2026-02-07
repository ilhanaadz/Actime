import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../constants/constants.dart';
import '../../components/app_bar_component.dart';
import '../../components/bottom_nav_user.dart';
import 'user_profile_screen.dart';
import '../../models/models.dart';
import '../../services/services.dart';
import '../../services/image_service.dart';
import 'favorites_screen.dart';
import '../landing/landing_logged_screen.dart';
import '../notifications/notifications_screen.dart';
import '../clubs/club_detail_screen.dart';
import '../events/event_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _userService = UserService();
  final _authService = AuthService();
  final _participationService = ParticipationService();
  final _eventService = EventService();

  List<Enrollment> _memberships = [];
  List<Event> _events = [];
  bool _isLoading = true;
  String? _error;
  int _selectedTab = 0; // 0 = Memberships, 1 = Events

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
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        setState(() {
          _error = 'Niste prijavljeni';
          _isLoading = false;
        });
        return;
      }

      // Load memberships and user participated events using new endpoint
      final membershipResponse = await _userService.getUserMemberships();
      final eventsResponse = await _participationService.getParticipatedEvents(
        int.parse(currentUser.id),
      );

      if (!mounted) return;

      setState(() {
        if (membershipResponse.success && membershipResponse.data != null) {
          _memberships = membershipResponse.data!;
        }
        if (eventsResponse.success && eventsResponse.data != null) {
          // Sort events by start date (newest first)
          _events = eventsResponse.data!;
          _events.sort((a, b) => b.startDate.compareTo(a.startDate));
        }
        _isLoading = false;
      });
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

  Future<void> _showCancelMembershipDialog(Enrollment membership) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Confirmation',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: const Text(
          'Are you sure you want to cancel membership?',
          style: TextStyle(fontSize: 14),
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
              'No',
              style: TextStyle(color: Colors.black87),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFF8B4A5E),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Yes',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (result == true) {
      await _cancelMembership(membership);
    }
  }

  Future<void> _cancelMembership(Enrollment membership) async {
    final response = await _userService.cancelMembership(membership.id);
    if (response.success) {
      // Refresh user data to update organization counts
      await _authService.getCurrentUser();
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Članstvo je uspješno otkazano')),
        );
      }
    }
  }

  Future<void> _showCancelEventDialog(Event event) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Confirmation',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: const Text(
          'Are you sure you want to cancel your registration for this event?',
          style: TextStyle(fontSize: 14),
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
              'No',
              style: TextStyle(color: Colors.black87),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFF8B4A5E),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Yes',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (result == true) {
      await _cancelEvent(event);
    }
  }

  Future<void> _cancelEvent(Event event) async {
    final response = await _eventService.leaveEvent(event.id);
    if (response.success) {
      // Refresh user data to update event counts
      await _authService.getCurrentUser();
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registracija je uspješno otkazana')),
        );
      }
    }
  }

  bool _canCancelEvent(Event event) {
    final now = DateTime.now();
    final hasNotPassed = event.startDate.isAfter(now);
    return hasNotPassed;
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
        onNotificationTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NotificationsScreen()),
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
          // Tab buttons
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: _buildTabButton('Memberships', 0),
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
      bottomNavigationBar: const BottomNavUser(currentIndex: 2),
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

    if (_selectedTab == 0) {
      return _buildMembershipsList();
    } else {
      return _buildEventsList();
    }
  }

  Widget _buildMembershipsList() {
    if (_memberships.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.card_membership, size: 48, color: AppColors.textMuted),
            const SizedBox(height: AppDimensions.spacingDefault),
            Text(
              'Nemate aktivnih članstava',
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
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _memberships.length,
        itemBuilder: (context, index) {
          final membership = _memberships[index];
          return _buildMembershipCard(membership);
        },
      ),
    );
  }

  Widget _buildMembershipCard(Enrollment membership) {
    final org = membership.organization;
    return GestureDetector(
      onTap: () {
        if (org != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ClubDetailScreen(organizationId: org.id),
            ),
          ).then((_) => _loadData());
        }
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
            // Organization logo/icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                shape: BoxShape.circle,
              ),
              child: org?.logo != null
                  ? ClipOval(
                      child: Image.network(
                        org!.logo!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildOrgIcon(org.categoryName);
                        },
                      ),
                    )
                  : _buildOrgIcon(org?.categoryName),
            ),
            const SizedBox(width: 16),
            // Organization info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    org?.name ?? 'Nepoznat klub',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    org?.categoryName ?? 'Klub',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            // Remove button
            IconButton(
              icon: Icon(Icons.remove_circle_outline, color: Colors.grey.shade400),
              onPressed: () => _showCancelMembershipDialog(membership),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrgIcon(String? categoryName) {
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

  Widget _buildEventsList() {
    if (_events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 48, color: AppColors.textMuted),
            const SizedBox(height: AppDimensions.spacingDefault),
            Text(
              'Nemate historiju događaja',
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
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _events.length,
        itemBuilder: (context, index) {
          final event = _events[index];
          return _buildEventCard(event);
        },
      ),
    );
  }

  Widget _buildOrgLogo(Event event) {
    final logoUrl = ImageService().getFullImageUrl(event.organizationLogoUrl);
    if (logoUrl.isNotEmpty) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey.shade200,
        ),
        child: ClipOval(
          child: Image.network(
            logoUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Icon(Icons.event, color: Colors.grey.shade400, size: 20);
            },
          ),
        ),
      );
    }
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.orange.withValues(alpha: 0.1),
      ),
      child: const Icon(Icons.event, color: Colors.orange, size: 20),
    );
  }

  Widget _buildEventCard(Event event) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetailScreen(eventId: event.id),
          ),
        ).then((_) => _loadData());
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
            // Organization logo
            _buildOrgLogo(event),
            const SizedBox(width: 12),
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
                  Row(
                    children: [
                      Text(
                        event.activityTypeName ?? 'Dogadjaj',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
                ],
              ),
            ),
            // Date and cancel button
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatDate(event.startDate),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade400),
                  ],
                ),
                if (_canCancelEvent(event))
                  IconButton(
                    icon: Icon(Icons.remove_circle_outline, color: Colors.grey.shade400),
                    onPressed: () => _showCancelEventDialog(event),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}