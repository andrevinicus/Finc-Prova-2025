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
      final snapshot = await goalsCollection
          .where('userId', isEqualTo: userId)
          .orderBy('endDate')
          .get();

      final goals = snapshot.docs
          .map((doc) => Goal.fromMap(doc.data()))
          .toList();

      log('✅ ${goals.length} metas carregadas para o userId: $userId');
      return goals;
    } catch (e, st) {
      log('❌ Erro ao buscar metas', error: e, stackTrace: st);
      throw Exception('Erro ao buscar metas');
    }
  }
}
