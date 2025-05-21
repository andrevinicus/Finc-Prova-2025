import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_repository/expense_repository.dart';
class BankRepository {
  final FirebaseFirestore firestore;

  BankRepository({FirebaseFirestore? firestoreInstance})
      : firestore = firestoreInstance ?? FirebaseFirestore.instance;

  Future<List<BankEntity>> fetchBanks() async {
    try {
      final querySnapshot = await firestore.collection('banks').get();

      return querySnapshot.docs
          .map((doc) => BankModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar bancos: $e');
    }
  }
}
