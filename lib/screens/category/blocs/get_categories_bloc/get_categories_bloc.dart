import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:expense_repository/expense_repository.dart';

part 'get_categories_event.dart';
part 'get_categories_state.dart';

class GetCategoriesBloc extends Bloc<GetCategoriesEvent, GetCategoriesState> {
  final CategoryRepository categoryRepository;

  GetCategoriesBloc({required this.categoryRepository}) : super(GetCategoriesInitial()) {
    on<GetCategories>((event, emit) async {
      emit(GetCategoriesLoading());

      print('➡️ GetCategories event recebido para userId: ${event.userId}');

      try {
        final categories = await categoryRepository.getCategories(event.userId);
        print('✅ Categorias recebidas do repositório: ${categories.length}');

        for (var category in categories) {
          print(
            '➡️ Categoria: ${category.name}, '
            'ID: ${category.categoryId}, '
            'Tipo: ${category.type}, '
            'Criada em: ${category.createdAt}, '
            'Cor: ${category.color}, '
            'Usuário: ${category.userId}',
          );
        }

        emit(GetCategoriesSuccess(categories));
      } catch (e, st) {
        print('❌ Erro ao buscar categorias: $e');
        print('StackTrace: $st');
        emit(GetCategoriesFailure('Não foi possível carregar categorias'));
      }
    });
  }
}
