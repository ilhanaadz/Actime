import 'package:flutter/material.dart';
import '../../constants/constants.dart';
import '../../models/notification.dart';
import '../../services/notification_service.dart';
import '../../services/signalr_service.dart';
import '../../components/notification_badge.dart';
import 'dart:async';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _notificationService = NotificationService();
  final SignalRService _signalRService = SignalRService();

  List<AppNotification> _notifications = [];
  bool _isLoading = true;
  bool _hasMore = true;
  int _currentPage = 1;
  final int _pageSize = 20;

  StreamSubscription<SignalRNotification>? _signalRSubscription;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadNotifications();
    _setupSignalRListener();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _signalRSubscription?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _setupSignalRListener() {
    _signalRSubscription = _signalRService.notificationStream.listen((notification) {
      // Add new notification to the top of the list
      setState(() {
        _notifications.insert(0, AppNotification(
          id: DateTime.now().millisecondsSinceEpoch,
          userId: 0,
          title: notification.title,
          message: notification.message,
          isRead: false,
          createdAt: notification.timestamp,
        ));
      });
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoading && _hasMore) {
        _loadMoreNotifications();
      }
    }
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _currentPage = 1;
    });

    try {
      final response = await _notificationService.getNotifications(
        page: _currentPage,
        pageSize: _pageSize,
      );

      if (mounted) {
        setState(() {
          if (response.success && response.data != null) {
            _notifications = response.data!.items;
            _hasMore = response.data!.items.length >= _pageSize;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadMoreNotifications() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    _currentPage++;

    try {
      final response = await _notificationService.getNotifications(
        page: _currentPage,
        pageSize: _pageSize,
      );

      if (mounted) {
        setState(() {
          if (response.success && response.data != null) {
            _notifications.addAll(response.data!.items);
            _hasMore = response.data!.items.length >= _pageSize;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _currentPage--;
        });
      }
    }
  }

  Future<void> _markAsRead(AppNotification notification) async {
    if (notification.isRead) return;

    final response = await _notificationService.markAsRead(notification.id);
    if (response.success && mounted) {
      setState(() {
        final index = _notifications.indexWhere((n) => n.id == notification.id);
        if (index != -1) {
          _notifications[index] = AppNotification(
            id: notification.id,
            userId: notification.userId,
            title: notification.title,
            message: notification.message,
            isRead: true,
            createdAt: notification.createdAt,
            readAt: DateTime.now(),
          );
        }
      });

      notificationBadgeKey.currentState?.refreshCount();
    }
  }

  Future<void> _markAllAsRead() async {
    final unreadNotifications = _notifications.where((n) => !n.isRead).toList();
    if (unreadNotifications.isEmpty) return;

    setState(() {
      for (var i = 0; i < _notifications.length; i++) {
        if (!_notifications[i].isRead) {
          _notifications[i] = AppNotification(
            id: _notifications[i].id,
            userId: _notifications[i].userId,
            title: _notifications[i].title,
            message: _notifications[i].message,
            isRead: true,
            createdAt: _notifications[i].createdAt,
            readAt: DateTime.now(),
          );
        }
      }
    });

    for (var notification in unreadNotifications) {
      await _notificationService.markAsRead(notification.id);
    }

    notificationBadgeKey.currentState?.refreshCount();
  }

  Future<void> _deleteNotification(AppNotification notification) async {
    final response = await _notificationService.deleteNotification(notification.id);
    if (response.success && mounted) {
      setState(() {
        _notifications.removeWhere((n) => n.id == notification.id);
      });
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Upravo sada';
    } else if (difference.inMinutes < 60) {
      return 'Prije ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Prije ${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return 'Prije ${difference.inDays}d';
    } else {
      return '${dateTime.day}.${dateTime.month}.${dateTime.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Notifikacije',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primary),
        actions: [
          if (_notifications.any((n) => !n.isRead))
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text(
                'Oznaci sve',
                style: TextStyle(color: AppColors.primary),
              ),
            ),
        ],
      ),
      body: _isLoading && _notifications.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadNotifications,
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _notifications.length + (_hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _notifications.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      return _buildNotificationItem(_notifications[index]);
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'Nema notifikacija',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ovdje ce se pojaviti vase notifikacije',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(AppNotification notification) {
    return Dismissible(
      key: Key('notification_${notification.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => _deleteNotification(notification),
      child: InkWell(
        onTap: () => _markAsRead(notification),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: notification.isRead ? Colors.white : AppColors.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: notification.isRead
                  ? Colors.grey.shade200
                  : AppColors.primary.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _getNotificationColor(notification).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getNotificationIcon(notification),
                  color: _getNotificationColor(notification),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title.isNotEmpty
                                ? notification.title
                                : 'Notifikacija',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: notification.isRead
                                  ? FontWeight.w500
                                  : FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message ?? '',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatTimeAgo(notification.createdAt),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getNotificationIcon(AppNotification notification) {
    final message = (notification.message ?? '').toLowerCase();
    if (message.contains('event') || message.contains('aktivnost')) {
      return Icons.event;
    } else if (message.contains('member') || message.contains('clan')) {
      return Icons.groups;
    } else if (message.contains('payment') || message.contains('placanje')) {
      return Icons.payment;
    }
    return Icons.notifications;
  }

  Color _getNotificationColor(AppNotification notification) {
    final message = (notification.message ?? '').toLowerCase();
    if (message.contains('event') || message.contains('aktivnost')) {
      return Colors.orange;
    } else if (message.contains('member') || message.contains('clan')) {
      return Colors.blue;
    } else if (message.contains('payment') || message.contains('placanje')) {
      return Colors.green;
    }
    return AppColors.primary;
  }
}
