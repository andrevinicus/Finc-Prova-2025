import 'package:cloud_firestore/cloud_firestore.dart';

class GoalTransaction {
  final String id;
  final String goalId;
  final double amount;
  final DateTime date;
  final String? description;

  GoalTransaction({
    required this.id,
    required this.goalId,
    required this.amount,
    required this.date,
    this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'goalId': goalId,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'description': description,
    };
  }

  factory GoalTransaction.fromMap(Map<String, dynamic> map) {
    return GoalTransaction(
      id: map['id'],
      goalId: map['goalId'],
      amount: (map['amount'] as num).toDouble(),
      date: (map['date'] as Timestamp).toDate(),
      description: map['description'],
    );
  }
}
