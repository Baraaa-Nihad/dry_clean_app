// lib/services/providers/notification_provider.dart

import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:saleem_dry_clean/screens/NotificationPage/NotificationModel.dart';
import 'package:saleem_dry_clean/services/ApiClient/config.dart';
import 'package:saleem_dry_clean/services/User/UserService.dart';
import 'package:saleem_dry_clean/utils/app_version_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:saleem_dry_clean/utils/navigator_key.dart';
import 'package:saleem_dry_clean/utils/route_names.dart';
import 'package:saleem_dry_clean/services/User/TokenService.dart';
import 'package:saleem_dry_clean/services/ApiClient/ApiClient.dart';

class NotificationProvider with ChangeNotifier {
  // Per-user SharedPreferences key — notifications are isolated per user ID.
  static String _userKey(String userId) => 'notifications_$userId';

  List<NotificationModel> _notifications = [];
  List<NotificationModel> get notifications =>
      List.unmodifiable(_notifications);

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// The user ID whose notifications are currently loaded.
  /// Null means no user is signed in — notifications are hidden.
  String? _currentUserId;

  int get notificationCount =>
      _notifications.where((notification) => notification.isNew).length;

  // Firebase Messaging instance
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // Flutter Local Notifications Plugin instance
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final TokenService _tokenService;
  final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();

  NotificationProvider(this._tokenService) {
    _initializeFCM();
    _initializeLocalNotifications();
    // Restore notifications for a previously-saved login session (e.g. app
    // restart). We read UserService directly here to avoid a circular
    // Provider dependency — UserProvider is not available in the constructor.
    _restoreSessionIfLoggedIn();
  }

  // ---------------------------------------------------------------------------
  // Public lifecycle hooks — called by UserProvider on sign-in / sign-out
  // ---------------------------------------------------------------------------

  /// Load this user's notifications from persistent storage.
  /// Call this immediately after a successful sign-in.
  Future<void> loadForUser(String userId) async {
    _currentUserId = userId;
    await _loadFromPrefs(userId);
  }

