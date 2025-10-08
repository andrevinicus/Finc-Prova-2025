import 'package:bloc/bloc.dart';
import 'package:expense_repository/expense_repository.dart';
import 'package:finc/perfils/userBloc/user_event.dart';
import 'package:finc/perfils/userBloc/user_state.dart';
import 'package:firebase_auth/firebase_auth.dart';



class UserBloc extends Bloc<UserEvent, UserState> {
  final FirebaseUserRepo _userRepo;

  UserBloc(this._userRepo) : super(UserInitial()) {
    on<LoadUser>(_onLoadUser);
    on<UpdateUser>(_onUpdateUser);
  }

  Future<void> _onLoadUser(LoadUser event, Emitter<UserState> emit) async {
    emit(UserLoading());
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        emit(UserUnauthenticated());
        return;
      }

      final userModel = await _userRepo.getUserById(currentUser.uid);
      if (userModel != null) {
        emit(UserLoaded(userModel));
      } else {
        emit(UserError('Usuário não encontrado no Firestore.'));
      }
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> _onUpdateUser(UpdateUser event, Emitter<UserState> emit) async {
    try {
      if (state is! UserLoaded) return;

      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        emit(UserUnauthenticated());
        return;
      }

      final updatedUser = event.user.copyWith(uid: currentUser.uid);

      await _userRepo.updateUser(updatedUser);
      emit(UserLoaded(updatedUser));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }
}
