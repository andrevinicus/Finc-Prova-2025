import 'notification_model.dart';

abstract class INotificationRepository {
  Future<List<NotificationModel>> fetchNotifications(String idApp);
  Future<void> markAsVisualized(String notificationId);
  Future<void> addNotification(NotificationModel notification);
  Future<List<NotificationModel>> getAllNotifications(String idApp);

  /// 🔹 Stream para notificações em tempo real
  Stream<List<NotificationModel>> notificationsStream(String idApp);
}
