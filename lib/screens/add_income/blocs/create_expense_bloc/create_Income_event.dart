part of 'create_income_bloc.dart';

sealed class CreateIncomeEvent extends Equatable {
  const CreateIncomeEvent();

  @override
  List<Object?> get props => [];
}

// Evento para indicar o início do processo de criação (loading)
final class CreateIncomeStarted extends CreateIncomeEvent {}

// Evento para enviar a despesa de fato
final class CreateIncomeSubmitted extends CreateIncomeEvent {
  final Income income;

  const CreateIncomeSubmitted(this.income);

  @override
  List<Object?> get props => [income];
}
