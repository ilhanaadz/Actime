import 'package:flutter/material.dart';
import '../constants/constants.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String cancelText;
  final String confirmText;
  final Color? confirmTextColor;
  final VoidCallback? onCancel;
  final VoidCallback? onConfirm;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.cancelText = 'Cancel',
    this.confirmText = 'Confirm',
    this.confirmTextColor,
    this.onCancel,
    this.onConfirm,
  });

  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String message,
    String cancelText = 'Cancel',
    String confirmText = 'Confirm',
    Color? confirmTextColor,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return ConfirmationDialog(
          title: title,
          message: message,
          cancelText: cancelText,
          confirmText: confirmText,
          confirmTextColor: confirmTextColor,
          onCancel: () => Navigator.pop(context, false),
          onConfirm: () => Navigator.pop(context, true),
        );
      },
    );
  }

  static Future<bool?> showDelete({
    required BuildContext context,
    required String itemName,
  }) {
    return show(
      context: context,
      title: 'Delete $itemName',
      message: 'Are you sure you want to delete this $itemName? This action cannot be undone.',
      confirmText: 'Delete',
      confirmTextColor: Colors.red,
    );
  }

  static Future<bool?> showLogout({
    required BuildContext context,
  }) {
    return show(
      context: context,
      title: 'Logout',
      message: 'Are you sure you want to logout?',
      confirmText: 'Logout',
      confirmTextColor: Colors.red,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusXLarge),
      ),
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: onCancel ?? () => Navigator.pop(context),
          child: Text(
            cancelText,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
        TextButton(
          onPressed: onConfirm,
          child: Text(
            confirmText,
            style: TextStyle(color: confirmTextColor ?? AppColors.primary),
          ),
        ),
      ],
    );
  }
}
