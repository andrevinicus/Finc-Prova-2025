import 'package:cloud_firestore/cloud_firestore.dart';

class AnaliseLancamento {
  final String id; // ID do documento no Firestore
  final String userId;
  final String categoria;
  final String chatId;
  final DateTime data;
  final String detalhes;
  final String categoryId;
  final String estabelecimento;
  final String tipo; // "despesa" ou "receita"
  final double valorTotal;
  bool expanded;
  bool notificar; // Novo campo para notificações

  AnaliseLancamento({
    required this.id,
    required this.userId,
    required this.categoria,
    required this.categoryId,
    required this.chatId,
    required this.data,
    required this.detalhes,
    required this.estabelecimento,
    required this.tipo,
    required this.valorTotal,
    this.expanded = false,
    this.notificar = false, // default false
  });

  /// Converte para Map para salvar no Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'categoria': categoria,
      'categoryId': categoryId,
      'chatid': chatId,
      'data': Timestamp.fromDate(data),
      'detalhes': detalhes,
      'estabelecimento': estabelecimento,
      'tipo': tipo,
      'valorTotal': valorTotal,
      'notificar': notificar, // adiciona no Firestore
    };
  }

  /// Cria a instância a partir de Map do Firestore
  factory AnaliseLancamento.fromMap(Map<String, dynamic> map, String documentId) {
    return AnaliseLancamento(
      id: documentId,
      userId: map['userId'] ?? '',
      categoria: map['categoria'] ?? '',
      categoryId: map['categoryId']?.toString() ?? '',
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
      notificar: map['notificar'] ?? false, // pega do Firestore
    );
  }

  /// copyWith atualizado
  AnaliseLancamento copyWith({
    String? categoria,
    String? categoryId,
    String? chatId,
    DateTime? data,
    String? detalhes,
    String? estabelecimento,
    String? tipo,
    double? valorTotal,
    bool? expanded,
    bool? notificar, // Novo campo para copyWith
  }) {
    return AnaliseLancamento(
      id: id,
      userId: userId,
      categoria: categoria ?? this.categoria,
      categoryId: categoryId ?? this.categoryId,
      chatId: chatId ?? this.chatId,
      data: data ?? this.data,
      detalhes: detalhes ?? this.detalhes,
      estabelecimento: estabelecimento ?? this.estabelecimento,
      tipo: tipo ?? this.tipo,
      valorTotal: valorTotal ?? this.valorTotal,
      expanded: expanded ?? this.expanded,
      notificar: notificar ?? this.notificar,
    );
  }
}
