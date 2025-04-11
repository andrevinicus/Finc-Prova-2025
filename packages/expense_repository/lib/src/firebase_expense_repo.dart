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
      rethrow;
    }
  }

  @override
  Future<List<Category>> getCategory(String userId) async {
    try {
      final snapshot = await categoryCollection
          .where('userId', isEqualTo: userId)
          .get();

      return snapshot.docs.map((doc) {
        return Category.fromEntity(
          CategoryEntity.fromDocument(doc.data()),
        );
      }).toList();
    } catch (e) {
      log('Erro ao buscar categorias: $e');
      rethrow;
    }
  }

  @override
  Future<void> createExpense(ExpenseEntity expense) async {
    try {
      await expenseCollection
          .doc(expense.expenseId)
          .set(expense.toDocument());
    } catch (e) {
      log('Erro ao criar despesa: $e');
      rethrow;
    }
  }

  @override
  Future<List<ExpenseEntity>> getExpenses(String userId) async {
    try {
      final snapshot = await expenseCollection
          .where('userId', isEqualTo: userId)
          .get();

      return snapshot.docs.map((doc) {
        return ExpenseEntity.fromDocument(doc.data());
      }).toList();
    } catch (e) {
      log('Erro ao buscar despesas: $e');
      rethrow;
    }
  }
}
