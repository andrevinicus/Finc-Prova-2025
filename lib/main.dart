import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finc/Notification/bloc_notifica_token/user_token_bloc.dart';
import 'package:finc/Notification/fcm_service.dart';
import 'package:finc/auth/auth_bloc.dart';
import 'package:finc/auth/auth_event.dart';
import 'package:finc/auth/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:finc/Notification/service_notifica.dart';
import 'package:finc/Notification/bloc_notifica_local/notification_bloc.dart';
import 'package:finc/Notification/bloc_notifica_local/notification_event.dart';
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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp();

  await LocalNotificationService.init();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  Bloc.observer = SimpleBlocObserver();

  runApp(MyAppRoot());
}

// =========================
// APP ROOT COM BLOCs
// =========================
class MyAppRoot extends StatelessWidget {
  const MyAppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc(FirebaseAuth.instance)..add(AuthCheckRequested()),
        ),
        BlocProvider<UserTokenBloc>(
          create: (_) => UserTokenBloc(FirebaseFirestore.instance),
        ),
      ],
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is Authenticated) {
            final userId = state.user.uid;

            return BlocProvider(
              create: (_) => NotificationBloc(
                repository: NotificationRepository(),
                localNotifications: LocalNotificationService.instance,
                idApp: userId, // ✅ usa o ID real do usuário logado
              ),
              child: MyAppWrapper(userId: userId),
            );
          }

          // Se não logado, apenas carrega app base
          return const MyAppWrapper();
        },
      ),
    );
  }
}

// =========================
// WIDGET WRAPPER PRINCIPAL
// =========================
class MyAppWrapper extends StatefulWidget {
  final String? userId;
  const MyAppWrapper({super.key, this.userId});

  @override
  State<MyAppWrapper> createState() => _MyAppWrapperState();
}

class _MyAppWrapperState extends State<MyAppWrapper> {
  NotificationBloc? _notificationBloc;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Garante que roda apenas uma vez
    if (!_initialized && widget.userId != null) {
      _initialized = true;

      // Agora o context já tem o Bloc
      _notificationBloc = BlocProvider.of<NotificationBloc>(context);

      // Inicializa FCM depois que o frame está pronto
      WidgetsBinding.instance.addPostFrameCallback((_) {
        FCMService.init(userId: widget.userId!, context: context);
      });

      // Escuta mensagens FCM
      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        final documentId = message.data['documentId'] ?? '';

        await LocalNotificationService.showNotification(
          id: documentId.hashCode,
          title: message.notification?.title ?? 'Nova notificação',
          body: message.notification?.body ?? '',
          payload: documentId,
        );

        _notificationBloc?.add(TriggerLocalNotification(
          id: documentId.hashCode,
          title: message.notification?.title ?? 'Nova notificação',
          body: message.notification?.body ?? '',
        ));

        print('📩 Notificação FCM em foreground: ${message.notification?.title}');
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        final documentId = message.data['documentId'] ?? '';
        print('[FCM OpenedApp] Notificação clicada: $documentId');
        // Aqui você pode navegar para a tela específica
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return const MyApp();
  }
}
