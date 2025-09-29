import 'package:cloud_firestore/cloud_firestore.dart';

class AnaliseLancamento {
  final String id; // ID do documento no Firestore
  final String userId; // Ex.: "02bdd078-3877-4301-95ad-b254403fef3b"
  final String categoria;
  final String chatId;
  final DateTime data;
  final String detalhes;
  final String estabelecimento;
  final String tipo; // "despesa" ou "receita"
  final double valorTotal;
   bool expanded;

  AnaliseLancamento({
    required this.id,
    required this.userId,
    required this.categoria,
    required this.chatId,
    required this.data,
    required this.detalhes,
    required this.estabelecimento,
    required this.tipo,
    required this.valorTotal,
    this.expanded = false,
  });

  /// Converte para Map para salvar no Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'categoria': categoria,
      'chatid': chatId,
      'data': Timestamp.fromDate(data),
      'detalhes': detalhes,
      'estabelecimento': estabelecimento,
      'tipo': tipo,
      'valorTotal': valorTotal,
    };
  }

  /// Cria a instância a partir de Map do Firestore
  factory AnaliseLancamento.fromMap(Map<String, dynamic> map, String documentId) {
    return AnaliseLancamento(
      id: documentId,
      userId: map['userId'] ?? '',
      categoria: map['categoria'] ?? '',
      chatId: map['chatid'] ?? '',
      data: map['data'] != null
          ? (map['data'] as Timestamp).toDate()
          : DateTime.now(),
      detalhes: map['detalhes'] ?? '',
      estabelecimento: map['estabelecimento'] ?? '',
      tipo: map['tipo'] ?? '',
      valorTotal: map['valorTotal'] != null
          ? (map['valorTotal'] as num).toDouble()
          : 0.0,
    );
  }
}
