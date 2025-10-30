import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ---- EVENT ----
abstract class UserTokenEvent extends Equatable {
  const UserTokenEvent();
  @override
  List<Object?> get props => [];
}

class SaveUserToken extends UserTokenEvent {
  final String userId;
  final String token;

  const SaveUserToken({required this.userId, required this.token});

  @override
  List<Object?> get props => [userId, token];
}

// ---- STATE ----
abstract class UserTokenState extends Equatable {
  const UserTokenState();
  @override
  List<Object?> get props => [];
}

class UserTokenInitial extends UserTokenState {}
class UserTokenSaving extends UserTokenState {}
class UserTokenSaved extends UserTokenState {}
class UserTokenError extends UserTokenState {
  final String message;
  const UserTokenError(this.message);

  @override
  List<Object?> get props => [message];
}

// ---- BLOC ----
class UserTokenBloc extends Bloc<UserTokenEvent, UserTokenState> {
  final FirebaseFirestore firestore;

  UserTokenBloc(this.firestore) : super(UserTokenInitial()) {
    on<SaveUserToken>(_onSaveUserToken);
  }

  Future<void> _onSaveUserToken(
    SaveUserToken event,
    Emitter<UserTokenState> emit,
  ) async {
    emit(UserTokenSaving());
    try {
      final userRef = firestore.collection('users').doc(event.userId);

      await userRef.set(
        {
          'fcmToken': event.token,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      print('✅ FCM token salvo para usuário ${event.userId}: ${event.token}');
      emit(UserTokenSaved());
    } catch (e) {
      print('❌ Erro ao salvar FCM token: $e');
      emit(UserTokenError(e.toString()));
    }
  }
}
