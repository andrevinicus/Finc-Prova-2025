import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_repository/expense_repository.dart';

class BankRepository {
  final FirebaseFirestore firestore;

  BankRepository({FirebaseFirestore? firestoreInstance})
      : firestore = firestoreInstance ?? FirebaseFirestore.instance;

  /// Busca as contas bancárias do usuário com base no [userId]
  Future<List<BankAccountEntity>> fetchBanks(String userId) async {
    try {
      final querySnapshot = await firestore
          .collection('banks')
          .where('userId', isEqualTo: userId)
          .get();

      return querySnapshot.docs
          .map((doc) => BankAccountModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar bancos: $e');
    }
  }

  /// Cria uma nova conta bancária no Firestore
  Future<void> createBank(BankAccountEntity bank) async {
    try {
      await firestore
          .collection('banks')
          .doc(bank.id)
          .set(BankAccountModel.fromEntity(bank).toJson());
    } catch (e) {
      throw Exception('Erro ao criar banco: $e');
    }
  }

  /// Atualiza os dados de uma conta bancária existente
  Future<void> updateBank(BankAccountEntity bank) async {
    try {
      await firestore
          .collection('banks')
          .doc(bank.id)
          .update(BankAccountModel.fromEntity(bank).toJson());
    } catch (e) {
      throw Exception('Erro ao atualizar banco: $e');
    }
  }

  /// Remove uma conta bancária pelo [bankId]
  Future<void> deleteBank(String bankId) async {
    try {
      await firestore.collection('banks').doc(bankId).delete();
    } catch (e) {
      throw Exception('Erro ao deletar banco: $e');
    }
  }
}
