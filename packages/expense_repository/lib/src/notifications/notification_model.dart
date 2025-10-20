import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String documentId; // corresponde ao seu documentId
  final String idApp;
  final String tipo;
  final String detalhes;
  final double valorTotal;
  final DateTime dataLancamento;
  final bool visualizado;

  NotificationModel({
    required this.documentId,
    required this.idApp,
    required this.tipo,
    required this.detalhes,
    required this.valorTotal,
    required this.dataLancamento,
    required this.visualizado,
  });

 factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
  final data = doc.data() as Map<String, dynamic>;
  return NotificationModel(
    documentId: doc.id, // ✅ pega direto do Firestore
    idApp: data['idApp'] ?? '',
    tipo: data['tipo'] ?? '',
    detalhes: data['detalhes'] ?? '',
    valorTotal: (data['valorTotal'] ?? 0).toDouble(),
    dataLancamento: (data['dataLancamento'] as Timestamp).toDate(),
    visualizado: data['visualizado'] ?? false,
  );
}

Map<String, dynamic> toFirestore() {
  return {
    'idApp': idApp,
    'tipo': tipo,
    'detalhes': detalhes,
    'valorTotal': valorTotal,
    'dataLancamento': Timestamp.fromDate(dataLancamento),
    'visualizado': visualizado,
  };
}
}
