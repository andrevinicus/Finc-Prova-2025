import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:expense_repository/expense_repository.dart';

part 'create_expense_event.dart';
part 'create_expense_state.dart';

class CreateExpenseBloc extends Bloc<CreateExpenseEvent, CreateExpenseState> {
  final ExpenseRepository _expenseRepository;

  CreateExpenseBloc(this._expenseRepository) : super(CreateExpenseInitial()) {
    on<CreateExpenseSubmitted>(_onSubmitted);
  }

  Future<void> _onSubmitted(
    CreateExpenseSubmitted event,
    Emitter<CreateExpenseState> emit,
  ) async {
    emit(CreateExpenseLoading());
    try {
      await _expenseRepository.createExpense(event.expense.toEntity());
      emit(CreateExpenseSuccess());
    } catch (e) {
      emit(CreateExpenseFailure(e.toString()));
    }
  }
}
