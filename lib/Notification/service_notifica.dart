import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class LocalNotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    // 📌 Solicita permissão de notificação no Android 13+ e no iOS
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }

    // Configuração Android
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // Configuração iOS
    const iosSettings = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const settings = InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (details) {
        // Aqui você pode tratar cliques na notificação
        print('Notificação clicada: ${details.payload}');
      },
    );

    // Cria canal no Android (Android 8+)
    const androidChannel = AndroidNotificationChannel(
      'channel_id',
      'Notificações',
      description: 'Canal de notificações do app',
      importance: Importance.max,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'channel_id',
      'Notificações',
      channelDescription: 'Canal de notificações do app',
      importance: Importance.max,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _notifications.show(id, title, body, notificationDetails);
  }
}
