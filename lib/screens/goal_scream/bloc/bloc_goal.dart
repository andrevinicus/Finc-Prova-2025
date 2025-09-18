import 'package:bloc/bloc.dart';
import 'package:expense_repository/expense_repository.dart';
import 'events_goal.dart';
import 'states_goal.dart';


class GoalBloc extends Bloc<GoalEvent, GoalState> {
  final IGoalRepository goalRepository;

  GoalBloc({required this.goalRepository}) : super(GoalInitial()) {
    on<LoadGoals>(_onLoadGoals);
    on<AddGoal>(_onAddGoal);
    on<UpdateGoal>(_onUpdateGoal);
    on<DeleteGoal>(_onDeleteGoal);
  }

  Future<void> _onLoadGoals(
    LoadGoals event,
    Emitter<GoalState> emit,
  ) async {
    emit(GoalLoading());
    try {
      final goals = await goalRepository.getGoals(event.userId);
      emit(GoalLoaded(goals));
    } catch (e) {
      emit(GoalError(e.toString()));
    }
  }

  Future<void> _onAddGoal(
    AddGoal event,
    Emitter<GoalState> emit,
  ) async {
    try {
      await goalRepository.createGoal(event.goal);
    } catch (e) {
      emit(GoalError(e.toString()));
    }
  }

  Future<void> _onUpdateGoal(
    UpdateGoal event,
    Emitter<GoalState> emit,
  ) async {
    try {
      await goalRepository.updateGoal(event.goal);
    } catch (e) {
      emit(GoalError(e.toString()));
    }
  }

  Future<void> _onDeleteGoal(
    DeleteGoal event,
    Emitter<GoalState> emit,
  ) async {
    try {
      await goalRepository.deleteGoal(event.goalId);
    } catch (e) {
      emit(GoalError(e.toString()));
    }
  }
}
