import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_repository/expense_repository.dart';



class FirebaseIncomeRepo implements IncomeRepository {
  final categoryCollection = FirebaseFirestore.instance.collection('categories');
  final incomeCollection = FirebaseFirestore.instance.collection('income');
  final bankCollection = FirebaseFirestore.instance.collection('banks');
  
  


  @override
  Future<void> createCategory(Category category) async {
    try {
      await categoryCollection
          .doc(category.categoryId)
          .set(category.toEntity().toDocument());
    } catch (e) {
      log('Erro ao criar categoria: $e');
      throw Exception('Erro ao criar categoria');
    }
  }

  
  @override
  Future<List<Category>> getCategory(String userId) async {
    try {
      final snapshot = await categoryCollection
          .where('userId', isEqualTo: userId)
          .get();

      if (snapshot.docs.isEmpty) return [];

      return snapshot.docs.map((doc) {
        return Category.fromEntity(
          CategoryEntity.fromDocument(doc.data()),
        );
      }).toList();
    } catch (e) {
      log('Erro ao buscar categorias: $e');
      throw Exception('Erro ao buscar categorias');
    }
  }

  @override
  Future<void> createIncome(IncomeEntity income) async {
    try {
      final incomeDocRef = incomeCollection.doc();
      await incomeDocRef.set(income.toDocument());
    } catch (e) {
      log('Erro ao criar despesa: $e');
      throw Exception('Erro ao criar despesa');
    }
  }

  @override
  Future<List<IncomeEntity>> getIncomes(String userId) async {
    try {
      final snapshot = await incomeCollection
          .where('userId', isEqualTo: userId)
          .get();

      if (snapshot.docs.isEmpty) return [];

      return snapshot.docs.map((doc) {
        return IncomeEntity.fromDocument(doc.data());
      }).toList();
    } catch (e) {
      log('Erro ao buscar despesas: $e');
      throw Exception('Erro ao buscar despesas');
    }
  }
  @override
  Future<List<BankAccountEntity>> fetchBanks(String userId) async {
    try {
      final querySnapshot = await bankCollection
        .where('userId', isEqualTo: userId)
        .get();

      return querySnapshot.docs
        .map((doc) => BankAccountModel.fromJson(doc.data()))
        .toList(); // ← Model que herda da Entity
    } catch (e) {
      log('Erro ao buscar bancos: $e');
      throw Exception('Erro ao buscar bancos');
    }
  }
  @override
  Future<void> createBank(BankAccountEntity bank) async {
    try {
      final bankModel = BankAccountModel.fromEntity(bank);
      await bankCollection
          .doc(bankModel.id)
          .set(bankModel.toJson());
    } catch (e, stackTrace) {
      log('Erro ao criar banco', error: e, stackTrace: stackTrace);
      throw Exception('Erro ao criar banco');
    }
  }
    
}
