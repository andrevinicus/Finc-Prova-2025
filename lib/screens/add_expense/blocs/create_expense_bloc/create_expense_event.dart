part of 'create_expense_bloc.dart';

sealed class CreateExpenseEvent extends Equatable {
  const CreateExpenseEvent();

  @override
  List<Object?> get props => [];
}

final class CreateExpenseSubmitted extends CreateExpenseEvent {
  final Expense expense;

  const CreateExpenseSubmitted(this.expense);

  @override
  List<Object?> get props => [expense];
}
