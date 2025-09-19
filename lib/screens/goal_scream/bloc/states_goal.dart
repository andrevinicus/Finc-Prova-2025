import 'package:equatable/equatable.dart';
import 'package:expense_repository/expense_repository.dart';

abstract class GoalState extends Equatable {
  const GoalState();

  @override
  List<Object?> get props => [];
}

class GoalInitial extends GoalState {}
class GoalLoading extends GoalState {}
class GoalLoaded extends GoalState {
  final List<Goal> goals;
  const GoalLoaded(this.goals);

  @override
  List<Object?> get props => [goals];
}
class GoalError extends GoalState {
  final String message;
  const GoalError(this.message);

  @override
  List<Object?> get props => [message];
}

// ========================
// 🔹 Novos estados para transações
// ========================

class TransactionLoading extends GoalState {}

class TransactionLoaded extends GoalState {
  final List<GoalTransaction> transactions;
  final String goalId;

  const TransactionLoaded(this.goalId, this.transactions);

  @override
  List<Object?> get props => [goalId, transactions];
}

class TransactionError extends GoalState {
  final String message;
  const TransactionError(this.message);

  @override
  List<Object?> get props => [message];
}
