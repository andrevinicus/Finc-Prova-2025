import 'package:equatable/equatable.dart';
import 'package:expense_repository/expense_repository.dart';

abstract class AnaliseLancamentoEvent extends Equatable {
  const AnaliseLancamentoEvent();

  @override
  List<Object?> get props => [];
}

class LoadLancamentos extends AnaliseLancamentoEvent {
  final String userId;

  const LoadLancamentos(this.userId);

  @override
  List<Object?> get props => [userId];
}

class AddLancamento extends AnaliseLancamentoEvent {
  final AnaliseLancamento lancamento;
  final String userId; // ADICIONADO

  const AddLancamento({required this.lancamento, required this.userId});

  @override
  List<Object?> get props => [lancamento, userId];
}

class UpdateLancamento extends AnaliseLancamentoEvent {
  final AnaliseLancamento lancamento;
  final String userId; // ADICIONADO

  const UpdateLancamento({required this.lancamento, required this.userId});

  @override
  List<Object?> get props => [lancamento, userId];
}

class DeleteLancamento extends AnaliseLancamentoEvent {
  final String lancamentoId;
  final String userId; // ADICIONADO

  const DeleteLancamento({required this.lancamentoId, required this.userId});

  @override
  List<Object?> get props => [lancamentoId, userId];
}

class CheckPendencias extends AnaliseLancamentoEvent {
  final String userId;

  const CheckPendencias(this.userId);

  @override
  List<Object?> get props => [userId];
}
