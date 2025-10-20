import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_repository/expense_repository.dart';

class NotificationRepository implements INotificationRepository {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final String collectionName = 'notificacao';

  @override
  Future<List<NotificationModel>> fetchNotifications(String idApp) async {
    final snapshot = await firestore
        .collection(collectionName)
        .where('idApp', isEqualTo: idApp)
        .where('visualizado', isEqualTo: false)
        .orderBy('dataLancamento', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => NotificationModel.fromFirestore(doc))
        .toList();
  }

  @override
  Future<void> markAsVisualized(String notificationId) async {
    await firestore.collection(collectionName).doc(notificationId).update({
      'visualizado': true,
    });
  }

  @override
  Future<void> addNotification(NotificationModel notification) async {
    await firestore
        .collection(collectionName)
        .doc(notification.documentId)
        .set(notification.toFirestore());
  }

  @override
  Future<List<NotificationModel>> getAllNotifications(String idApp) async {
    final snapshot = await firestore
        .collection(collectionName)
        .where('idApp', isEqualTo: idApp)
        .orderBy('dataLancamento', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => NotificationModel.fromFirestore(doc))
        .toList();
  }

  /// 🔴 Stream para tempo real
  Stream<List<NotificationModel>> notificationsStream(String idApp) {
    return firestore
        .collection(collectionName)
        .where('idApp', isEqualTo: idApp)
        .orderBy('dataLancamento', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => NotificationModel.fromFirestore(doc)).toList());
  }
}
