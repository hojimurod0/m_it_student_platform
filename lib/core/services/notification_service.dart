import 'dart:convert';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:m_it_student_platform/core/network/api_client.dart';
import 'package:m_it_student_platform/core/network/app_config.dart';
import 'package:m_it_student_platform/core/storage/local_storage_service.dart';

/// Top-level background handler for FCM messages
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (_) {}
  debugPrint('🔔 [FCM Background Message]: ${message.messageId} - ${message.notification?.title}');
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  static const String _channelId = 'mit_student_high_importance';
  static const String _channelName = 'M-IT Bildirishnomalar';
  static const String _channelDescription = 'Darslar, to\'lovlar va e\'lonlar haqida muhim bildirishnomalar';

  static const AndroidNotificationChannel _androidChannel = AndroidNotificationChannel(
    _channelId,
    _channelName,
    description: _channelDescription,
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
  );

  bool _isInitialized = false;
  bool _firebaseAvailable = false;
  String? _fcmToken;

  String? get fcmToken => _fcmToken;
  bool get isInitialized => _isInitialized;
  bool get isFirebaseAvailable => _firebaseAvailable;

  /// Initialize Firebase Core, FCM, and Local Notifications
  Future<void> initialize({
    void Function(String? payload)? onNotificationTap,
  }) async {
    if (_isInitialized) return;

    try {
      // 1. Setup Flutter Local Notifications first (always works independently)
      await _initLocalNotifications(onNotificationTap);

      // 2. Initialize Firebase Core safely if config exists
      try {
        if (Firebase.apps.isEmpty) {
          await Firebase.initializeApp();
        }
        _firebaseAvailable = Firebase.apps.isNotEmpty;
      } catch (e) {
        _firebaseAvailable = false;
        debugPrint('ℹ️ [NotificationService] Firebase mavjud emas (google-services.json qo\'shilganda FCM avtomatik ulanadi): $e');
      }

      // 3. If Firebase is available, setup FCM push notifications
      if (_firebaseAvailable) {
        await _requestPermissions();
        await _setupFCMListeners();
      }

      _isInitialized = true;
      debugPrint('✅ [NotificationService] Bildirishnomalar xizmati muvaffaqiyatli ishga tushdi.');
    } catch (e, stack) {
      debugPrint('❌ [NotificationService] Initialization error: $e\n$stack');
    }
  }

  /// Request permissions for Push Notifications
  Future<void> _requestPermissions() async {
    if (!_firebaseAvailable) return;
    try {
      final fcm = FirebaseMessaging.instance;
      final settings = await fcm.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      debugPrint('🔔 [NotificationService] AuthorizationStatus: ${settings.authorizationStatus}');

      // Set foreground notification presentation options for Apple / Android
      await fcm.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    } catch (e) {
      debugPrint('⚠️ [NotificationService] Permission request failed: $e');
    }
  }

  /// Initialize Local Notification channel and click handlers
  Future<void> _initLocalNotifications(
    void Function(String? payload)? onNotificationTap,
  ) async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        if (response.payload != null && onNotificationTap != null) {
          onNotificationTap(response.payload);
        }
      },
    );

    // Create high importance Android notification channel
    if (!kIsWeb && Platform.isAndroid) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_androidChannel);
    }
  }

  /// Setup Foreground and Tap listeners
  Future<void> _setupFCMListeners() async {
    if (!_firebaseAvailable) return;
    try {
      final fcm = FirebaseMessaging.instance;

      // 1. Get FCM Token
      _fcmToken = await fcm.getToken();
      debugPrint('🔑 [NotificationService] FCM Token: $_fcmToken');
      if (_fcmToken != null) {
        await syncFcmTokenToServer(_fcmToken!);
      }

      // Listen for token refreshes
      fcm.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        debugPrint('🔄 [NotificationService] Refreshed FCM Token: $_fcmToken');
        syncFcmTokenToServer(newToken);
      });

      // 2. Set Background Handler
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // 3. Listen to Foreground Messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('📩 [NotificationService Foreground]: ${message.notification?.title} - ${message.notification?.body}');
        _showForegroundNotification(message);
      });

      // 4. Handle Notification click when app was opened from background
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('🚀 [NotificationService Clicked from BG]: ${message.data}');
      });

      // 5. Check if app was opened from a terminated state notification
      final initialMessage = await fcm.getInitialMessage();
      if (initialMessage != null) {
        debugPrint('📦 [NotificationService Initial Message]: ${initialMessage.data}');
      }

      // 6. Subscribe to default student topics
      await subscribeToTopic('all_students');
      await subscribeToTopic('announcements');
    } catch (e) {
      debugPrint('⚠️ [NotificationService] FCM setup error: $e');
    }
  }

  /// Display a heads-up local notification when an FCM arrives while app is in foreground
  Future<void> _showForegroundNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      playSound: true,
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      message.hashCode,
      notification.title ?? 'M-IT Akademiya',
      notification.body ?? '',
      notificationDetails,
      payload: jsonEncode(message.data),
    );
  }

  /// Manually trigger a custom local notification
  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
    int? id,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      id ?? DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  /// Subscribe to a specific FCM topic (e.g., 'group_flutter_01', 'announcements')
  Future<void> subscribeToTopic(String topic) async {
    if (!_firebaseAvailable) return;
    try {
      await FirebaseMessaging.instance.subscribeToTopic(topic);
      debugPrint('📌 [NotificationService] Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('⚠️ [NotificationService] Failed to subscribe to $topic: $e');
    }
  }

  /// Unsubscribe from a specific FCM topic
  Future<void> unsubscribeFromTopic(String topic) async {
    if (!_firebaseAvailable) return;
    try {
      await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
      debugPrint('🔌 [NotificationService] Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('⚠️ [NotificationService] Failed to unsubscribe from $topic: $e');
    }
  }

  /// Send FCM Push Notification token to backend
  Future<void> syncFcmTokenToServer([String? token]) async {
    final effectiveToken = token ?? _fcmToken;
    if (effectiveToken == null || effectiveToken.isEmpty) return;

    final authToken = LocalStorageService.getAuthToken();
    if (authToken == null || authToken.isEmpty) return;

    try {
      final apiClient = ApiClient();
      await apiClient.post(
        AppConfig.authFcmToken,
        body: {
          'token': effectiveToken,
          'fcm_token': effectiveToken,
          'registration_id': effectiveToken,
        },
      );
      debugPrint('✅ [NotificationService] FCM token backendga muvaffaqiyatli uzatildi');
    } catch (e) {
      debugPrint('⚠️ [NotificationService] FCM tokenni backendga yuborishda xatolik: $e');
    }
  }
}
