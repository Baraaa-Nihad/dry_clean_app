// lib/services/providers/notification_provider.dart

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:saleem_dry_clean/screens/NotificationPage/NotificationModel.dart';
import 'package:saleem_dry_clean/services/ApiClient/config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:saleem_dry_clean/utils/navigator_key.dart';
import 'package:saleem_dry_clean/utils/route_names.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:saleem_dry_clean/services/User/TokenService.dart';
import 'package:saleem_dry_clean/services/ApiClient/ApiClient.dart';

class NotificationProvider with ChangeNotifier {
  static const String _notificationsKey = 'notifications';
  static const String _notificationCountKey = 'notificationCount';

  List<NotificationModel> _notifications = [];
  List<NotificationModel> get notifications =>
      List.unmodifiable(_notifications);

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  int get notificationCount =>
      _notifications.where((notification) => notification.isNew).length;

  // Firebase Messaging instance
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // Flutter Local Notifications Plugin instance
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // TokenService instance (ensure it's provided correctly)
  final TokenService _tokenService;

  NotificationProvider(this._tokenService) {
    _initializePreferences();
    _initializeFCM();
    _initializeLocalNotifications();
  }

  // Initialize SharedPreferences and load existing notifications
  Future<void> _initializePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? notificationsJson = prefs.getString(_notificationsKey);

      if (notificationsJson == null) {
        // Initialize with demo data if no notifications are stored
        _notifications = _getDemoNotifications();

        await _saveNotifications(prefs);
      } else {
        _notifications = _loadNotificationsFromJson(notificationsJson);
      }
    } catch (e) {
      // Handle error gracefully, possibly logging it
      _notifications = _getDemoNotifications();
      await _saveNotifications();
    }

    _isInitialized = true;
    notifyListeners();
  }

  // Initialize Firebase Cloud Messaging
  Future<void> _initializeFCM() async {
    try {
      // Request notification permissions (iOS)
      NotificationSettings settings =
          await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('User granted permission');

        // Handle foreground messages
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          print('Received a message in the foreground!');
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
      } else {
        print('User declined or has not accepted permission');
      }
    } catch (e) {
      print('Error initializing FCM: $e');
    }
  }

  // Android notification channel used for all local notifications
  static const String _channelId = 'orders_channel';
  static const String _channelName = 'Order Updates';
  static const String _channelDesc = 'Notifications about your order status';

  Future<void> _initializeLocalNotifications() async {
    // 1. Android initialization — use the same channel ID everywhere
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // 2. iOS (Darwin) initialization
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    // 3. Combine
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    // 4. Initialize with tap handler
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

    // 5. Create the Android notification channel (required on Android 8+)
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
    print('Message clicked!: ${message.messageId}');
    // Navigate to a specific screen based on message data
    navigatorKey.currentState
        ?.pushNamed(RouteNames.notifications, arguments: message.data);
  }

  // Add FCM notification to the list
  Future<void> _addFCMNotification(RemoteMessage message) async {
    final notificationData = message.data;

    // Map FCM message data to NotificationModel
    final notification = NotificationModel(
      orderNumber: notificationData['orderNumber'] ?? 'N/A',
      status: notificationData['status'] ?? 'unknown',
      dateTime: DateTime.now(), // Use current time or parse from data
      isNew: true,
    );

    _notifications.insert(0, notification); // Insert at the beginning
    notifyListeners();

    // Save updated notifications to SharedPreferences
    await _saveNotifications();
  }

  // Load notifications from JSON
  List<NotificationModel> _loadNotificationsFromJson(String jsonString) {
    try {
      final List<dynamic> decodedList = json.decode(jsonString);
      return decodedList
          .map((item) => NotificationModel.fromMap(item))
          .toList();
    } catch (e) {
      // Handle parsing error, return empty list or demo data
      return _getDemoNotifications();
    }
  }

  // Save notifications to SharedPreferences
  Future<void> _saveNotifications([SharedPreferences? prefs]) async {
    final SharedPreferences preferences =
        prefs ?? await SharedPreferences.getInstance();
    final String encodedData = json.encode(
      _notifications.map((notification) => notification.toMap()).toList(),
    );
    await preferences.setString(_notificationsKey, encodedData);
  }

  // Add a new notification (local)
  Future<void> addNotification(NotificationModel notification) async {
    _notifications.insert(0, notification); // Insert at the beginning
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

  // Initialize with demo notifications
  List<NotificationModel> _getDemoNotifications() {
    return [
      NotificationModel(
          orderNumber: '12345',
          status: 'shipped',
          dateTime: DateTime.parse('2024-04-25T10:30:00'),
          isNew: true),
      NotificationModel(
        orderNumber: '12346',
        status: 'delivered',
        dateTime: DateTime.parse('2024-04-26T14:15:00'),
      ),
      NotificationModel(
        orderNumber: '12347',
        status: 'processing',
        dateTime: DateTime.parse('2024-04-27T09:00:00'),
      ),
      NotificationModel(
        orderNumber: '12348',
        status: 'shipped',
        dateTime: DateTime.parse('2024-04-25T10:30:00'),
      ),
      NotificationModel(
        orderNumber: '12349',
        status: 'delivered',
        dateTime: DateTime.parse('2024-04-26T14:15:00'),
      ),
      NotificationModel(
        orderNumber: '12350',
        status: 'processing',
        dateTime: DateTime.parse('2024-04-27T09:00:00'),
      ),
      NotificationModel(
        orderNumber: '12351',
        status: 'processing',
        dateTime: DateTime.parse('2024-05-27T09:00:00'),
        isNew: true,
      ),
    ];
  }

  // Send device token to backend
  Future<void> _sendTokenToBackend(String token) async {
    final String apiEndpoint = '${Config.deviceRegistration}';

    try {
      // Retrieve JWT token from your UserProvider or secure storage
      String jwtToken = await _getJwtToken();

      final client = ApiClient.createClient(_tokenService);

      final response = await client.post(
        Uri.parse(apiEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },
        body: jsonEncode({
          'deviceToken': token,
        }),
      );

      if (response.statusCode == 200) {
        print('Device token sent successfully to backend.');
      } else {
        print('Failed to send device token: ${response.body}');
      }
    } catch (e) {
      print('Error sending device token to backend: $e');
    }
  }

  // Retrieve JWT token from secure storage
  Future<String> _getJwtToken() async {
    final token = await _tokenService.getAccessToken();
    return token ?? '';
  }
}
