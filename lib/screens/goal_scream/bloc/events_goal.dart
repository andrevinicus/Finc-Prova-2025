import 'package:equatable/equatable.dart';
import 'package:expense_repository/expense_repository.dart';

abstract class GoalEvent extends Equatable {
  const GoalEvent();

  @override
  List<Object?> get props => [];
}

// ========================
// 🔹 Metas
// ========================

class LoadGoals extends GoalEvent {
  final String userId;
  const LoadGoals(this.userId);

  @override
  List<Object?> get props => [userId];
}

class AddGoal extends GoalEvent {
  final Goal goal;
  const AddGoal(this.goal);

  @override
  List<Object?> get props => [goal];
}

class UpdateGoal extends GoalEvent {
  final Goal goal;
  const UpdateGoal(this.goal);

  @override
  List<Object?> get props => [goal];
}

class DeleteGoal extends GoalEvent {
  final String goalId;
  final String userId; // necessário para recarregar a lista
  const DeleteGoal(this.goalId, this.userId);

  @override
  List<Object?> get props => [goalId, userId];
}

// ========================
// 🔹 Transações
// ========================

class LoadTransactions extends GoalEvent {
  final String goalId;
  const LoadTransactions(this.goalId);

  @override
  List<Object?> get props => [goalId];
}

class AddTransaction extends GoalEvent {
  final Goal goal;
  final GoalTransaction transaction;
  const AddTransaction(this.goal, this.transaction);

  @override
  List<Object?> get props => [goal, transaction];
}

class DeleteTransaction extends GoalEvent {
  final Goal goal;
  final GoalTransaction transaction;
  const DeleteTransaction(this.goal, this.transaction);

  @override
  List<Object?> get props => [goal, transaction];
}
