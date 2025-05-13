import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:expense_repository/expense_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'create_category_event.dart';
part 'create_category_state.dart';

class CreateCategoryBloc extends Bloc<CreateCategoryEvent, CreateCategoryState> {
  final ExpenseRepository expenseRepository;

  // Construtor com parâmetro nomeado
  CreateCategoryBloc({required this.expenseRepository}) : super(CreateCategoryInitial()) {
    on<CreateCategory>((event, emit) async {
      emit(CreateCategoryLoading());
      try {
        final userId = FirebaseAuth.instance.currentUser?.uid;
        if (userId == null) throw Exception("Usuário não autenticado");

        // Aqui você garante que o tipo seja 'expense' ou 'income', se não for informado
        final categoryWithUser = event.category.copyWith(
          userId: userId,
          type: event.category.type.isEmpty ? 'expense' : event.category.type, // Valor padrão para type
        );

        await expenseRepository.createCategory(categoryWithUser);
        emit(CreateCategorySuccess());
      } catch (e) {
        emit(CreateCategoryFailure());
      }
    });
  }
}