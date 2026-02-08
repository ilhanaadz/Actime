import 'dart:async';

/// Controller for refreshing notification badges across the app
class NotificationBadgeController {
  static final NotificationBadgeController _instance = NotificationBadgeController._internal();
  factory NotificationBadgeController() => _instance;
  NotificationBadgeController._internal();

  final StreamController<void> _refreshController = StreamController<void>.broadcast();

  Stream<void> get refreshStream => _refreshController.stream;

  void refresh() {
    if (!_refreshController.isClosed) {
      _refreshController.add(null);
    }
  }

  void dispose() {
    _refreshController.close();
  }
}
