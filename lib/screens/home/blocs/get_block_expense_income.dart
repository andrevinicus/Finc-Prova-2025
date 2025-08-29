import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:expense_repository/expense_repository.dart';
 // <-- seu repo local

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
class GetFinancialDataFailure extends GetFinancialDataState {
  final String message;
  const GetFinancialDataFailure(this.message);
  @override
  List<Object> get props => [message];
}
class GetFinancialDataSuccess extends GetFinancialDataState {
  final List<Expense> expenses;
  final List<Income> income;
  final Map<String, Category> categoryMap;
  const GetFinancialDataSuccess({
    required this.expenses,
    required this.income,
    required this.categoryMap,
  });
  @override
  List<Object> get props => [expenses, income, categoryMap];
}

// --- BLOC ---
class GetFinancialDataBloc extends Bloc<GetFinancialDataEvent, GetFinancialDataState> {
  final ExpenseRepository expenseRepository;
  final IncomeRepository incomeRepository;
  final CategoryRepository categoryRepository;

  // Use seu FirebaseCategoryRepository para garantir que os prints apareçam
  GetFinancialDataBloc({
    required this.expenseRepository,
    required this.incomeRepository,
    CategoryRepository? categoryRepository,
  })  : categoryRepository = categoryRepository ?? FirebaseCategoryRepository(),
        super(GetFinancialDataInitial()) {
    on<GetFinancialData>(_onGetFinancialData);
  }

  Future<void> _onGetFinancialData(
    GetFinancialData event,
    Emitter<GetFinancialDataState> emit,
  ) async {
    emit(GetFinancialDataLoading());
    print('➡️ GetFinancialData event recebido para userId: ${event.userId}');

    try {
      // --- Carregar categorias do usuário ---
      final categories = await categoryRepository.getCategories(event.userId);

      // Criar map garantindo IDs únicos e filtrando pelo mesmo userId
// Criar map garantindo IDs únicos
      final categoryMap = <String, Category>{};
      for (var c in categories) {
        final id = c.categoryId.toString().trim();
        final userIdCat = c.userId?.toString().trim() ?? '';

        // Adiciona a categoria se ainda não existir no map
        if (!categoryMap.containsKey(id)) {
          categoryMap[id] = c;
        } else {
          print('⚠️ Categoria com ID duplicado ignorada: ${c.name}, ID: $id');
        }

        // Aviso se o userId não bater
        if (userIdCat != event.userId.trim()) {
          print('⚠️ Categoria do Firebase com userId diferente: ${c.name}, Firebase userId: $userIdCat, esperado: ${event.userId}');
        }
      }

      final categoryList = categoryMap.values.toList();

      print('✅ Categorias carregadas: ${categoryList.length}');
      for (var c in categoryList) {
        print('📌 Categoria: ${c.name} | ID: ${c.categoryId} | Tipo: ${c.type} | UserId: ${c.userId}');
      }

      // --- Função auxiliar para conversão segura ---
      List<T> safeConvert<T>(List<dynamic> entities, T Function(dynamic) converter) {
        return entities.map((e) {
          try {
            return converter(e);
          } catch (ex) {
            print('❌ Erro ao converter $T: $ex');
            return null;
          }
        }).where((e) => e != null).cast<T>().toList();
      }

      // --- Despesas ---
      final expenseEntities = await expenseRepository.getExpenses(event.userId);
      final safeExpenses = safeConvert<Expense>(expenseEntities, (e) => Expense.fromEntity(e));

      print('✅ Despesas recebidas: ${safeExpenses.length}');
      for (var exp in safeExpenses) {
        final key = exp.categoryId.toString().trim();
        final cat = categoryMap[key];
        print(
          '💸 Expense | ID: ${exp.id} | Valor: ${exp.amount} | '
          'categoryId raw: ${exp.categoryId} | lookupKey: "$key" | '
          'Categoria: ${cat?.name ?? "Desconhecida"} | Tipo: ${cat?.type ?? "N/A"}'
        );
      }

      // --- Receitas ---
      final incomeEntities = await incomeRepository.getIncomes(event.userId);
      final safeIncomes = safeConvert<Income>(incomeEntities, (e) => Income.fromEntity(e));

      print('✅ Receitas recebidas: ${safeIncomes.length}');
      for (var inc in safeIncomes) {
        final key = inc.categoryId.toString().trim();
        final cat = categoryMap[key];
        print(
          '💰 Income | ID: ${inc.id} | Valor: ${inc.amount} | '
          'categoryId raw: ${inc.categoryId} | lookupKey: "$key" | '
          'Categoria: ${cat?.name ?? "Desconhecida"} | Tipo: ${cat?.type ?? "N/A"}'
        );
      }

      emit(GetFinancialDataSuccess(
        expenses: safeExpenses,
        income: safeIncomes,
        categoryMap: categoryMap,
      ));
    } catch (e, st) {
      print('❌ Erro ao buscar dados financeiros: $e\n$st');
      emit(GetFinancialDataFailure('Não foi possível carregar dados financeiros'));
    }
  }
}
