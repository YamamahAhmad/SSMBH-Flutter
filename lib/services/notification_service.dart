// lib/services/notification_service.dart

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// 1. استيراد الحزمة لقراءة الإعدادات المحفوظة
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description: 'This channel is used for important notifications.', // description
    importance: Importance.max,
    playSound: true,
  );

  // 2. دالة جديدة وثابتة للتحقق من حالة الإشعارات
  static Future<bool> _areNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    // إذا لم تكن هناك قيمة محفوظة، نفترض أنها مفعّلة (true)
    return prefs.getBool('notifications_enabled') ?? true;
  }

  static Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
    InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _notificationsPlugin.initialize(initializationSettings);

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  static Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    // 3. -- التعديل الأهم --
    // قبل إظهار الإشعار، تحقق أولاً إذا كانت الإشعارات مفعّلة
    if (!await _areNotificationsEnabled()) {
      // إذا كانت الإشعارات معطلة، اطبع رسالة في الـ console واخرج من الدالة
      print('Notifications are disabled by the user. Skipping notification.');
      return; // هذا السطر يمنع تنفيذ باقي الكود وعرض الإشعار
    }

    // إذا كانت الإشعارات مفعّلة، سيتم تنفيذ الكود التالي كالمعتاد
    print('Notifications are enabled. Showing notification...');
    await _notificationsPlugin.show(
      id,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          icon: '@mipmap/ic_launcher',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
        ),
      ),
    );
  }
}
