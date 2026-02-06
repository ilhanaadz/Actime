import 'package:flutter/material.dart';
import '../constants/constants.dart';

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
            borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: AppColors.primary),
            borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.borderLight),
            borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
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
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
          borderSide: BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
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

class ActimeTextFormField extends StatelessWidget {
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
  final String? Function(String?)? validator;
  final AutovalidateMode? autovalidateMode;
  final String? errorText; // Za API validation greške
  final bool enabled;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final void Function(String)? onFieldSubmitted;

  const ActimeTextFormField({
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
    this.validator,
    this.autovalidateMode,
    this.errorText,
    this.enabled = true,
    this.focusNode,
    this.textInputAction,
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    String? combinedValidator(String? value) {
      if (errorText != null && errorText!.isNotEmpty) {
        return errorText;
      }
      return validator?.call(value);
    }

    if (isOutlined) {
      return TextFormField(
        controller: controller,
        obscureText: obscureText,
        readOnly: readOnly,
        onTap: onTap,
        keyboardType: keyboardType,
        maxLines: maxLines,
        onChanged: onChanged,
        validator: combinedValidator,
        autovalidateMode: autovalidateMode ?? AutovalidateMode.onUserInteraction,
        enabled: enabled,
        focusNode: focusNode,
        textInputAction: textInputAction,
        onFieldSubmitted: onFieldSubmitted,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: AppColors.textHint),
          labelText: labelText,
          labelStyle: const TextStyle(color: AppColors.primary),
          prefixIcon: prefixIcon,
          prefixText: prefixText,
          suffixIcon: suffixIcon,
          errorStyle: const TextStyle(
            color: AppColors.red,
            fontSize: 12,
          ),
          errorMaxLines: 3,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.borderLight),
            borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: AppColors.primary),
            borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: AppColors.red),
            borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: AppColors.red, width: 2),
            borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
          ),
          disabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.borderLight.withValues(alpha: 0.5)),
            borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.borderLight),
            borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
          ),
        ),
      );
    }

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      readOnly: readOnly,
      onTap: onTap,
      keyboardType: keyboardType,
      maxLines: maxLines,
      onChanged: onChanged,
      validator: combinedValidator,
      autovalidateMode: autovalidateMode ?? AutovalidateMode.onUserInteraction,
      enabled: enabled,
      focusNode: focusNode,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: AppColors.textHint),
        labelText: labelText,
        labelStyle: const TextStyle(color: AppColors.primary),
        prefixIcon: prefixIcon,
        prefixText: prefixText,
        suffixIcon: suffixIcon,
        errorStyle: const TextStyle(
          color: AppColors.red,
          fontSize: 12,
        ),
        errorMaxLines: 3,
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary),
        ),
        errorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.red),
        ),
        focusedErrorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.red, width: 2),
        ),
        disabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.borderLight.withValues(alpha: 0.5)),
        ),
      ),
    );
  }
}
