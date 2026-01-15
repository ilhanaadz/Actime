import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ActimeTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final bool obscureText;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final String? prefixText;
  final bool readOnly;
  final VoidCallback? onTap;
  final TextInputType? keyboardType;
  final int maxLines;
  final bool isOutlined;
  final ValueChanged<String>? onChanged;

  const ActimeTextField({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.obscureText = false,
    this.suffixIcon,
    this.prefixIcon,
    this.prefixText,
    this.readOnly = false,
    this.onTap,
    this.keyboardType,
    this.maxLines = 1,
    this.isOutlined = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (isOutlined) {
      return TextField(
        controller: controller,
        obscureText: obscureText,
        readOnly: readOnly,
        onTap: onTap,
        keyboardType: keyboardType,
        maxLines: maxLines,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: AppColors.textHint),
          labelText: labelText,
          labelStyle: const TextStyle(color: AppColors.primary),
          prefixIcon: prefixIcon,
          prefixText: prefixText,
          suffixIcon: suffixIcon,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.borderLight),
            borderRadius: BorderRadius.circular(AppSizes.borderRadiusMedium),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: AppColors.primary),
            borderRadius: BorderRadius.circular(AppSizes.borderRadiusMedium),
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.borderLight),
            borderRadius: BorderRadius.circular(AppSizes.borderRadiusMedium),
          ),
        ),
      );
    }

    return TextField(
      controller: controller,
      obscureText: obscureText,
      readOnly: readOnly,
      onTap: onTap,
      keyboardType: keyboardType,
      maxLines: maxLines,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: AppColors.textHint),
        labelText: labelText,
        labelStyle: const TextStyle(color: AppColors.primary),
        prefixIcon: prefixIcon,
        prefixText: prefixText,
        suffixIcon: suffixIcon,
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }
}

class ActimeSearchField extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final ValueChanged<String>? onChanged;

  const ActimeSearchField({
    super.key,
    this.controller,
    this.hintText = 'Search...',
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.search, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.borderRadiusMedium),
          borderSide: BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.borderRadiusMedium),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }
}

class ActimeDropdownField<T> extends StatelessWidget {
  final T? initialValue;
  final String? labelText;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;

  const ActimeDropdownField({
    super.key,
    this.initialValue,
    this.labelText,
    required this.items,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: AppColors.primary),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary),
        ),
      ),
      items: items,
      onChanged: onChanged,
    );
  }
}
