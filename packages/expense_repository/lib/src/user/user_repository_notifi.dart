import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_repository/expense_repository.dart';


class UserRepository {
  final FirebaseFirestore _firestore;

  UserRepository(this._firestore);

  /// Atualiza ou cria o token FCM do usuário
  Future<void> updateUserFcmToken({
    required String userId,
    required String fcmToken,
  }) async {
    try {
      final userRef = _firestore.collection('users').doc(userId);

      await userRef.set(
        {'fcmToken': fcmToken},
        SetOptions(merge: true), // mantém outros campos intactos
      );

      print('✅ FCM token atualizado para o usuário $userId: $fcmToken');
    } catch (e) {
      print('❌ Erro ao atualizar FCM token: $e');
      rethrow;
    }
  }

  /// Opcional: buscar usuário com token
  Future<UserModel?> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) return null;

      return UserModel.fromMap(doc.data()!);
    } catch (e) {
      print('❌ Erro ao buscar usuário: $e');
      return null;
    }
  }
}
