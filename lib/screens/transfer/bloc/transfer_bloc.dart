import 'package:bloc/bloc.dart';

import 'package:expense_repository/expense_repository.dart';
import 'package:finc/screens/transfer/bloc/transfer_event.dart';
import 'package:finc/screens/transfer/bloc/transfer_state.dart'; // Seu repositório



class TransferBloc extends Bloc<TransferEvent, TransferState> {
  final ExpenseRepository _expenseRepository; // Supondo que a lógica de transferência esteja aqui

  TransferBloc({required ExpenseRepository expenseRepository})
      : _expenseRepository = expenseRepository,
        super(TransferState(date: DateTime.now())) { // Define a data inicial como hoje
    on<LoadTransferData>(_onLoadTransferData);
    on<OriginAccountChanged>(_onOriginAccountChanged);
    on<DestinationAccountChanged>(_onDestinationAccountChanged);
    on<AmountChanged>(_onAmountChanged);
    on<DateChanged>(_onDateChanged);
    on<DescriptionChanged>(_onDescriptionChanged);
    on<TransferSubmitted>(_onTransferSubmitted);
  }

  void _onLoadTransferData(LoadTransferData event, Emitter<TransferState> emit) async {
    // Aqui você carregaria as contas do seu repositório
    // final accounts = await _expenseRepository.getBankAccounts();
    // emit(state.copyWith(availableAccounts: accounts));
  }
  
  void _onOriginAccountChanged(OriginAccountChanged event, Emitter<TransferState> emit) {
    emit(state.copyWith(originAccount: event.originAccount));
  }

  void _onDestinationAccountChanged(DestinationAccountChanged event, Emitter<TransferState> emit) {
    emit(state.copyWith(destinationAccount: event.destinationAccount));
  }

  void _onAmountChanged(AmountChanged event, Emitter<TransferState> emit) {
    final amount = double.tryParse(event.amount) ?? 0.0;
    emit(state.copyWith(amount: amount));
  }

  void _onDateChanged(DateChanged event, Emitter<TransferState> emit) {
    emit(state.copyWith(date: event.date));
  }

  void _onDescriptionChanged(DescriptionChanged event, Emitter<TransferState> emit) {
    emit(state.copyWith(description: event.description));
  }

  void _onTransferSubmitted(TransferSubmitted event, Emitter<TransferState> emit) async {
    if (!state.isFormValid) return; // Não faz nada se o formulário for inválido

    emit(state.copyWith(status: TransferStatus.loading));
    try {
      // Aqui você chamaria a função do seu repositório para criar a transferência
      // await _expenseRepository.createTransfer(
      //   from: state.originAccount!,
      //   to: state.destinationAccount!,
      //   amount: state.amount,
      //   date: state.date!,
      //   description: state.description,
      // );
      emit(state.copyWith(status: TransferStatus.success));
    } catch (e) {
      emit(state.copyWith(status: TransferStatus.failure, errorMessage: e.toString()));
    }
  }
}