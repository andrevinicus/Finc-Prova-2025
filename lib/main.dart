import 'package:finc/Notification/fcm_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:finc/Notification/service_notifica.dart';
import 'package:finc/Notification/bloc_notifica/notification_bloc.dart';
import 'package:finc/Notification/bloc_notifica/notification_event.dart';
import 'package:finc/simple_bloc_observer.dart';
import 'package:finc/app.dart';
import 'package:expense_repository/expense_repository.dart';


// =========================
// BACKGROUND HANDLER FCM
// =========================
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  await LocalNotificationService.showNotification(
    id: message.data['documentId']?.hashCode ?? 0,
    title: message.notification?.title ?? 'Nova notificação',
    body: message.notification?.body ?? '',
    payload: message.data['documentId'] ?? '',
  );

  print('📨 Mensagem FCM em background: ${message.notification?.title}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp();

  // Inicializa notificações locais (cria canal)
  await LocalNotificationService.init();

  // Inicializa FCM e registra handler de background
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Inicializa o FCMService (gera token e listeners)
  await FCMService.init();

  // Inicializa bloc e repositório
  final notificationRepository = NotificationRepository();
  Bloc.observer = SimpleBlocObserver();

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<NotificationRepository>.value(
          value: notificationRepository,
        ),
      ],
      child: BlocProvider(
        create: (context) => NotificationBloc(
          repository: notificationRepository,
          localNotifications: LocalNotificationService.instance,
          idApp: 'global_app', // ou userId do usuário
        ),
        child: const MyAppWrapper(),
      ),
    ),
  );
}

// =========================
// WIDGET WRAPPER PRINCIPAL
// =========================
class MyAppWrapper extends StatefulWidget {
  const MyAppWrapper({super.key});

  @override
  State<MyAppWrapper> createState() => _MyAppWrapperState();
}

class _MyAppWrapperState extends State<MyAppWrapper> {
  late final NotificationBloc _notificationBloc;

  @override
  void initState() {
    super.initState();
    _notificationBloc = BlocProvider.of<NotificationBloc>(context);

    // Listener FCM em foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      final documentId = message.data['documentId'] ?? '';

      await LocalNotificationService.showNotification(
        id: documentId.hashCode,
        title: message.notification?.title ?? 'Nova notificação',
        body: message.notification?.body ?? '',
        payload: documentId,
      );

      _notificationBloc.add(TriggerLocalNotification(
        id: documentId.hashCode,
        title: message.notification?.title ?? 'Nova notificação',
        body: message.notification?.body ?? '',
      ));

      print('📩 Notificação FCM em foreground: ${message.notification?.title}');
    });

    // Listener quando app é aberto via notificação
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final documentId = message.data['documentId'] ?? '';
      print('[FCM OpenedApp] Notificação clicada: $documentId');
      // Aqui você pode navegar para tela específica
    });
  }

  @override
  Widget build(BuildContext context) {
    return const MyApp();
  }
}
