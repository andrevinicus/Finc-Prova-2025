import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:expense_repository/expense_repository.dart';

part 'get_expenses_event.dart';
part 'get_expenses_state.dart';

class GetExpensesBloc extends Bloc<GetExpensesEvent, GetExpensesState> {
  final ExpenseRepository expenseRepository;

  GetExpensesBloc(this.expenseRepository) : super(GetExpensesInitial()) {
    on<GetExpenses>((event, emit) async {
      print('GetExpensesBloc: Evento GetExpenses recebido para userId=${event.userId}');
      
      emit(GetExpensesLoading());
      try {
        final entities = await expenseRepository.getExpenses(event.userId);
        print('GetExpensesBloc: Recebido ${entities.length} despesas do repositório');

        final expenses = entities.map((e) => Expense.fromEntity(e)).toList();
        print('GetExpensesBloc: Convertido para Expense, total=${expenses.length}');
        
        emit(GetExpensesSuccess(expenses));
        print('GetExpensesBloc: Emitido GetExpensesSuccess');
      } catch (e, stackTrace) {
        print('GetExpensesBloc: Erro ao buscar expenses -> $e');
        print(stackTrace);
        emit(GetExpensesFailure());
      }
    });
  }
}
