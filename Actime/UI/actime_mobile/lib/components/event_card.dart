import 'package:flutter/material.dart';
import '../constants/constants.dart';
import 'circle_icon_container.dart';
import 'actime_button.dart';

class EventCard extends StatelessWidget {
  final String title;
  final String price;
  final String date;
  final String location;
  final String participants;
  final IconData icon;
  final Color? iconColor;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;
  final VoidCallback? onEditTap;
  final VoidCallback? onDeleteTap;
  final bool showFavorite;
  final bool showEditButton;
  final bool showDeleteButton;
  final bool isFavorite;

  const EventCard({
    super.key,
    required this.title,
    required this.price,
    required this.date,
    required this.location,
    required this.participants,
    required this.icon,
    this.iconColor,
    this.onTap,
    this.onFavoriteTap,
    this.onEditTap,
    this.onDeleteTap,
    this.showFavorite = true,
    this.showEditButton = false,
    this.showDeleteButton = false,
    this.isFavorite = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor = iconColor ?? AppColors.orange;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: AppDimensions.spacingDefault),
            padding: const EdgeInsets.all(AppDimensions.spacingDefault),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleIconContainer(
                      icon: icon,
                      iconColor: effectiveIconColor,
                      backgroundColor: effectiveIconColor.withValues(alpha: 0.1),
                    ),
                    const SizedBox(width: AppDimensions.spacingDefault),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          PriceBadge(price: price),
                          const SizedBox(height: AppDimensions.spacingSmall),
                          Row(
                            children: [
                              const Icon(Icons.person_outline, size: 14, color: AppColors.textSecondary),
                              const SizedBox(width: AppDimensions.spacingXSmall),
                              Text(
                                participants,
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppDimensions.spacingXSmall),
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spacingDefault),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Text(date, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                            const SizedBox(width: AppDimensions.spacingXSmall),
                            const Icon(Icons.calendar_today, size: 12, color: AppColors.textSecondary),
                          ],
                        ),
                        const SizedBox(height: AppDimensions.spacingXSmall),
                        Row(
                          children: [
                            Text(location, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                            const SizedBox(width: AppDimensions.spacingXSmall),
                            const Icon(Icons.location_on_outlined, size: 12, color: AppColors.textSecondary),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                if (showEditButton || showDeleteButton) ...[
                  const SizedBox(height: AppDimensions.spacingMedium),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (showEditButton)
                        ActimeSmallOutlinedButton(
                          label: 'Edit',
                          onPressed: onEditTap,
                        ),
                      if (showEditButton && showDeleteButton)
                        const SizedBox(width: AppDimensions.spacingMedium),
                      if (showDeleteButton)
                        ActimeSmallOutlinedButton(
                          label: 'Delete',
                          onPressed: onDeleteTap,
                          borderColor: AppColors.red,
                          textColor: AppColors.red,
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          // Favorite button positioned at top-right corner
          if (showFavorite)
            Positioned(
              top: AppDimensions.spacingSmall,
              right: AppDimensions.spacingSmall,
              child: GestureDetector(
                onTap: onFavoriteTap,
                child: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  size: 20,
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class PriceBadge extends StatelessWidget {
  final String price;
  final Color? backgroundColor;
  final Color? textColor;

  const PriceBadge({
    super.key,
    required this.price,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingSmall,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.primary,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSmall),
      ),
      child: Text(
        price,
        style: TextStyle(
          color: textColor ?? AppColors.white,
          fontSize: 10,
        ),
      ),
    );
  }
}

class ClubCard extends StatelessWidget {
  final String name;
  final String sport;
  final String email;
  final String phone;
  final String members;
  final IconData icon;
  final Color iconColor;
  final bool isFavorite;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;

  const ClubCard({
    super.key,
    required this.name,
    required this.sport,
    required this.email,
    required this.phone,
    required this.members,
    required this.icon,
    required this.iconColor,
    this.isFavorite = false,
    this.onTap,
    this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.spacingDefault),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Stack(
                  children: [
                    CircleIconContainer(
                      icon: icon,
                      iconColor: iconColor,
                      backgroundColor: iconColor.withValues(alpha: 0.1),
                    ),
                    if (isFavorite)
                      const Positioned(
                        top: 0,
                        right: 0,
                        child: FavoriteBadge(),
                      ),
                  ],
                ),
                const SizedBox(width: AppDimensions.spacingDefault),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingXSmall),
                      Text(
                        sport,
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: AppDimensions.spacingSmall),
                      Text(
                        email,
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                      Text(
                        phone,
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Text(
                      members,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spacingXSmall),
                    const Icon(Icons.person_outline, size: 16, color: AppColors.textSecondary),
                  ],
                ),
              ],
            ),
          ),
          // Favorite button positioned at top-right corner
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: onFavoriteTap,
              child: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                size: 20,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ClubItemSmall extends StatelessWidget {
  final String name;
  final String sport;
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onTap;

  const ClubItemSmall({
    super.key,
    required this.name,
    required this.sport,
    required this.icon,
    required this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.spacingMedium),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            CircleIconContainer.small(
              icon: icon,
              iconColor: iconColor,
              backgroundColor: iconColor.withValues(alpha: 0.1),
            ),
            const SizedBox(width: AppDimensions.spacingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    sport,
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
