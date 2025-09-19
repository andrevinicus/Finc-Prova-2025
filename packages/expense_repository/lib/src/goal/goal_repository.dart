import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_repository/expense_repository.dart';


class FirebaseGoalRepository implements IGoalRepository {
  final CollectionReference<Map<String, dynamic>> goalsCollection =
      FirebaseFirestore.instance.collection('goals');

  @override
  Future<void> createGoal(Goal goal) async {
    try {
      await goalsCollection.doc(goal.id).set(goal.toMap());
      log('✅ Meta criada: ${goal.title} (ID: ${goal.id})');
    } catch (e, st) {
      log('❌ Erro ao criar meta', error: e, stackTrace: st);
      throw Exception('Erro ao criar meta');
    }
  }

  @override
  Future<void> updateGoal(Goal goal) async {
    try {
      await goalsCollection.doc(goal.id).update(goal.toMap());
      log('✅ Meta atualizada: ${goal.title} (ID: ${goal.id})');
    } catch (e, st) {
      log('❌ Erro ao atualizar meta', error: e, stackTrace: st);
      throw Exception('Erro ao atualizar meta');
    }
  }

  @override
  Future<void> deleteGoal(String goalId) async {
    try {
      await goalsCollection.doc(goalId).delete();
      log('✅ Meta deletada (ID: $goalId)');
    } catch (e, st) {
      log('❌ Erro ao deletar meta', error: e, stackTrace: st);
      throw Exception('Erro ao deletar meta');
    }
  }

  @override
  Future<List<Goal>> getGoals(String userId) async {
    try {
      log('🔹 Buscando metas para userId: $userId');

      final snapshot = await goalsCollection
          .where('userId', isEqualTo: userId)
          .orderBy('endDate')
          .get();

      log('🔹 Documentos encontrados: ${snapshot.docs.length}');

      final goals =
          snapshot.docs.map((doc) => Goal.fromMap(doc.data())).toList();

      log('✅ ${goals.length} metas carregadas para o userId: $userId');
      return goals;
    } catch (e, st) {
      log('❌ Erro ao buscar metas', error: e, stackTrace: st);
      throw Exception('Erro ao buscar metas');
    }
  }

  // =============================
  // 🔹 NOVO: Transações da meta
  // =============================

  Future<void> addTransaction(String goalId, GoalTransaction tx) async {
    try {
      final goalRef = goalsCollection.doc(goalId);

      final batch = FirebaseFirestore.instance.batch();

      // Salva transação na subcoleção
      final txRef = goalRef.collection('transactions').doc(tx.id);
      batch.set(txRef, tx.toMap());

      // Atualiza o saldo da meta
      batch.update(goalRef, {
        'currentAmount': FieldValue.increment(tx.amount),
      });

      await batch.commit();

      log('✅ Transação adicionada: ${tx.amount} (meta $goalId)');
    } catch (e, st) {
      log('❌ Erro ao adicionar transação', error: e, stackTrace: st);
      throw Exception('Erro ao adicionar transação');
    }
  }

  Future<List<GoalTransaction>> getTransactions(String goalId) async {
    try {
      final snapshot = await goalsCollection
          .doc(goalId)
          .collection('transactions')
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => GoalTransaction.fromMap(doc.data()))
          .toList();
    } catch (e, st) {
      log('❌ Erro ao buscar transações', error: e, stackTrace: st);
      throw Exception('Erro ao buscar transações');
    }
  }
}
