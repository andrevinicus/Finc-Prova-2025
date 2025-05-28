import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:expense_repository/expense_repository.dart';  // Repositórios de expense/income

// --- EVENTOS ---
abstract class GetFinancialDataEvent extends Equatable {
  const GetFinancialDataEvent();

  @override
  List<Object> get props => [];
}

class GetFinancialData extends GetFinancialDataEvent {
  final String userId;

  const GetFinancialData(this.userId);

  @override
  List<Object> get props => [userId];
}

// --- ESTADOS ---
abstract class GetFinancialDataState extends Equatable {
  const GetFinancialDataState();

  @override
  List<Object> get props => [];
}

class GetFinancialDataInitial extends GetFinancialDataState {}

class GetFinancialDataLoading extends GetFinancialDataState {}

class GetFinancialDataFailure extends GetFinancialDataState {}

class GetFinancialDataSuccess extends GetFinancialDataState {
  final List<Expense> expenses;
  final List<Income> income;

  const GetFinancialDataSuccess({required this.expenses, required this.income});

  @override
  List<Object> get props => [expenses, income];
}

// --- BLOC ---
class GetFinancialDataBloc extends Bloc<GetFinancialDataEvent, GetFinancialDataState> {
  final ExpenseRepository expenseRepository;
  final IncomeRepository incomeRepository;

  GetFinancialDataBloc({
    required this.expenseRepository,
    required this.incomeRepository,
  }) : super(GetFinancialDataInitial()) {
    on<GetFinancialData>(_onGetFinancialData);
  }

  Future<void> _onGetFinancialData(
    GetFinancialData event,
    Emitter<GetFinancialDataState> emit,
  ) async {
    emit(GetFinancialDataLoading());
    try {
      final expenseEntities = await expenseRepository.getExpenses(event.userId);
      final incomeEntities = await incomeRepository.getIncomes(event.userId);

      final expenses = expenseEntities.map((e) => Expense.fromEntity(e)).toList();
      final incomes = incomeEntities.map((i) => Income.fromEntity(i)).toList();

      emit(GetFinancialDataSuccess(expenses: expenses, income: incomes));
    } catch (_) {
      emit(GetFinancialDataFailure());
    }
  }
}