  /// Clear in-memory notifications when the user signs out.
  /// Notifications are kept on disk so they are restored on the next login.
  void clearOnSignOut() {
    _currentUserId = null;
    _notifications = [];
    _isInitialized = false;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// Restores a persisted login session on app start (no BuildContext needed).
  Future<void> _restoreSessionIfLoggedIn() async {
    try {
      final userService = UserService();
      final isSignedIn = await userService.isUserSignedIn();
      if (isSignedIn) {
        final user = await userService.getUser();
        if (user != null) {
          await loadForUser(user.id);
          return; // loadForUser already sets _isInitialized = true
        }
      }
    } catch (_) {
      // Notifications are non-critical — silently ignore any startup errors.
    }
    // No signed-in user — mark as initialized with empty list so the
    // NotificationPage shows the empty state instead of an infinite spinner.
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _loadFromPrefs(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? notificationsJson = prefs.getString(_userKey(userId));
      _notifications = notificationsJson == null
          ? []
          : _loadNotificationsFromJson(notificationsJson);
    } catch (_) {
      _notifications = [];
    }
    _isInitialized = true;
    notifyListeners();
  }

  // Initialize Firebase Cloud Messaging
  Future<void> _initializeFCM() async {
    try {
      NotificationSettings settings =
          await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        // Handle foreground messages
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          if (message.notification != null) {
            _showLocalNotification(message);
          }
          _addFCMNotification(message);
        });

        // Handle messages opened from terminated state
        FirebaseMessaging.instance
            .getInitialMessage()
            .then((RemoteMessage? message) {
          if (message != null) {
            _handleMessage(message);
            _addFCMNotification(message);
          }
        });

        // Handle messages opened from background
        FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
          _handleMessage(message);
          _addFCMNotification(message);
        });

        // Get the device token and send it to the backend
        String? token = await _firebaseMessaging.getToken();
        if (token != null) {
          await _sendTokenToBackend(token);
        }

        // Listen for token refresh
        _firebaseMessaging.onTokenRefresh.listen((String newToken) {
          _sendTokenToBackend(newToken);
        });
      }
    } catch (_) {
      // Silently ignore FCM init errors
    }
  }

  // Android notification channel used for all local notifications
  static const String _channelId = 'orders_channel';
  static const String _channelName = 'Order Updates';
  static const String _channelDesc = 'Notifications about your order status';

  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        if (response.payload != null) {
          try {
            final Map<String, dynamic> data = jsonDecode(response.payload!);
            navigatorKey.currentState
                ?.pushNamed(RouteNames.notifications, arguments: data);
          } catch (e) {
            debugPrint('Error decoding notification payload: $e');
          }
        }
      },
    );

    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
        _localNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDesc,
        importance: Importance.high,
        playSound: true,
      ),
    );
  }

  // Display Local Notification — works on both Android and iOS
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final RemoteNotification? notification = message.notification;
    if (notification == null || kIsWeb) return;

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    await _localNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      platformDetails,
      payload: jsonEncode(message.data),
    );
  }

  // Handle message navigation
  void _handleMessage(RemoteMessage message) {
    navigatorKey.currentState
        ?.pushNamed(RouteNames.notifications, arguments: message.data);
  }

  /// Stores an incoming FCM notification for the current user.
  /// Silently discarded when no user is signed in.
  Future<void> _addFCMNotification(RemoteMessage message) async {
    if (_currentUserId == null) return; // No signed-in user — discard

    final notificationData = message.data;
    final notification = NotificationModel(
      orderNumber: notificationData['orderId'] ?? notificationData['orderNumber'] ?? 'N/A',
      status: notificationData['status'] ?? 'unknown',
      dateTime: DateTime.now(),
      isNew: true,
    );

    _notifications.insert(0, notification);
    notifyListeners();

    await _saveNotifications();
  }

  // Load notifications from JSON — returns empty list on any parse error
  List<NotificationModel> _loadNotificationsFromJson(String jsonString) {
    try {
      final List<dynamic> decodedList = json.decode(jsonString);
      return decodedList
          .map((item) => NotificationModel.fromMap(item))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Persists the current notification list under the signed-in user's key.
  /// No-op when no user is signed in.
  Future<void> _saveNotifications([SharedPreferences? prefs]) async {
    if (_currentUserId == null) return;
    final SharedPreferences preferences =
        prefs ?? await SharedPreferences.getInstance();
    final String encodedData = json.encode(
      _notifications.map((notification) => notification.toMap()).toList(),
    );
    await preferences.setString(_userKey(_currentUserId!), encodedData);
  }

  // Add a new notification (local)
  Future<void> addNotification(NotificationModel notification) async {
    _notifications.insert(0, notification);
    await _saveNotifications();
    notifyListeners();
  }

  // Remove a notification
  Future<void> removeNotification(int index) async {
    if (index >= 0 && index < _notifications.length) {
      _notifications.removeAt(index);
      await _saveNotifications();
      notifyListeners();
    }
  }

  // Reset all notifications
  Future<void> resetNotifications() async {
    _notifications.clear();
    await _saveNotifications();
    notifyListeners();
  }

  // Mark a notification as read
  Future<void> markAsRead(int index) async {
    if (index >= 0 && index < _notifications.length) {
      _notifications[index].isNew = false;
      await _saveNotifications();
      notifyListeners();
    }
  }

  // Toggle read status
  Future<void> toggleReadStatus(int index) async {
    if (index >= 0 && index < _notifications.length) {
      _notifications[index].isNew = !_notifications[index].isNew;
      await _saveNotifications();
      notifyListeners();
    }
  }

  // Send device token to backend
  Future<void> _sendTokenToBackend(String token) async {
    final String apiEndpoint = Config.deviceRegistration;

    try {
      String deviceType;
      String osVersion;
      String model;

      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfoPlugin.androidInfo;
        deviceType = 'Android';
        osVersion = androidInfo.version.release;
        model = androidInfo.model;
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfoPlugin.iosInfo;
        deviceType = 'iOS';
        osVersion = iosInfo.systemVersion;
        model = iosInfo.utsname.machine;
      } else {
        deviceType = 'Unknown';
        osVersion = 'Unknown';
        model = 'Unknown';
      }

      final String appVersion = await AppVersionHelper.getAppVersion();
      final String jwtToken = await _getJwtToken();

      final client = ApiClient.createClient(_tokenService);

      await client.post(
        Uri.parse(apiEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },
        body: jsonEncode({
          'deviceToken': token,
          'deviceType': deviceType,
          'osVersion': osVersion,
          'model': model,
          'appVersion': appVersion,
        }),
      );
    } catch (_) {
      // Silently ignore token registration errors
    }
  }

  // Retrieve JWT token from secure storage
  Future<String> _getJwtToken() async {
    final token = await _tokenService.getAccessToken();
    return token ?? '';
  }
}
