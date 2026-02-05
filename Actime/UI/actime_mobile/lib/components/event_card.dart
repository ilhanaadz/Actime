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
  final String? imageUrl;
  final String? statusText;
  final Color? statusColor;
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
    this.imageUrl,
    this.statusText,
    this.statusColor,
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
              borderRadius: BorderRadius.circular(
                AppDimensions.borderRadiusLarge,
              ),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (imageUrl != null && imageUrl!.isNotEmpty)
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: effectiveIconColor.withValues(alpha: 0.1),
                        ),
                        child: ClipOval(
                          child: Image.network(
                            imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                icon,
                                color: effectiveIconColor,
                                size: 24,
                              );
                            },
                          ),
                        ),
                      )
                    else
                      CircleIconContainer(
                        icon: icon,
                        iconColor: effectiveIconColor,
                        backgroundColor: effectiveIconColor.withValues(
                          alpha: 0.1,
                        ),
                      ),
                    const SizedBox(width: AppDimensions.spacingDefault),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: AppDimensions.spacingSmall,
                            runSpacing: AppDimensions.spacingXSmall,
                            children: [
                              PriceBadge(price: price),
                              if (statusText != null)
                                StatusBadge(
                                  status: statusText!,
                                  color: statusColor,
                                ),
                            ],
                          ),
                          const SizedBox(height: AppDimensions.spacingSmall),
                          Row(
                            children: [
                              const Icon(
                                Icons.person_outline,
                                size: 14,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(
                                width: AppDimensions.spacingXSmall,
                              ),
                              Flexible(
                                child: Text(
                                  participants,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
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
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.spacingSmall),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: AppDimensions.spacingXSmall),
                    Expanded(
                      child: Text(
                        date,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spacingDefault),
                    const Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: AppDimensions.spacingXSmall),
                    Flexible(
                      child: Text(
                        location,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
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
        style: TextStyle(color: textColor ?? AppColors.white, fontSize: 10),
      ),
    );
  }
}

class StatusBadge extends StatelessWidget {
  final String status;
  final Color? color;

  const StatusBadge({super.key, required this.status, this.color});

  @override
  Widget build(BuildContext context) {
    final badgeColor = color ?? AppColors.orange;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingSmall,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSmall),
        border: Border.all(color: badgeColor, width: 1),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: badgeColor,
          fontSize: 10,
          fontWeight: FontWeight.w500,
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
  final bool isFavorite;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;
  final String? imageUrl;

  const ClubCard({
    super.key,
    required this.name,
    required this.sport,
    required this.email,
    required this.phone,
    required this.members,
    this.isFavorite = false,
    this.onTap,
    this.onFavoriteTap,
    this.imageUrl,
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
              borderRadius: BorderRadius.circular(
                AppDimensions.borderRadiusLarge,
              ),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: AppColors.borderLight,
                      backgroundImage: imageUrl != null
                          ? NetworkImage(imageUrl!)
                          : null,
                      child: imageUrl == null
                          ? Icon(
                              _getCategoryIcon(sport),
                              size: 25,
                              color: _getCategoryColor(sport),
                            )
                          : null,
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
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingSmall),
                      Text(
                        email,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        phone,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
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
                    const Icon(
                      Icons.person_outline,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
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

class ClubItemSmall extends StatelessWidget {
  final String name;
  final String sport;
  final VoidCallback? onTap;
  final String? imageUrl;

  const ClubItemSmall({
    super.key,
    required this.name,
    required this.sport,
    this.onTap,
    this.imageUrl,
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
            Stack(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: AppColors.borderLight,
                  backgroundImage: imageUrl != null
                      ? NetworkImage(imageUrl!)
                      : null,
                  child: imageUrl == null
                      ? Icon(_getCategoryIcon(sport), size: 25, color: _getCategoryColor(sport))
                      : null,
                ),
              ],
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
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
