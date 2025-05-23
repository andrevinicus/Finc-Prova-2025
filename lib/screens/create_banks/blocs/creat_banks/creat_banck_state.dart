import 'package:equatable/equatable.dart';

abstract class AddBankState extends Equatable {
  const AddBankState();

  @override
  List<Object> get props => [];
}

class AddBankInitial extends AddBankState {}

class AddBankLoading extends AddBankState {}

class AddBankSuccess extends AddBankState {}

class AddBankFailure extends AddBankState {
  final String message;

  const AddBankFailure(this.message);

  @override
  List<Object> get props => [message];
}