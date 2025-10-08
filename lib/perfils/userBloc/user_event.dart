

import 'package:equatable/equatable.dart';
import 'package:expense_repository/expense_repository.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object?> get props => [];
}

class LoadUser extends UserEvent {}

class UpdateUser extends UserEvent {
  final UserModel user;

  const UpdateUser(this.user);

  @override
  List<Object?> get props => [user];
}
