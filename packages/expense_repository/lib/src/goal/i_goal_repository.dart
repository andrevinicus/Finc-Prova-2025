import 'package:expense_repository/expense_repository.dart';

abstract class IGoalRepository {
  /// Cria uma nova meta
  Future<void> createGoal(Goal goal);

  /// Atualiza uma meta existente
  Future<void> updateGoal(Goal goal);

  /// Deleta uma meta pelo ID
  Future<void> deleteGoal(String goalId);

  /// Retorna todas as metas de um usuário, ordenadas pela data final
  Future<List<Goal>> getGoals(String userId);

  // ========================================
  // 🔹 NOVOS MÉTODOS PARA TRANSAÇÕES
  // ========================================

  /// Adiciona uma transação (depósito) a uma meta
  /// e atualiza automaticamente o [currentAmount].
  Future<void> addTransaction(String goalId, GoalTransaction transaction);

  /// Busca todas as transações de uma meta específica
  Future<List<GoalTransaction>> getTransactions(String goalId);
}
