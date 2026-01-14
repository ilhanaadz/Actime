import 'package:flutter/material.dart';

class ActimeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showFavorite;
  final bool showSearch;
  final bool showFilter;
  final VoidCallback? onProfileTap;
  final VoidCallback? onFavoriteTap;
  final VoidCallback? onSearchTap;
  final VoidCallback? onFilterTap;

  const ActimeAppBar({
    super.key,
    this.showFavorite = false,
    this.showSearch = false,
    this.showFilter = false,
    this.onProfileTap,
    this.onFavoriteTap,
    this.onSearchTap,
    this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: const Text(
        'Actime',
        style: TextStyle(
          color: Color(0xFF0D7C8C),
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        if (showSearch)
          IconButton(
            icon: const Icon(Icons.search, color: Color(0xFF0D7C8C)),
            onPressed: onSearchTap ?? () {},
          ),
        if (showFilter)
          IconButton(
            icon: const Icon(Icons.tune, color: Color(0xFF0D7C8C)),
            onPressed: onFilterTap ?? () {},
          ),
        if (showFavorite)
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Color(0xFF0D7C8C)),
            onPressed: onFavoriteTap ?? () {},
          ),
        IconButton(
          icon: const Icon(Icons.person_outline, color: Color(0xFF0D7C8C)),
          onPressed: onProfileTap ?? () {},
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}