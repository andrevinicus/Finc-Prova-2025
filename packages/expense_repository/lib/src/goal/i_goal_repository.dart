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
}
