import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_repository/expense_repository.dart';

import 'get_bank_event.dart';
import 'get_bank_state.dart';

class GetBankBloc extends Bloc<GetBankEvent, GetBankState> {
  final ExpenseRepository expenseRepository;

  GetBankBloc(this.expenseRepository) : super(GetBankInitial()) {
    on<GetLoadBanks>((event, emit) async {
      emit(GetBankLoading());

      try {
        final banks = await expenseRepository.fetchBanks(event.userId);
        emit(GetBankLoaded(banks));
      } catch (e) {
        emit(GetBankError('Erro ao carregar bancos: ${e.toString()}'));
      }
    });
  }
}
