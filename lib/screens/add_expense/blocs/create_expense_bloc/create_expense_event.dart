part of 'create_expense_bloc.dart';

sealed class CreateExpenseEvent extends Equatable {
  const CreateExpenseEvent();

  @override
  List<Object?> get props => [];
}

// Evento para indicar o início do processo de criação (loading)
final class CreateExpenseStarted extends CreateExpenseEvent {}

// Evento para enviar a despesa de fato
final class CreateExpenseSubmitted extends CreateExpenseEvent {
  final Expense expense;

  const CreateExpenseSubmitted(this.expense);

  @override
  List<Object?> get props => [expense];
}
