import 'package:flutter/material.dart';
import '../../constants/constants.dart';
import '../../components/app_bar_component.dart';
import '../../components/bottom_nav_user.dart';
import '../../components/bottom_nav.dart';
import '../../components/actime_text_field.dart';
import '../user/user_profile_screen.dart';
import '../../components/event_card.dart';
import '../../models/models.dart';
import '../../services/services.dart';
import '../user/favorites_screen.dart';
import '../landing/landing_logged_screen.dart';
import '../landing/landing_not_logged_screen.dart';
import '../auth/sign_in_screen.dart';
import 'club_detail_screen.dart';

class ClubsListScreen extends StatefulWidget {
  final bool isLoggedIn;

  const ClubsListScreen({super.key, this.isLoggedIn = true});

  @override
  State<ClubsListScreen> createState() => _ClubsListScreenState();
}

class _ClubsListScreenState extends State<ClubsListScreen> {
  final _organizationService = OrganizationService();
  final _favoriteService = FavoriteService();
  final _searchController = TextEditingController();

  List<Organization> _organizations = [];
  Set<String> _favoriteClubIds = {};
  bool _isLoading = true;
  String? _error;
  bool _showSearchField = false;
  String _sortBy = 'Name';
  bool _sortDescending = false;

  @override
  void initState() {
    super.initState();
    _loadOrganizations();
    if (widget.isLoggedIn) {
      _loadFavorites();
    }
    _searchController.addListener(_onSearchChanged);
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
        _loadOrganizations();
      }
    });
  }

  Future<void> _loadFavorites() async {
    if (!widget.isLoggedIn) return;
    final favorites = await _favoriteService.getFavoriteClubs();
    if (mounted) {
      setState(() {
        _favoriteClubIds = favorites.map((c) => c.id).toSet();
      });
    }
  }

  Future<void> _toggleFavorite(Organization org) async {
    if (!widget.isLoggedIn) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SignInScreen()),
      );
      return;
    }
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
        search: _searchController.text.isNotEmpty ? _searchController.text : null,
        sortBy: _sortBy,
        sortDescending: _sortDescending,
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
        showFavorite: widget.isLoggedIn,
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
          _buildSearchFilterRow(),
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
      bottomNavigationBar: widget.isLoggedIn
          ? const BottomNavUser(currentIndex: 1)
          : const BottomNav(currentIndex: 1),
    );
  }

  Widget _buildSearchFilterRow() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppDimensions.spacingDefault),
          child: Row(
            children: [
              Expanded(
                child: _showSearchField
                    ? ActimeSearchField(
                        controller: _searchController,
                        hintText: 'Pretraži klubove...',
                      )
                    : const SizedBox.shrink(),
              ),
              if (!_showSearchField) const Spacer(),
              IconButton(
                icon: Icon(
                  _showSearchField ? Icons.close : Icons.search,
                  color: _showSearchField ? AppColors.primary : AppColors.textSecondary,
                ),
                onPressed: () {
                  setState(() {
                    _showSearchField = !_showSearchField;
                    if (!_showSearchField) {
                      _searchController.clear();
                    }
                  });
                },
              ),
              IconButton(
                icon: const Icon(Icons.sort, color: AppColors.textSecondary),
                onPressed: _showSortOptions,
              ),
            ],
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppDimensions.spacingDefault),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sortiraj po',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingDefault),
            _buildSortOption('Naziv (A-Z)', 'Name', false),
            _buildSortOption('Naziv (Z-A)', 'Name', true),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(String label, String sortBy, bool descending) {
    final isSelected = _sortBy == sortBy && _sortDescending == descending;
    return ListTile(
      title: Text(label),
      trailing: isSelected ? const Icon(Icons.check, color: AppColors.primary) : null,
      onTap: () {
        setState(() {
          _sortBy = sortBy;
          _sortDescending = descending;
        });
        _loadOrganizations();
        Navigator.pop(context);
      },
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
        builder: (context) => ClubDetailScreen(
          organizationId: org.id,
          isLoggedIn: widget.isLoggedIn,
        ),
      ),
    );
  }
}
