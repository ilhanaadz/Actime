import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CircleIconContainer extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final Color? backgroundColor;
  final double size;
  final double iconSize;
  final Widget? badge;

  const CircleIconContainer({
    super.key,
    required this.icon,
    this.iconColor,
    this.backgroundColor,
    this.size = AppSizes.circleMedium,
    this.iconSize = AppSizes.iconLarge,
    this.badge,
  });

  factory CircleIconContainer.small({
    required IconData icon,
    Color? iconColor,
    Color? backgroundColor,
    Widget? badge,
  }) {
    return CircleIconContainer(
      icon: icon,
      iconColor: iconColor,
      backgroundColor: backgroundColor,
      size: AppSizes.circleSmall,
      iconSize: AppSizes.iconDefault,
      badge: badge,
    );
  }

  factory CircleIconContainer.medium({
    required IconData icon,
    Color? iconColor,
    Color? backgroundColor,
    Widget? badge,
  }) {
    return CircleIconContainer(
      icon: icon,
      iconColor: iconColor,
      backgroundColor: backgroundColor,
      size: AppSizes.circleMedium,
      iconSize: AppSizes.iconLarge,
      badge: badge,
    );
  }

  factory CircleIconContainer.large({
    required IconData icon,
    Color? iconColor,
    Color? backgroundColor,
    Widget? badge,
  }) {
    return CircleIconContainer(
      icon: icon,
      iconColor: iconColor,
      backgroundColor: backgroundColor,
      size: AppSizes.circleLarge,
      iconSize: 30,
      badge: badge,
    );
  }

  factory CircleIconContainer.xLarge({
    required IconData icon,
    Color? iconColor,
    Color? backgroundColor,
    Widget? badge,
  }) {
    return CircleIconContainer(
      icon: icon,
      iconColor: iconColor,
      backgroundColor: backgroundColor,
      size: AppSizes.circleXLarge,
      iconSize: AppSizes.iconXLarge,
      badge: badge,
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor = iconColor ?? AppColors.orange;
    final effectiveBackgroundColor = backgroundColor ?? effectiveIconColor.withValues(alpha: 0.1);

    Widget container = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: effectiveBackgroundColor,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: effectiveIconColor, size: iconSize),
    );

    if (badge != null) {
      return Stack(
        children: [
          container,
          Positioned(
            bottom: 0,
            right: 0,
            child: badge!,
          ),
        ],
      );
    }

    return container;
  }
}

class CircleBadge extends StatelessWidget {
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final double size;

  const CircleBadge({
    super.key,
    required this.icon,
    this.backgroundColor = AppColors.primary,
    this.iconColor = AppColors.white,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: iconColor, size: size * 0.6),
    );
  }
}

class FavoriteBadge extends StatelessWidget {
  final double size;

  const FavoriteBadge({super.key, this.size = 16});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Colors.red,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.star,
        color: Colors.white,
        size: size * 0.6,
      ),
    );
  }
}
