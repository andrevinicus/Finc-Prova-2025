import 'package:equatable/equatable.dart';
import 'package:expense_repository/expense_repository.dart';


abstract class GoalEvent extends Equatable {
  const GoalEvent();

  @override
  List<Object?> get props => [];
}

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
  const DeleteGoal(this.goalId);

  @override
  List<Object?> get props => [goalId];
}
