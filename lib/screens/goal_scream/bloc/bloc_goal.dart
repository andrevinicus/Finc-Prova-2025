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

    // Eventos de lançamentos
    on<AddTransaction>(_onAddTransaction);
    on<DeleteTransaction>(_onDeleteTransaction);
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
    try {
      await goalRepository.createGoal(event.goal);
      add(LoadGoals(event.goal.userId));
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
      add(LoadGoals(event.goal.userId));
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

    // 🔹 Recarrega automaticamente a lista usando o userId
    add(LoadGoals(event.userId));
  } catch (e) {
    emit(GoalError(e.toString()));
  }
}

  // Novo: adicionar lançamento
Future<void> _onAddTransaction(
  AddTransaction event,
  Emitter<GoalState> emit,
) async {
  try {
    // Salva a transação no Firestore
    if (goalRepository is FirebaseGoalRepository) {
      await (goalRepository as FirebaseGoalRepository)
          .addTransaction(event.goal.id, event.transaction);
    }

    // Atualiza o estado local do Goal
    final updatedGoal = event.goal.copyWith(
      currentAmount: event.goal.currentAmount + event.transaction.amount,
    );

    // Atualiza meta no Firestore
    await goalRepository.updateGoal(updatedGoal);

    // Recarrega lista
    add(LoadGoals(event.goal.userId));
  } catch (e) {
    emit(GoalError(e.toString()));
  }
}


  // Novo: excluir lançamento
Future<void> _onDeleteTransaction(
  DeleteTransaction event,
  Emitter<GoalState> emit,
) async {
  try {
    if (goalRepository is FirebaseGoalRepository) {
      final goalRepo = goalRepository as FirebaseGoalRepository;

      // Deleta a transação da subcoleção
      final txRef = goalRepo.goalsCollection
          .doc(event.goal.id)
          .collection('transactions')
          .doc(event.transaction.id);
      await txRef.delete();
    }

    // Atualiza meta localmente
    final updatedGoal = event.goal.copyWith(
      currentAmount: event.goal.currentAmount - event.transaction.amount,
    );

    await goalRepository.updateGoal(updatedGoal);

    // Recarrega lista
    add(LoadGoals(event.goal.userId));
  } catch (e) {
    emit(GoalError(e.toString()));
  }
}

}
