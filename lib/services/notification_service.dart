import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:workmanager/workmanager.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Background task callback - must be top-level function
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == 'checkExpiringItems') {
      await NotificationService.checkAndNotifyExpiringItems();
    }
    return Future.value(true);
  });
}

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'expiry_alerts';
  static const String _channelName = 'Thông báo hết hạn';
  static const String _channelDescription =
      'Nhắc nhở về nguyên liệu sắp hết hạn';
  static const String _taskName = 'checkExpiringItems';

  /// Initialize notification service
  static Future<void> initialize() async {
    // Initialize timezone
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    // Android initialization settings
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // iOS initialization settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channel for Android
    if (Platform.isAndroid) {
      await _createNotificationChannel();
    }

    // Request permissions on iOS
    if (Platform.isIOS) {
      await _requestIOSPermissions();
    }
  }

  /// Create Android notification channel
  static Future<void> _createNotificationChannel() async {
    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
      playSound: true,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  /// Request iOS permissions
  static Future<void> _requestIOSPermissions() async {
    await _notifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  /// Request Android 13+ notification permission
  static Future<bool> requestAndroidPermission() async {
    if (Platform.isAndroid) {
      final android = _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      final granted = await android?.requestNotificationsPermission();
      return granted ?? false;
    }
    return true;
  }

  /// Handle notification tap
  static void _onNotificationTapped(NotificationResponse response) {
    // Navigation is handled by the app when it receives the payload
    debugPrint('Notification tapped: ${response.payload}');
  }

  /// Initialize Workmanager for background tasks
  static Future<void> initializeWorkmanager() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: kDebugMode,
    );
  }

  /// Schedule daily check at 8:00 AM
  static Future<void> scheduleDailyCheck() async {
    // Cancel existing tasks first
    await Workmanager().cancelByUniqueName(_taskName);

    // Schedule periodic task (minimum 15 minutes on Android)
    await Workmanager().registerPeriodicTask(
      _taskName,
      _taskName,
      frequency: const Duration(hours: 24),
      initialDelay: _calculateInitialDelay(),
      constraints: Constraints(networkType: NetworkType.connected),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
    );

    debugPrint('Daily notification check scheduled');
  }

  /// Calculate delay until next 8:00 AM
  static Duration _calculateInitialDelay() {
    final now = DateTime.now();
    var scheduledTime = DateTime(now.year, now.month, now.day, 8, 0);

    // If it's already past 8 AM, schedule for tomorrow
    if (now.isAfter(scheduledTime)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    return scheduledTime.difference(now);
  }

  /// Show notification for expiring items
  static Future<void> showExpiryNotification({
    required int itemCount,
    required String itemNames,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFF4CAF50),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    String title;
    String body;

    if (itemCount == 1) {
      title = '⚠️ Nguyên liệu sắp hết hạn';
      body = '$itemNames sẽ hết hạn trong 3 ngày tới!';
    } else {
      title = '⚠️ $itemCount nguyên liệu sắp hết hạn';
      body = '$itemNames sẽ hết hạn trong 3 ngày tới!';
    }

    await _notifications.show(0, title, body, details, payload: 'expiry_alert');
  }

  /// Check and notify about expiring items (called from background)
  static Future<void> checkAndNotifyExpiringItems() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user == null) {
        debugPrint('No user logged in, skipping notification check');
        return;
      }

      // Get items expiring in 3 days
      final today = DateTime.now();
      final futureDate = today.add(const Duration(days: 3));
      final todayStr = today.toIso8601String().split('T')[0];
      final futureDateStr = futureDate.toIso8601String().split('T')[0];

      final response = await supabase
          .from('pantry_items')
          .select('*, ingredients(*)')
          .eq('profile_id', user.id)
          .isFilter('deleted_at', null)
          .gte('expiry_date', todayStr)
          .lte('expiry_date', futureDateStr);

      final items = response as List;

      if (items.isNotEmpty) {
        // Get ingredient names
        final names = items
            .take(3)
            .map((item) => item['ingredients']?['name'] ?? 'Unknown')
            .join(', ');

        final displayNames = items.length > 3 ? '$names...' : names;

        await showExpiryNotification(
          itemCount: items.length,
          itemNames: displayNames,
        );

        debugPrint('Sent notification for ${items.length} expiring items');
      }
    } catch (e) {
      debugPrint('Error checking expiring items: $e');
    }
  }

  /// Test notification (for development)
  static Future<void> showTestNotification() async {
    await showExpiryNotification(itemCount: 2, itemNames: 'Sữa, Thịt bò');
  }
}
