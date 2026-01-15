import 'package:flutter/material.dart';
import '../constants/constants.dart';

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? iconColor;
  final bool useContainer;
  final double containerSize;
  final BorderRadius? borderRadius;

  const InfoRow({
    super.key,
    required this.icon,
    required this.text,
    this.iconColor,
    this.useContainer = true,
    this.containerSize = AppDimensions.circleSmall,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor = iconColor ?? AppColors.primary;
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(AppDimensions.borderRadiusMedium);

    return Row(
      children: [
        if (useContainer)
          Container(
            width: containerSize,
            height: containerSize,
            decoration: BoxDecoration(
              color: effectiveIconColor.withValues(alpha: 0.1),
              borderRadius: effectiveBorderRadius,
            ),
            child: Icon(icon, color: effectiveIconColor, size: AppDimensions.iconDefault),
          )
        else
          Icon(icon, color: effectiveIconColor, size: AppDimensions.iconDefault),
        const SizedBox(width: AppDimensions.spacingMedium),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class ProfileInfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const ProfileInfoRow({
    super.key,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingDefault),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: AppDimensions.iconDefault),
          const SizedBox(width: AppDimensions.spacingDefault),
          Text(
            text,
            style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}

class ProfileField extends StatelessWidget {
  final String label;
  final String value;
  final bool hasEdit;
  final bool isMultiline;
  final VoidCallback? onEditTap;

  const ProfileField({
    super.key,
    required this.label,
    required this.value,
    this.hasEdit = false,
    this.isMultiline = false,
    this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
            if (hasEdit)
              GestureDetector(
                onTap: onEditTap,
                child: const Icon(
                  Icons.edit_outlined,
                  size: 20,
                  color: AppColors.primary,
                ),
              ),
          ],
        ),
        const SizedBox(height: AppDimensions.spacingXSmall),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
