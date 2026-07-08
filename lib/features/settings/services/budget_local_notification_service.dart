import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class BudgetLocalNotificationService {
  BudgetLocalNotificationService({
    FlutterLocalNotificationsPlugin? notifications,
  }) : _notifications = notifications ?? FlutterLocalNotificationsPlugin();

  static const _channelId = 'budget_alerts';
  static const _channelName = 'Budget alerts';
  static const _channelDescription = 'Alerts when budgets reach their limits.';

  final FlutterLocalNotificationsPlugin _notifications;
  var _initialized = false;
  var _permissionsRequested = false;

  Future<void> showBudgetThresholdAlert({
    required String id,
    required String title,
    required String body,
  }) async {
    if (kIsWeb) {
      return;
    }

    await _ensureInitialized();
    await _requestPermissions();

    await _notifications.show(
      id: _notificationId(id),
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
        macOS: DarwinNotificationDetails(),
      ),
      payload: id,
    );
  }

  Future<void> _ensureInitialized() async {
    if (_initialized) {
      return;
    }

    await _notifications.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestSoundPermission: false,
          requestBadgePermission: false,
        ),
        macOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestSoundPermission: false,
          requestBadgePermission: false,
        ),
      ),
    );
    _initialized = true;
  }

  Future<void> _requestPermissions() async {
    if (_permissionsRequested) {
      return;
    }

    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
    await _notifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, sound: true);
    await _notifications
        .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, sound: true);

    _permissionsRequested = true;
  }

  int _notificationId(String id) {
    var hash = 0;
    for (final codeUnit in id.codeUnits) {
      hash = (hash * 31 + codeUnit) & 0x7fffffff;
    }
    return hash;
  }
}
