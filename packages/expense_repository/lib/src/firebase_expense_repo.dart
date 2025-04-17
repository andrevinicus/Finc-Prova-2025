import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_repository/expense_repository.dart';

class FirebaseExpenseRepo implements ExpenseRepository {
  final categoryCollection = FirebaseFirestore.instance.collection('categories');
  final expenseCollection = FirebaseFirestore.instance.collection('expenses');

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
  Future<void> createExpense(ExpenseEntity expense) async {
    try {
      final expenseDocRef = expenseCollection.doc();
      await expenseDocRef.set(expense.toDocument());
    } catch (e) {
      log('Erro ao criar despesa: $e');
      throw Exception('Erro ao criar despesa');
    }
  }

  @override
  Future<List<ExpenseEntity>> getExpenses(String userId) async {
    try {
      final snapshot = await expenseCollection
          .where('userId', isEqualTo: userId)
          .get();

      if (snapshot.docs.isEmpty) return [];

      return snapshot.docs.map((doc) {
        return ExpenseEntity.fromDocument(doc.data());
      }).toList();
    } catch (e) {
      log('Erro ao buscar despesas: $e');
      throw Exception('Erro ao buscar despesas');
    }
  }
}
