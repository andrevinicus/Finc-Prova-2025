import 'package:equatable/equatable.dart';
import 'package:expense_repository/expense_repository.dart';

abstract class AddBankEvent extends Equatable {
  const AddBankEvent();

  @override
  List<Object> get props => [];
}

class SubmitNewBank extends AddBankEvent {
  final BankAccountModel bankAccount;

  const SubmitNewBank(this.bankAccount);

  @override
  List<Object> get props => [bankAccount];
}