import 'dart:async';
import 'package:flutter/material.dart';
import '../services/signalr_service.dart';

/// Widget that listens for real-time SignalR notifications
/// and shows them as snackbars or dialogs
class NotificationListenerWidget extends StatefulWidget {
  final Widget child;
  final void Function(SignalRNotification)? onNotification;

  const NotificationListenerWidget({
    super.key,
    required this.child,
    this.onNotification,
  });

  @override
  State<NotificationListenerWidget> createState() => _NotificationListenerWidgetState();
}

class _NotificationListenerWidgetState extends State<NotificationListenerWidget> {
  final SignalRService _signalRService = SignalRService();
  StreamSubscription<SignalRNotification>? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = _signalRService.notificationStream.listen(_handleNotification);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _handleNotification(SignalRNotification notification) {
    // Call custom handler if provided
    widget.onNotification?.call(notification);

    // Show snackbar notification
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                notification.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                notification.message,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF0D7C8C),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Pogledaj',
            textColor: Colors.white,
            onPressed: () {
              _navigateToNotification(notification);
            },
          ),
        ),
      );
    }
  }

  void _navigateToNotification(SignalRNotification notification) {
    // TODO: Implement navigation based on notification type
    // Example:
    // if (notification.eventId != null) {
    //   Navigator.push(context, MaterialPageRoute(
    //     builder: (_) => EventDetailScreen(eventId: notification.eventId!),
    //   ));
    // }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
