import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:signalr_netcore/signalr_client.dart';
import '../config/api_config.dart';

/// Notification data model for SignalR messages
class SignalRNotification {
  final String type;
  final String title;
  final String message;
  final int? eventId;
  final int? organizationId;
  final DateTime timestamp;

  SignalRNotification({
    required this.type,
    required this.title,
    required this.message,
    this.eventId,
    this.organizationId,
    required this.timestamp,
  });

  factory SignalRNotification.fromJson(Map<String, dynamic> json) {
    return SignalRNotification(
      type: json['Type'] as String? ?? json['type'] as String? ?? '',
      title: json['Title'] as String? ?? json['title'] as String? ?? '',
      message: json['Message'] as String? ?? json['message'] as String? ?? '',
      eventId: json['EventId'] as int? ?? json['eventId'] as int?,
      organizationId: json['OrganizationId'] as int? ?? json['organizationId'] as int?,
      timestamp: DateTime.tryParse(json['Timestamp']?.toString() ?? json['timestamp']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}

/// SignalR Service for real-time notifications
///
/// This service manages WebSocket connection to the backend SignalR hub
/// and handles real-time notification delivery.
class SignalRService {
  static final SignalRService _instance = SignalRService._internal();
  factory SignalRService() => _instance;
  SignalRService._internal();

  HubConnection? _hubConnection;
  bool _isConnected = false;
  int? _currentUserId;
  final Set<int> _subscribedOrganizations = {};

  // Stream controller for notifications
  final StreamController<SignalRNotification> _notificationController =
      StreamController<SignalRNotification>.broadcast();

  // Track recently received notifications to prevent duplicates
  final Map<String, DateTime> _recentNotifications = {};
  static const _duplicateWindowSeconds = 5;

  /// Stream of incoming notifications
  Stream<SignalRNotification> get notificationStream => _notificationController.stream;

  /// Whether the service is currently connected
  bool get isConnected => _isConnected;

  /// Initialize and connect to SignalR hub
  Future<void> connect(int userId) async {
    if (_isConnected && _currentUserId == userId) {
      debugPrint('[SignalR] Already connected for user $userId');
      return;
    }

    _currentUserId = userId;

    try {
      // Create hub connection
      _hubConnection = HubConnectionBuilder()
          .withUrl(ApiConfig.signalRHubUrl)
          .withAutomaticReconnect()
          .build();

      // Set up event handlers
      _setupEventHandlers();

      // Start connection
      await _hubConnection!.start();
      _isConnected = true;
      debugPrint('[SignalR] Connected to ${ApiConfig.signalRHubUrl}');

      // Register user for targeted notifications
      await _registerUser(userId);

    } catch (e) {
      debugPrint('[SignalR] Connection error: $e');
      _isConnected = false;
    }
  }

  /// Setup SignalR event handlers
  void _setupEventHandlers() {
    if (_hubConnection == null) return;

    // Handle incoming notifications
    _hubConnection!.on('ReceiveNotification', (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        try {
          final data = arguments[0] as Map<String, dynamic>;
          final notification = SignalRNotification.fromJson(data);

          // Create unique key for deduplication (type + eventId/orgId + message)
          final notificationKey = '${notification.type}_${notification.eventId ?? notification.organizationId}_${notification.message}';

          // Check if we received this notification recently (within duplicate window)
          final now = DateTime.now();
          if (_recentNotifications.containsKey(notificationKey)) {
            final lastReceived = _recentNotifications[notificationKey]!;
            if (now.difference(lastReceived).inSeconds < _duplicateWindowSeconds) {
              debugPrint('[SignalR] Duplicate notification filtered: ${notification.title}');
              return; // Skip duplicate
            }
          }

          // Mark this notification as received
          _recentNotifications[notificationKey] = now;

          // Clean up old entries (older than duplicate window)
          _recentNotifications.removeWhere((key, timestamp) =>
            now.difference(timestamp).inSeconds > _duplicateWindowSeconds
          );

          debugPrint('[SignalR] Received: ${notification.title} - ${notification.message}');
          _notificationController.add(notification);
        } catch (e) {
          debugPrint('[SignalR] Error parsing notification: $e');
        }
      }
    });

    // Handle reconnection
    _hubConnection!.onreconnecting(({error}) {
      debugPrint('[SignalR] Reconnecting... Error: $error');
      _isConnected = false;
    });

    _hubConnection!.onreconnected(({connectionId}) {
      debugPrint('[SignalR] Reconnected with ID: $connectionId');
      _isConnected = true;

      // Re-register user after reconnection
      if (_currentUserId != null) {
        _registerUser(_currentUserId!);
      }

      // Re-subscribe to organizations
      for (var orgId in _subscribedOrganizations) {
        subscribeToOrganization(orgId);
      }
    });

    _hubConnection!.onclose(({error}) {
      debugPrint('[SignalR] Connection closed. Error: $error');
      _isConnected = false;
    });
  }

  /// Register user for targeted notifications
  Future<void> _registerUser(int userId) async {
    if (_hubConnection == null || !_isConnected) return;

    try {
      await _hubConnection!.invoke('RegisterUser', args: [userId]);
      debugPrint('[SignalR] Registered user $userId');
    } catch (e) {
      debugPrint('[SignalR] Error registering user: $e');
    }
  }

  /// Subscribe to organization notifications (for followers)
  Future<void> subscribeToOrganization(int organizationId) async {
    if (_hubConnection == null || !_isConnected) {
      // Queue for later if not connected
      _subscribedOrganizations.add(organizationId);
      return;
    }

    try {
      await _hubConnection!.invoke('SubscribeToOrganization', args: [organizationId]);
      _subscribedOrganizations.add(organizationId);
      debugPrint('[SignalR] Subscribed to organization $organizationId');
    } catch (e) {
      debugPrint('[SignalR] Error subscribing to organization: $e');
    }
  }

  /// Unsubscribe from organization notifications
  Future<void> unsubscribeFromOrganization(int organizationId) async {
    if (_hubConnection == null || !_isConnected) return;

    try {
      await _hubConnection!.invoke('UnsubscribeFromOrganization', args: [organizationId]);
      _subscribedOrganizations.remove(organizationId);
      debugPrint('[SignalR] Unsubscribed from organization $organizationId');
    } catch (e) {
      debugPrint('[SignalR] Error unsubscribing from organization: $e');
    }
  }

  /// Subscribe to multiple organizations at once
  Future<void> subscribeToOrganizations(List<int> organizationIds) async {
    for (var orgId in organizationIds) {
      await subscribeToOrganization(orgId);
    }
  }

  /// Disconnect from SignalR hub
  Future<void> disconnect() async {
    if (_hubConnection != null) {
      try {
        await _hubConnection!.stop();
        debugPrint('[SignalR] Disconnected');
      } catch (e) {
        debugPrint('[SignalR] Error disconnecting: $e');
      }
    }

    _isConnected = false;
    _currentUserId = null;
    _subscribedOrganizations.clear();
  }

  /// Dispose resources
  void dispose() {
    disconnect();
    _notificationController.close();
  }
}
