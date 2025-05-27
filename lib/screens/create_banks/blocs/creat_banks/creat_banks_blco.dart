import 'package:expense_repository/expense_repository.dart';
import 'package:finc/screens/create_banks/blocs/creat_banks/creat_banck_state.dart';
import 'package:finc/screens/create_banks/blocs/creat_banks/creat_bank_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddBankBloc extends Bloc<AddBankEvent, AddBankState> {
  final BankRepository bankRepository;

  AddBankBloc({required this.bankRepository}) : super(AddBankInitial()) {
    on<SubmitNewBank>(_onSubmittedNewBank);
  }


  Future<void> _onSubmittedNewBank(
      SubmitNewBank event, Emitter<AddBankState> emit) async {
    emit(AddBankLoading());
    try {
      await bankRepository.createBank(event.bankAccount);
      emit(AddBankSuccess());
    } catch (e) {
      emit(AddBankFailure("Erro ao salvar a conta: ${e.toString()}"));
    }
  }
  
}
