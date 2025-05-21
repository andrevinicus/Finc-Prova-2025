import 'package:equatable/equatable.dart';
import 'package:expense_repository/expense_repository.dart';

abstract class BankState extends Equatable {
  const BankState();

  @override
  List<Object?> get props => [];
}

class BankInitial extends BankState {}

class BankLoading extends BankState {}

class BankLoaded extends BankState {
  final List<BankEntity> banks;

  const BankLoaded(this.banks);

  @override
  List<Object?> get props => [banks];
}

class BankError extends BankState {
  final String message;

  const BankError(this.message);

  @override
  List<Object?> get props => [message];
}
