import 'package:expense_repository/expense_repository.dart';
import 'package:finc/screens/home/blocs/get_income_bloc/get_expenses_event.dart';
import 'package:finc/screens/home/blocs/get_income_bloc/get_expenses_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GetIncomeBloc extends Bloc<GetIncomeEvent, GetIncomeState> {
  final IncomeRepository incomeRepository;

  GetIncomeBloc(this.incomeRepository) : super(GetIncomeInitial()) {
    on<GetIncome>((event, emit) async {
      emit(GetIncomeLoading());
      try {
        final entities = await incomeRepository.getIncomes(event.userId);
        final incomes = entities.map((e) => Income.fromEntity(e)).toList();
        emit(GetIncomeSuccess(incomes));
      } catch (e) {
        emit(GetIncomeFailure());
      }
    });
  }
}
