import 'package:expense_repository/expense_repository.dart';
import 'package:finc/screens/home/blocs/get_income_bloc/get_income_event.dart';
import 'package:finc/screens/home/blocs/get_income_bloc/get_income_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GetIncomeBloc extends Bloc<GetIncomeEvent, GetIncomeState> {
  final IncomeRepository incomeRepository;

  GetIncomeBloc(this.incomeRepository) : super(GetIncomeInitial()) {
    on<GetIncome>((event, emit) async {
      print('GetIncomeBloc: Evento GetIncome recebido para userId=${event.userId}');
      
      emit(GetIncomeLoading());
      try {
        final entities = await incomeRepository.getIncomes(event.userId);
        print('GetIncomeBloc: Recebido ${entities.length} entradas do repositório');

        final incomes = entities.map((e) => Income.fromEntity(e)).toList();
        print('GetIncomeBloc: Convertido para Income, total=${incomes.length}');
        
        emit(GetIncomeSuccess(incomes));
        print('GetIncomeBloc: Emitido GetIncomeSuccess');
      } catch (e, stackTrace) {
        print('GetIncomeBloc: Erro ao buscar incomes -> $e');
        print(stackTrace);
        emit(GetIncomeFailure());
      }
    });
  }
}
