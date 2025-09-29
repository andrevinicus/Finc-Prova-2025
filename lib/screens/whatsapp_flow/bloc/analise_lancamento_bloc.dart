import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_repository/expense_repository.dart';
import 'analise_lancamento_event.dart';
import 'analise_lancamento_state.dart';

class AnaliseLancamentoBloc
    extends Bloc<AnaliseLancamentoEvent, AnaliseLancamentoState> {
  final IAnaliseLancamentoRepository repository;

  AnaliseLancamentoBloc({required this.repository})
      : super(AnaliseLancamentoInitial()) {
    on<LoadLancamentos>(_onLoadLancamentos);
    on<AddLancamento>(_onAddLancamento);
    on<UpdateLancamento>(_onUpdateLancamento);
    on<DeleteLancamento>(_onDeleteLancamento);
    on<CheckPendencias>(_onCheckPendencias);
  }

  // -------------------------
  // Carrega e escuta lançamentos usando emit.forEach
  // -------------------------
  Future<void> _onLoadLancamentos(
      LoadLancamentos event, Emitter<AnaliseLancamentoState> emit) async {
    emit(AnaliseLancamentoLoading());
    try {
      await emit.forEach<List<AnaliseLancamento>>(
        repository.streamLancamentos(event.userId),
        onData: (lancamentos) {
          print('[Bloc] Recebido ${lancamentos.length} lançamentos');
          return AnaliseLancamentoLoaded(lancamentos);
        },
        onError: (error, stackTrace) {
          print('[Bloc] Erro na stream: $error');
          return AnaliseLancamentoError(error.toString());
        },
      );
    } catch (e, s) {
      print('[Bloc] Erro ao iniciar stream: $e');
      print(s);
      emit(AnaliseLancamentoError(e.toString()));
    }
  }

  // -------------------------
  // Adiciona um lançamento
  // -------------------------
  Future<void> _onAddLancamento(
      AddLancamento event, Emitter<AnaliseLancamentoState> emit) async {
    try {
      await repository.createLancamento(event.lancamento);
      print('[Bloc] Lancamento adicionado: ${event.lancamento.id}');
      // A stream já atualiza automaticamente, não precisa reload
    } catch (e, s) {
      print('[Bloc] Erro ao adicionar lançamento: $e');
      print(s);
      emit(AnaliseLancamentoError(e.toString()));
    }
  }

  // -------------------------
  // Atualiza um lançamento
  // -------------------------
  Future<void> _onUpdateLancamento(
      UpdateLancamento event, Emitter<AnaliseLancamentoState> emit) async {
    try {
      await repository.updateLancamento(event.lancamento);
      print('[Bloc] Lancamento atualizado: ${event.lancamento.id}');
    } catch (e, s) {
      print('[Bloc] Erro ao atualizar lançamento: $e');
      print(s);
      emit(AnaliseLancamentoError(e.toString()));
    }
  }

  // -------------------------
  // Deleta um lançamento
  // -------------------------
  Future<void> _onDeleteLancamento(
      DeleteLancamento event, Emitter<AnaliseLancamentoState> emit) async {
    try {
      await repository.deleteLancamento(event.lancamentoId);
      print('[Bloc] Lancamento deletado: ${event.lancamentoId}');
    } catch (e, s) {
      print('[Bloc] Erro ao deletar lançamento: $e');
      print(s);
      emit(AnaliseLancamentoError(e.toString()));
    }
  }

  // -------------------------
  // Checa se há pendências
  // -------------------------
  Future<void> _onCheckPendencias(
      CheckPendencias event, Emitter<AnaliseLancamentoState> emit) async {
    try {
      final hasPendencias = await repository.hasPendencias(event.userId);
      print('[Bloc] Pendências encontradas: $hasPendencias');
      emit(AnalisePendenciasState(hasPendencias));
    } catch (e, s) {
      print('[Bloc] Erro ao checar pendências: $e');
      print(s);
      emit(AnaliseLancamentoError(e.toString()));
    }
  }
}
