import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:expense_repository/expense_repository.dart';
import 'notification_event.dart';
import 'notification_state.dart';



class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final INotificationRepository repository;
  final FlutterLocalNotificationsPlugin localNotifications;
  final String idApp; // Identifica o usuário/app
  StreamSubscription<List<NotificationModel>>? _subscription;

  NotificationBloc({
    required this.repository,
    required this.localNotifications,
    required this.idApp,
  }) : super(NotificationInitial()) {
    print('[NotificationBloc] Criado para idApp: $idApp');

    // 🔹 Carrega e escuta notificações em tempo real
    on<LoadNotifications>((event, emit) async {
      emit(NotificationLoading());
      print('[NotificationBloc] LoadNotifications disparado');

      // Cancela stream antiga se existir
      await _subscription?.cancel();

      _subscription = repository.notificationsStream(idApp).listen(
        (notifications) {
          print('[NotificationBloc] Stream recebeu ${notifications.length} notificações');

          // Dispara notificações locais apenas para não visualizadas
          for (var notif in notifications.where((n) => !n.visualizado)) {
            print('[NotificationBloc] Disparando notificação local: ${notif.tipo} - ${notif.detalhes}');
            add(TriggerLocalNotification(
              id: notif.documentId.hashCode,
              title: notif.tipo,
              body: notif.detalhes,
            ));
          }

          // Atualiza estado com notificações
          add(_UpdateNotificationsState(notifications));
        },
        onError: (error) {
          print('[NotificationBloc] Erro na stream: $error');
          emit(NotificationError(error.toString()));
        },
      );
    });

    // 🔹 Evento interno para atualizar estado do BLoC
    on<_UpdateNotificationsState>((event, emit) {
      emit(NotificationLoaded(event.notifications));
      print('[NotificationBloc] Estado atualizado com ${event.notifications.length} notificações');
    });

    // 🔹 Marca notificação como visualizada
    on<MarkAsVisualized>((event, emit) async {
      print('[NotificationBloc] Marcando ${event.notificationId} como visualizada');
      try {
        await repository.markAsVisualized(event.notificationId);
      } catch (e) {
        print('[NotificationBloc] Erro ao marcar visualizada: $e');
        emit(NotificationError(e.toString()));
      }
    });

    // 🔹 Dispara notificação local
    on<TriggerLocalNotification>((event, emit) async {
      print('[NotificationBloc] TriggerLocalNotification id=${event.id}, title=${event.title}');
      try {
        const androidDetails = AndroidNotificationDetails(
          'channel_id',
          'Notificações',
          channelDescription: 'Canal de notificações do app',
          importance: Importance.max,
          priority: Priority.high,
        );

        const iosDetails = DarwinNotificationDetails();
        const notificationDetails = NotificationDetails(android: androidDetails, iOS: iosDetails);

        await localNotifications.show(event.id, event.title, event.body, notificationDetails);
      } catch (e) {
        print('[NotificationBloc] Erro ao disparar notificação local: $e');
        emit(NotificationError(e.toString()));
      }
    });
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    print('[NotificationBloc] Fechando BLoC e cancelando stream');
    return super.close();
  }
}

/// Evento interno para atualizar estado do BLoC sem chamar o repositório
class _UpdateNotificationsState extends NotificationEvent {
  final List<NotificationModel> notifications;

  _UpdateNotificationsState(this.notifications);

  @override
  List<Object?> get props => [notifications];
}
