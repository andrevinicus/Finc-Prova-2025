import 'package:finc/Notification/bloc_notifica_token/user_token_bloc.dart';
import 'package:finc/Notification/service_notifica.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FCMService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // Callbacks externos opcionais
  static Function(RemoteMessage)? onForegroundMessageCallback;
  static Function(RemoteMessage)? onOpenedAppCallback;

  /// Inicializa o FCM, grava token e escuta notificações
  static Future<void> init({
    required String userId,
    required BuildContext context,
  }) async {
    // ✅ Garante que o Firebase já foi inicializado (evita crash)
    try {
      await Firebase.initializeApp();
    } catch (e) {
      debugPrint('⚠️ Firebase já estava inicializado.');
    }

    // Solicita permissões (necessário no iOS e Android 13+)
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Inicializa notificações locais (apenas uma vez)
    await LocalNotificationService.init();

    // 🔹 Obtém token FCM e salva via UserTokenBloc
    final token = await _getToken();
    if (token != null && context.mounted) {
      context.read<UserTokenBloc>().add(
        SaveUserToken(userId: userId, token: token),
      );
    }

    // 🔹 Atualiza token automaticamente quando o Firebase emitir novo
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      debugPrint('🔄 Token FCM atualizado: $newToken');
      if (context.mounted) {
        context.read<UserTokenBloc>().add(
          SaveUserToken(userId: userId, token: newToken),
        );
      }
    });

    // 🔹 Listener para mensagens em foreground
    FirebaseMessaging.onMessage.listen(_onMessage);

    // 🔹 Listener para quando app é aberto via notificação
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);

    // 🔹 Handler global para background
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  /// Obtém token FCM do dispositivo ou gera novo se não existir
  static Future<String?> _getToken() async {
    String? token = await _firebaseMessaging.getToken();

    if (token == null) {
      debugPrint('⚠️ Token FCM não disponível. Gerando novo token...');
      await _firebaseMessaging.deleteToken();
      token = await _firebaseMessaging.getToken();
    }

    debugPrint('🔑 Token FCM do dispositivo: $token');
    return token;
  }

  /// Handler para mensagens recebidas em foreground
  static Future<void> _onMessage(RemoteMessage message) async {
    debugPrint('📩 Mensagem FCM recebida em foreground: ${message.notification?.title}');

    if (message.notification != null) {
      await LocalNotificationService.showNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: message.notification?.title ?? 'Nova notificação',
        body: message.notification?.body ?? '',
        payload: message.data['id'] ?? '',
      );
    }

    // Dispara callback externo, se existir
    onForegroundMessageCallback?.call(message);
  }

  /// Handler quando o app é aberto via notificação
  static void _onMessageOpenedApp(RemoteMessage message) {
    debugPrint('🟢 Notificação aberta: ${message.data}');
    onOpenedAppCallback?.call(message);
  }

  /// Handler de mensagens em background
  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    try {
      await Firebase.initializeApp();
    } catch (_) {}
    await LocalNotificationService.init();

    debugPrint('📨 Mensagem FCM recebida em background: ${message.notification?.title}');

    if (message.notification != null) {
      await LocalNotificationService.showNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: message.notification?.title ?? 'Nova notificação',
        body: message.notification?.body ?? '',
        payload: message.data['id'] ?? '',
      );
    }
  }

  /// Permite registrar callback externo para mensagens em foreground
  static void onForegroundMessage(Function(RemoteMessage) callback) {
    onForegroundMessageCallback = callback;
  }

  /// Permite registrar callback externo para app aberto via notificação
  static void onMessageOpenedApp(Function(RemoteMessage) callback) {
    onOpenedAppCallback = callback;
  }
}
