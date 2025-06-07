
import 'package:equatable/equatable.dart';
import 'package:expense_repository/expense_repository.dart';


abstract class TransferEvent extends Equatable {
  const TransferEvent();

  @override
  List<Object?> get props => [];
}

// Evento para carregar as contas disponíveis
class LoadTransferData extends TransferEvent {}

// Eventos para atualizar os campos do formulário
class OriginAccountChanged extends TransferEvent {
  final BankAccountEntity originAccount;
  const OriginAccountChanged(this.originAccount);

  @override
  List<Object> get props => [originAccount];
}

class DestinationAccountChanged extends TransferEvent {
  final BankAccountEntity destinationAccount;
  const DestinationAccountChanged(this.destinationAccount);

  @override
  List<Object> get props => [destinationAccount];
}

class AmountChanged extends TransferEvent {
  final String amount;
  const AmountChanged(this.amount);

  @override
  List<Object> get props => [amount];
}

class DateChanged extends TransferEvent {
  final DateTime date;
  const DateChanged(this.date);

  @override
  List<Object> get props => [date];
}

class DescriptionChanged extends TransferEvent {
  final String description;
  const DescriptionChanged(this.description);

  @override
  List<Object> get props => [description];
}

// Evento para submeter a transferência
class TransferSubmitted extends TransferEvent {}