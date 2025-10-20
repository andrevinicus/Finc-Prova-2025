import 'package:finc/Notification/service_notifica.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';

class FCMService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // Callbacks externos opcionais
  static Function(RemoteMessage)? onForegroundMessageCallback;
  static Function(RemoteMessage)? onOpenedAppCallback;

  /// Inicializa o FCM e notificações locais
  static Future<void> init() async {
    // Inicializa Firebase
    await Firebase.initializeApp();

    // Solicita permissões (iOS e Android 13+)
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Inicializa notificações locais
    await LocalNotificationService.init();

    // Obtém token FCM ou gera novo
    await _getToken();

    // Atualiza token quando renovado
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      print('🔑 Token FCM atualizado: $newToken');
      // Enviar token para backend, se necessário
    });

    // Listener para mensagens em foreground
    FirebaseMessaging.onMessage.listen(_onMessage);

    // Listener para quando app é aberto a partir de notificação
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);

    // Listener para mensagens em background
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  /// Permite registrar callback externo para mensagens em foreground
  static void onForegroundMessage(Function(RemoteMessage) callback) {
    onForegroundMessageCallback = callback;
  }

  /// Permite registrar callback externo para app aberto via notificação
  static void onMessageOpenedApp(Function(RemoteMessage) callback) {
    onOpenedAppCallback = callback;
  }

  /// Obtém token FCM do dispositivo ou gera um novo se não existir
  static Future<String?> _getToken() async {
    String? token = await _firebaseMessaging.getToken();

    if (token == null) {
      print('⚠️ Token FCM não disponível. Gerando novo token...');
      // Força a geração de um novo token
      await _firebaseMessaging.deleteToken();
      token = await _firebaseMessaging.getToken();
    }

    print('🔑 Token FCM do dispositivo: $token');
    // Aqui você pode enviar token para o backend, se necessário
    return token;
  }

  /// Handler para mensagens recebidas em foreground
  static Future<void> _onMessage(RemoteMessage message) async {
    print('📩 Mensagem FCM recebida em foreground: ${message.notification?.title}');

    if (message.notification != null) {
      await LocalNotificationService.showNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: message.notification?.title ?? 'Nova notificação',
        body: message.notification?.body ?? '',
        payload: message.data['id'] ?? '',
      );
    }

    // Dispara callback externo, se existir
    if (onForegroundMessageCallback != null) {
      onForegroundMessageCallback!(message);
    }
  }

  /// Handler quando o app é aberto via notificação
  static void _onMessageOpenedApp(RemoteMessage message) {
    print('🟢 Notificação aberta: ${message.data}');

    // Dispara callback externo, se existir
    if (onOpenedAppCallback != null) {
      onOpenedAppCallback!(message);
    }
  }

  /// Handler de mensagens em background
  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp();
    await LocalNotificationService.init();

    print('📨 Mensagem FCM recebida em background: ${message.notification?.title}');

    if (message.notification != null) {
      await LocalNotificationService.showNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: message.notification?.title ?? 'Nova notificação',
        body: message.notification?.body ?? '',
        payload: message.data['id'] ?? '',
      );
    }
  }
}
