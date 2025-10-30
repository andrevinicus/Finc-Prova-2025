import 'package:equatable/equatable.dart';

abstract class NotificationEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadNotifications extends NotificationEvent {
  final String idApp;

  LoadNotifications(this.idApp);

  @override
  List<Object?> get props => [idApp];
}

class MarkAsVisualized extends NotificationEvent {
  final String notificationId;

  MarkAsVisualized(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

class TriggerLocalNotification extends NotificationEvent {
  final String title;
  final String body;
  final int id;

  TriggerLocalNotification({required this.id, required this.title, required this.body});

  @override
  List<Object?> get props => [id, title, body];
}
