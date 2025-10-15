import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init(BuildContext context) async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final payload = response.payload;
        if (payload != null && payload.startsWith('chat_')) {
          Navigator.of(context).pushNamed('/chat', arguments: payload);
        }
      },
    );
  }

  Future<void> showNotification({
    required String title,
    required String body,
    required String payload, // e.g. "chat_12345"
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'chat_channel_id',
      'Chat Notifications',
      channelDescription: 'Notifications for new chat messages',
      importance: Importance.max,
      priority: Priority.high,
      playSound: false,
    );

    const NotificationDetails details = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      DateTime.now().millisecond,
      title,
      body,
      details,
      payload: payload,
    );
  }
}
