import 'package:equatable/equatable.dart';
import 'package:expense_repository/expense_repository.dart';


abstract class AnaliseLancamentoState extends Equatable {
  const AnaliseLancamentoState();

  @override
  List<Object?> get props => [];
}

class AnaliseLancamentoInitial extends AnaliseLancamentoState {}

class AnaliseLancamentoLoading extends AnaliseLancamentoState {}

class AnaliseLancamentoLoaded extends AnaliseLancamentoState {
  final List<AnaliseLancamento> lancamentos;

  const AnaliseLancamentoLoaded(this.lancamentos);

  @override
  List<Object?> get props => [lancamentos];
}

class AnaliseLancamentoError extends AnaliseLancamentoState {
  final String message;

  const AnaliseLancamentoError(this.message);

  @override
  List<Object?> get props => [message];
}

class AnalisePendenciasState extends AnaliseLancamentoState {
  final bool hasPendencias;

  const AnalisePendenciasState(this.hasPendencias);

  @override
  List<Object?> get props => [hasPendencias];
}
