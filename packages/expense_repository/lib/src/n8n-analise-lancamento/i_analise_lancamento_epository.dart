import 'package:expense_repository/src/n8n-analise-lancamento/n8n-analise-lancamento.dart';

abstract class IAnaliseLancamentoRepository {
  /// Cria um novo lançamento
  Future<void> createLancamento(AnaliseLancamento lancamento);

  /// Atualiza um lançamento existente
  Future<void> updateLancamento(AnaliseLancamento lancamento);

  /// Deleta um lançamento pelo ID
  Future<void> deleteLancamento(String lancamentoId);

  /// Retorna todos os lançamentos de um usuário, ordenados pela data
  Future<List<AnaliseLancamento>> getLancamentos(String userId);

  /// Retorna true se houver lançamentos pendentes (ex: para mostrar badge)
  Future<bool> hasPendencias(String userId);

  /// Stream em tempo real de lançamentos do usuário
  Stream<List<AnaliseLancamento>> streamLancamentos(String userId);
}
