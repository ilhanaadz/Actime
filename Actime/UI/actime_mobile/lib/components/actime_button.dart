import 'package:flutter/material.dart';
import '../constants/constants.dart';

class ActimePrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? width;
  final double height;

  const ActimePrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.width,
    this.height = AppDimensions.buttonHeight,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.borderRadiusRound),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}

class ActimeOutlinedButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color? borderColor;
  final Color? textColor;
  final IconData? icon;
  final double? width;
  final double height;

  const ActimeOutlinedButton({
    super.key,
    required this.label,
    this.onPressed,
    this.borderColor,
    this.textColor,
    this.icon,
    this.width,
    this.height = AppDimensions.buttonHeight,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderColor = borderColor ?? AppColors.primary;
    final effectiveTextColor = textColor ?? AppColors.primary;

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: icon != null
          ? OutlinedButton.icon(
              onPressed: onPressed,
              icon: Icon(icon, color: effectiveTextColor),
              label: Text(
                label,
                style: TextStyle(color: effectiveTextColor, fontSize: 16),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: effectiveBorderColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.borderRadiusRound),
                ),
              ),
            )
          : OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: effectiveBorderColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.borderRadiusRound),
                ),
              ),
              child: Text(
                label,
                style: TextStyle(color: effectiveTextColor, fontSize: 16),
              ),
            ),
    );
  }
}

class ActimeSmallOutlinedButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color? borderColor;
  final Color? textColor;

  const ActimeSmallOutlinedButton({
    super.key,
    required this.label,
    this.onPressed,
    this.borderColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderColor = borderColor ?? AppColors.primary;
    final effectiveTextColor = textColor ?? AppColors.primary;

    return SizedBox(
      width: double.infinity,
      height: AppDimensions.buttonHeightSmall,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: effectiveBorderColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(color: effectiveTextColor),
        ),
      ),
    );
  }
}

class ActimeTextButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color? textColor;
  final FontWeight? fontWeight;

  const ActimeTextButton({
    super.key,
    required this.label,
    this.onPressed,
    this.textColor,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        label,
        style: TextStyle(
          color: textColor ?? AppColors.primary,
          fontSize: 14,
          fontWeight: fontWeight,
        ),
      ),
    );
  }
}
