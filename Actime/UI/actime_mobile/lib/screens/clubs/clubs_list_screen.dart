import 'package:flutter/material.dart';
import '../../constants/constants.dart';
import '../../components/app_bar_component.dart';
import '../../components/bottom_nav_user.dart';
import '../user/user_profile_screen.dart';
import '../../components/event_card.dart';
import '../../models/models.dart';
import '../../services/services.dart';
import '../user/favorites_screen.dart';
import '../landing/landing_logged_screen.dart';
import 'club_detail_screen.dart';

class ClubsListScreen extends StatefulWidget {
  const ClubsListScreen({super.key});

  @override
  State<ClubsListScreen> createState() => _ClubsListScreenState();
}

class _ClubsListScreenState extends State<ClubsListScreen> {
  final _organizationService = OrganizationService();
  final _favoriteService = FavoriteService();

  List<Organization> _organizations = [];
  Set<String> _favoriteClubIds = {};
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadOrganizations();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final favorites = await _favoriteService.getFavoriteClubs();
    if (mounted) {
      setState(() {
        _favoriteClubIds = favorites.map((c) => c.id).toSet();
      });
    }
  }

  Future<void> _toggleFavorite(Organization org) async {
    final isFavorite = await _favoriteService.toggleClubFavorite(org);
    if (mounted) {
      setState(() {
        if (isFavorite) {
          _favoriteClubIds.add(org.id);
        } else {
          _favoriteClubIds.remove(org.id);
        }
      });
    }
  }

  Future<void> _loadOrganizations() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _organizationService.getOrganizations(
        page: 1,
        perPage: 20,
        sortBy: 'name',
      );

      if (!mounted) return;

      if (response.success && response.data != null) {
        setState(() {
          _organizations = response.data!.data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response.message ?? 'Greška pri učitavanju klubova';
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
        return Icons.groups;
    }
  }

  Color _getCategoryColor(String? categoryName) {
    switch (categoryName?.toLowerCase()) {
      case 'sport':
        return AppColors.red;
      case 'kultura':
        return Colors.purple;
      case 'edukacija':
        return Colors.blue;
      case 'zdravlje':
        return AppColors.red;
      case 'muzika':
        return AppColors.orange;
      case 'tehnologija':
        return Colors.grey;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: ActimeAppBar(
        showFavorite: true,
        showSearch: true,
        showFilter: true,
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
      body: _buildContent(),
      bottomNavigationBar: const BottomNavUser(currentIndex: 1),
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
              onPressed: _loadOrganizations,
              child: const Text('Pokušaj ponovo'),
            ),
          ],
        ),
      );
    }

    if (_organizations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.groups_outlined, size: 48, color: AppColors.textMuted),
            const SizedBox(height: AppDimensions.spacingDefault),
            Text(
              'Nema pronađenih klubova',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadOrganizations,
      color: AppColors.primary,
      child: ListView.separated(
        padding: const EdgeInsets.all(AppDimensions.spacingDefault),
        itemCount: _organizations.length,
        separatorBuilder: (context, index) =>
            const SizedBox(height: AppDimensions.spacingDefault),
        itemBuilder: (context, index) {
          final org = _organizations[index];
          return ClubCard(
            name: org.name,
            sport: org.categoryName ?? 'Klub',
            email: org.email ?? '',
            phone: org.phone ?? '',
            members: org.membersCount.toString(),
            icon: _getCategoryIcon(org.categoryName),
            iconColor: _getCategoryColor(org.categoryName),
            isFavorite: _favoriteClubIds.contains(org.id),
            onTap: () => _navigateToDetail(context, org),
            onFavoriteTap: () => _toggleFavorite(org),
          );
        },
      ),
    );
  }

  void _navigateToDetail(BuildContext context, Organization org) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClubDetailScreen(organizationId: org.id),
      ),
    );
  }
}
