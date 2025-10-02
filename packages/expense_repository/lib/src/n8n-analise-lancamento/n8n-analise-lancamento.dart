import 'package:cloud_firestore/cloud_firestore.dart';

class AnaliseLancamento {
  final String id;
  final String userId;
  final String categoria;
  final String categoryId;
  final String chatId;
  final DateTime data;
  final String detalhes;
  final String estabelecimento;
  final String tipo; // "despesa" ou "receita"
  final double valorTotal;
  bool expanded;
  bool notificado;
  bool isPending;

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
    this.notificado = false,
    this.isPending = true,
  });

  /// Conversões seguras para diferentes tipos
  static String safeString(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  static double safeDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static bool safeBool(dynamic value, {bool defaultValue = false}) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final lower = value.toLowerCase();
      return lower == 'true' || lower == '1';
    }
    return defaultValue;
  }

  static DateTime safeDateTime(dynamic value) {
    if (value == null) return DateTime.now();

    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is double) return DateTime.fromMillisecondsSinceEpoch(value.toInt());

    if (value is String) {
      final parsed = DateTime.tryParse(value);
      if (parsed != null) return parsed;

      final millis = int.tryParse(value);
      if (millis != null) return DateTime.fromMillisecondsSinceEpoch(millis);
    }

    return DateTime.now();
  }

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
      'notificado': notificado,
      'isPending': isPending,
    };
  }

  /// Cria instância a partir de Map do Firestore
  factory AnaliseLancamento.fromMap(Map<String, dynamic> map, String documentId) {
    return AnaliseLancamento(
      id: documentId,
      userId: safeString(map['userId']),
      categoria: safeString(map['categoria']),
      categoryId: safeString(map['categoryId']),
      chatId: safeString(map['chatid']),
      data: safeDateTime(map['data']),
      detalhes: safeString(map['detalhes']),
      estabelecimento: safeString(map['estabelecimento']),
      tipo: safeString(map['tipo']),
      valorTotal: safeDouble(map['valorTotal']),
      notificado: safeBool(map['notificado']),
      isPending: safeBool(map['isPending'], defaultValue: true),
    );
  }

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
    bool? notificado,
    bool? isPending,
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
      notificado: notificado ?? this.notificado,
      isPending: isPending ?? this.isPending,
    );
  }
}
