import 'package:equatable/equatable.dart';
import 'package:expense_repository/expense_repository.dart';

enum TransferStatus { initial, loading, success, failure }

class TransferState extends Equatable {
  const TransferState({
    this.status = TransferStatus.initial,
    this.availableAccounts = const [],
    this.originAccount,
    this.destinationAccount,
    this.amount = 0.0,
    this.date,
    this.description = '',
    this.errorMessage,
  });

  final TransferStatus status;
  final List<BankAccountEntity> availableAccounts;
  final BankAccountEntity? originAccount;
  final BankAccountEntity? destinationAccount;
  final double amount;
  final DateTime? date;
  final String description;
  final String? errorMessage;

  // Lógica para saber se o formulário está válido
  bool get isFormValid =>
      originAccount != null &&
      destinationAccount != null &&
      amount > 0 &&
      date != null &&
      originAccount!.id != destinationAccount!.id; // Garante que as contas são diferentes

  TransferState copyWith({
    TransferStatus? status,
    List<BankAccountEntity>? availableAccounts,
    BankAccountEntity? originAccount,
    BankAccountEntity? destinationAccount,
    double? amount,
    DateTime? date,
    String? description,
    String? errorMessage,
  }) {
    return TransferState(
      status: status ?? this.status,
      availableAccounts: availableAccounts ?? this.availableAccounts,
      originAccount: originAccount ?? this.originAccount,
      destinationAccount: destinationAccount ?? this.destinationAccount,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      description: description ?? this.description,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        availableAccounts,
        originAccount,
        destinationAccount,
        amount,
        date,
        description,
        errorMessage
      ];
}