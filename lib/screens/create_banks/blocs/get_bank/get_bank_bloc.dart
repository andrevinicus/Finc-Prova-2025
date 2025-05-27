import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_repository/expense_repository.dart';

import 'get_bank_event.dart';
import 'get_bank_state.dart';

class GetBankBloc extends Bloc<GetBankEvent, GetBankState> {
  final BankRepository bankRepository;

  GetBankBloc(this.bankRepository) : super(GetBankInitial()) {
    on<GetLoadBanks>((event, emit) async {
      emit(GetBankLoading());

      try {
        final banks = await bankRepository.fetchBanks(event.userId);
        emit(GetBankLoaded(banks));
      } catch (e) {
        emit(GetBankError('Erro ao carregar bancos: ${e.toString()}'));
      }
    });
  }
}
