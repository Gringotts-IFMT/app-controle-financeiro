import 'package:cloud_firestore/cloud_firestore.dart';

class FinancialTransaction {
  final String id;
  final double value;
  final String description;
  final String category;
  final DateTime date;
  final bool isExpense;

  FinancialTransaction({
    required this.id,
    required this.value,
    required this.description,
    required this.category,
    required this.date,
    required this.isExpense,
  });

  Map<String, dynamic> toMap() {
    return {
      'value': value,
      'description': description,
      'category': category,
      'date': Timestamp.fromDate(date),
      'isExpense': isExpense,
    };
  }

  factory FinancialTransaction.fromMap(Map<String, dynamic> map, String id) {
    return FinancialTransaction(
      id: id,
      value: map['value'],
      description: map['description'],
      category: map['category'],
      date: (map['date'] as Timestamp).toDate(),
      isExpense: map['isExpense'],
    );
  }
}
