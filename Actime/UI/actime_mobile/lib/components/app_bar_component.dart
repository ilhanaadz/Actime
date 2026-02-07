import 'package:flutter/material.dart';
import 'notification_badge.dart';

class ActimeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showFavorite;
  final bool showSearch;
  final bool showFilter;
  final bool showNotifications;
  final VoidCallback? onProfileTap;
  final VoidCallback? onFavoriteTap;
  final VoidCallback? onSearchTap;
  final VoidCallback? onFilterTap;
  final VoidCallback? onLogoTap;
  final VoidCallback? onNotificationTap;

  const ActimeAppBar({
    super.key,
    this.showFavorite = false,
    this.showSearch = false,
    this.showFilter = false,
    this.showNotifications = true,
    this.onProfileTap,
    this.onFavoriteTap,
    this.onSearchTap,
    this.onFilterTap,
    this.onLogoTap,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: GestureDetector(
        onTap: onLogoTap,
        child: const Text(
          'Actime',
          style: TextStyle(
            color: Color(0xFF0D7C8C),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
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
        if (showNotifications)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: NotificationBadge(
              key: notificationBadgeKey,
              onTap: onNotificationTap,
              iconColor: const Color(0xFF0D7C8C),
            ),
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
