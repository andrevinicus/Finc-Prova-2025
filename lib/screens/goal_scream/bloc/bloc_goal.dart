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
    print('[GoalBloc] _onLoadGoals chamado para userId: ${event.userId}');
    emit(GoalLoading());
    try {
      final goals = await goalRepository.getGoals(event.userId);
      print('[GoalBloc] Goals carregados: ${goals.length}');
      for (var g in goals) {
        print('[GoalBloc] Meta: ${g.title}, ${g.currentAmount}/${g.targetAmount}');
      }
      emit(GoalLoaded(goals));
    } catch (e, s) {
      print('[GoalBloc] Erro ao carregar goals: $e');
      print(s);
      emit(GoalError(e.toString()));
    }
  }

  Future<void> _onAddGoal(
    AddGoal event,
    Emitter<GoalState> emit,
  ) async {
    print('[GoalBloc] _onAddGoal chamado: ${event.goal.title}');
    try {
      await goalRepository.createGoal(event.goal);
      print('[GoalBloc] Meta adicionada com sucesso');
      // Atualiza a lista após adicionar
      add(LoadGoals(event.goal.userId));
    } catch (e, s) {
      print('[GoalBloc] Erro ao adicionar goal: $e');
      print(s);
      emit(GoalError(e.toString()));
    }
  }

  Future<void> _onUpdateGoal(
    UpdateGoal event,
    Emitter<GoalState> emit,
  ) async {
    print('[GoalBloc] _onUpdateGoal chamado: ${event.goal.title}');
    try {
      await goalRepository.updateGoal(event.goal);
      print('[GoalBloc] Meta atualizada com sucesso');
      add(LoadGoals(event.goal.userId));
    } catch (e, s) {
      print('[GoalBloc] Erro ao atualizar goal: $e');
      print(s);
      emit(GoalError(e.toString()));
    }
  }

  Future<void> _onDeleteGoal(
    DeleteGoal event,
    Emitter<GoalState> emit,
  ) async {
    print('[GoalBloc] _onDeleteGoal chamado: ${event.goalId}');
    try {
      await goalRepository.deleteGoal(event.goalId);
      print('[GoalBloc] Meta deletada com sucesso');
      // Aqui você precisa passar o userId correto, se disponível
      // Se tiver uma variável goalId → pegue o userId do contexto ou evento
      // add(LoadGoals(userId));
    } catch (e, s) {
      print('[GoalBloc] Erro ao deletar goal: $e');
      print(s);
      emit(GoalError(e.toString()));
    }
  }
}
