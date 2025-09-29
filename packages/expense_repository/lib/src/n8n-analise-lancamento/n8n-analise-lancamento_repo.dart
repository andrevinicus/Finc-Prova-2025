import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_repository/expense_repository.dart';
import 'package:expense_repository/src/n8n-analise-lancamento/n8n-analise-lancamento.dart';

class FirebaseAnaliseLancamentoRepository implements IAnaliseLancamentoRepository {
  final CollectionReference<Map<String, dynamic>> lancamentosCollection =
      FirebaseFirestore.instance.collection('n8n-analise-lançamento');

  // -------------------------
  // Stream de lançamentos do usuário
  // -------------------------
  Stream<List<AnaliseLancamento>> streamLancamentos(String userId) {
    return lancamentosCollection
        .where('idApp', isEqualTo: userId) // <-- filtra pelo idApp do usuário
        .orderBy('data', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AnaliseLancamento.fromMap(doc.data(), doc.id))
            .toList());
  }

  // -------------------------
  // Consulta pontual
  // -------------------------
  @override
  Future<List<AnaliseLancamento>> getLancamentos(String userId) async {
    try {
      log('🔹 Buscando lançamentos para userId: $userId');

      final snapshot = await lancamentosCollection
          .where('idApp', isEqualTo: userId)
          .orderBy('data', descending: true)
          .get();

      log('🔹 Documentos encontrados: ${snapshot.docs.length}');

      final lancamentos = snapshot.docs
          .map((doc) => AnaliseLancamento.fromMap(doc.data(), doc.id))
          .toList();

      log('✅ ${lancamentos.length} lançamentos carregados para o userId: $userId');
      return lancamentos;
    } catch (e, st) {
      log('❌ Erro ao buscar lançamentos', error: e, stackTrace: st);
      rethrow;
    }
  }

  // -------------------------
  // Create / Update / Delete
  // -------------------------
  @override
  Future<void> createLancamento(AnaliseLancamento lancamento) async {
    try {
      await lancamentosCollection.doc(lancamento.id).set(lancamento.toMap());
      log('✅ Lançamento criado: ${lancamento.detalhes} (ID: ${lancamento.id})');
    } catch (e, st) {
      log('❌ Erro ao criar lançamento', error: e, stackTrace: st);
      throw Exception('Erro ao criar lançamento');
    }
  }

  @override
  Future<void> updateLancamento(AnaliseLancamento lancamento) async {
    try {
      await lancamentosCollection.doc(lancamento.id).update(lancamento.toMap());
      log('✅ Lançamento atualizado: ${lancamento.detalhes} (ID: ${lancamento.id})');
    } catch (e, st) {
      log('❌ Erro ao atualizar lançamento', error: e, stackTrace: st);
      throw Exception('Erro ao atualizar lançamento');
    }
  }

  @override
  Future<void> deleteLancamento(String lancamentoId) async {
    try {
      await lancamentosCollection.doc(lancamentoId).delete();
      log('✅ Lançamento deletado (ID: $lancamentoId)');
    } catch (e, st) {
      log('❌ Erro ao deletar lançamento', error: e, stackTrace: st);
      throw Exception('Erro ao deletar lançamento');
    }
  }

  // -------------------------
  // Checa pendências
  // -------------------------
  @override
  Future<bool> hasPendencias(String userId) async {
    try {
      final snapshot = await lancamentosCollection
          .where('idApp', isEqualTo: userId)
          .where('status', isEqualTo: 'pendente')
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e, st) {
      log('❌ Erro ao verificar pendências', error: e, stackTrace: st);
      throw Exception('Erro ao verificar pendências');
    }
  }
}
