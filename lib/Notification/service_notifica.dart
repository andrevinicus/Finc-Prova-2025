import 'dart:typed_data';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class LocalNotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();

  static FlutterLocalNotificationsPlugin get instance => _notifications;

  /// Inicializa o serviço de notificações locais
  static Future<void> init() async {
    // Solicita permissão de notificação (Android 13+ e iOS)
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

    final settings = InitializationSettings(android: androidSettings, iOS: iosSettings);

    // Inicializa o plugin
    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (details) {
        final documentId = details.payload;
        if (documentId != null) {
          print('🔔 Notificação clicada: $documentId');
          // Aqui você pode disparar evento para marcar como visualizada no NotificationBloc
        }
      },
    );

    // Cria canal Android com heads-up, som e vibração
    final androidChannel = AndroidNotificationChannel(
      'channel_id', // ID do canal deve bater com Manifest
      'Notificações', // Nome visível do canal
      description: 'Canal de notificações do app',
      importance: Importance.max, // heads-up
      playSound: true,
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 250, 250, 250]),
    );

    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  /// Exibe uma notificação local no dispositivo
  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload, // usado para identificar a notificação
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'channel_id', // mesmo ID do canal
      'Notificações',
      channelDescription: 'Canal de notificações do app',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 250, 250, 250]),
      icon: '@mipmap/ic_launcher', // ícone da notificação
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notificationDetails = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _notifications.show(id, title, body, notificationDetails, payload: payload);
  }
}
