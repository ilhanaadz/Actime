import 'dart:async';
import 'package:flutter/material.dart';
import '../constants/constants.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import '../services/signalr_service.dart';
import '../services/notification_badge_controller.dart';

/// Notification bell icon with badge showing unread count
/// Automatically updates when new notifications arrive via SignalR
class NotificationBadge extends StatefulWidget {
  final VoidCallback? onTap;
  final Color? iconColor;
  final double iconSize;

  const NotificationBadge({
    super.key,
    this.onTap,
    this.iconColor,
    this.iconSize = 24,
  });

  @override
  State<NotificationBadge> createState() => _NotificationBadgeState();
}

class _NotificationBadgeState extends State<NotificationBadge>
    with SingleTickerProviderStateMixin {
  final NotificationService _notificationService = NotificationService();
  final SignalRService _signalRService = SignalRService();
  final AuthService _authService = AuthService();
  final NotificationBadgeController _badgeController = NotificationBadgeController();

  int _unreadCount = 0;
  StreamSubscription<SignalRNotification>? _signalRSubscription;
  StreamSubscription<void>? _refreshSubscription;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadUnreadCount();
    _setupSignalRListener();
    _setupRefreshListener();
  }

  @override
  void dispose() {
    _signalRSubscription?.cancel();
    _refreshSubscription?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );
  }

  void _setupSignalRListener() {
    _signalRSubscription = _signalRService.notificationStream.listen((_) {
      // Increment count and play animation when new notification arrives
      setState(() {
        _unreadCount++;
      });
      _playBounceAnimation();
    });
  }

  void _setupRefreshListener() {
    _refreshSubscription = _badgeController.refreshStream.listen((_) {
      _loadUnreadCount();
    });
  }

  void _playBounceAnimation() {
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
  }

  Future<void> _loadUnreadCount() async {
    final userId = _authService.currentUserId;
    if (userId == null) return;

    try {
      final response = await _notificationService.getUnreadCount(userId);
      if (response.success && mounted) {
        setState(() {
          _unreadCount = response.data ?? 0;
        });
      }
    } catch (e) {
      debugPrint('Error loading unread count: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onTap?.call();
        // Reset count when user taps (assumes they'll view notifications)
        // The actual count will be refreshed when they return
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ScaleTransition(
            scale: _scaleAnimation,
            child: Icon(
              Icons.notifications_outlined,
              color: widget.iconColor ?? AppColors.primary,
              size: widget.iconSize,
            ),
          ),
          if (_unreadCount > 0)
            Positioned(
              right: -6,
              top: -4,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.all(_unreadCount > 9 ? 4 : 6),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 18,
                  minHeight: 18,
                ),
                child: Center(
                  child: Text(
                    _unreadCount > 99 ? '99+' : _unreadCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
