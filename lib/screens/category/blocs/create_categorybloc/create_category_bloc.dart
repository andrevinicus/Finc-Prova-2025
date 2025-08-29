import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:expense_repository/expense_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'create_category_event.dart';
part 'create_category_state.dart';

class CreateCategoryBloc extends Bloc<CreateCategoryEvent, CreateCategoryState> {
  final CategoryRepository categoryRepository;

  CreateCategoryBloc({required this.categoryRepository}) : super(CreateCategoryInitial()) {
    on<CreateCategory>((event, emit) async {
      emit(CreateCategoryLoading());

      try {
        final userId = FirebaseAuth.instance.currentUser?.uid;
        if (userId == null) throw Exception("Usuário não autenticado");

        // Garante que o tipo seja 'expense' ou 'income'
        final categoryWithUser = event.category.copyWith(
          userId: userId,
          type: event.category.type.isEmpty ? 'expense' : event.category.type,
        );

        // Criação usando CategoryRepository
        await categoryRepository.createCategory(categoryWithUser);
        emit(CreateCategorySuccess());
        print('✅ Categoria criada com sucesso: ${categoryWithUser.name}');
      } catch (e, st) {
        print('❌ Erro ao criar categoria: $e\n$st');
        emit(CreateCategoryFailure());
      }
    });
  }
}
