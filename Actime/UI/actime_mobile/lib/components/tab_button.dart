import 'package:flutter/material.dart';
import '../constants/constants.dart';

class ActimeTabButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  const ActimeTabButton({
    super.key,
    required this.label,
    required this.isActive,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingDefault,
          vertical: AppDimensions.spacingSmall,
        ),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.borderLight,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? AppColors.white : AppColors.textSecondary,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class ActimeTabBar extends StatelessWidget {
  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int>? onTabChanged;

  const ActimeTabBar({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(tabs.length, (index) {
        return Padding(
          padding: EdgeInsets.only(right: index < tabs.length - 1 ? AppDimensions.spacingDefault : 0),
          child: ActimeTabButton(
            label: tabs[index],
            isActive: selectedIndex == index,
            onTap: () => onTabChanged?.call(index),
          ),
        );
      }),
    );
  }
}
