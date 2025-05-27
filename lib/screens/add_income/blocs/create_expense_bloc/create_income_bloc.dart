import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:expense_repository/expense_repository.dart';

part 'create_Income_event.dart';
part 'create_Income_state.dart';

class CreateIncomeBloc extends Bloc<CreateIncomeEvent, CreateIncomeState> {
  final IncomeRepository _incomeRepository;

  CreateIncomeBloc(this._incomeRepository) : super(CreateIncomeInitial()) {
    on<CreateIncomeSubmitted>(_onSubmitted);
  }

  Future<void> _onSubmitted(
    CreateIncomeSubmitted event,
    Emitter<CreateIncomeState> emit,
  ) async {
    emit(CreateIncomeLoading());
    try {
      await _incomeRepository.createIncome(event.income.toEntity());
      emit(CreateIncomeSuccess());
    } catch (e) {
      emit(CreateIncomeFailure(e.toString()));
    }
  }
}
