import 'package:flutter_bloc/flutter_bloc.dart';
import 'bank_event.dart';
import 'bank_state.dart';
import 'package:expense_repository/expense_repository.dart';

class BankBloc extends Bloc<BankEvent, BankState> {
  final ExpenseRepository expenseRepository;

  BankBloc(this.expenseRepository) : super(BankInitial()) {
    on<LoadBanks>((event, emit) async {
      emit(BankLoading());
      try {
        // Passa o userId do evento para o fetchBanks, se aplicável
        final banks = await expenseRepository.fetchBanks(event.userId);
        emit(BankLoaded(banks));
      } catch (e) {
        emit(BankError('Erro ao carregar bancos: ${e.toString()}'));
      }
    });
  }
}
