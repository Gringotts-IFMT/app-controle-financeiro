import 'package:cloud_firestore/cloud_firestore.dart';
import '../enums/tipo_transacao.dart';
import 'package:flutter/material.dart';

class FinancialTransaction {
  final String id;
  final double value;
  final String description;
  final String category;
  final DateTime date;
  final bool isExpense;
  final TipoTransacao tipo;
  

  FinancialTransaction({
    required this.id,
    required this.value,
    required this.description,
    required this.category,
    required this.date,
    required this.isExpense,
    required this.tipo,
    
  });

  Map<String, dynamic> toMap() {
    return {
      'value': value,
      'description': description,
      'category': category,
      'date': Timestamp.fromDate(date),
      'isExpense': isExpense,
      'tipo': tipo.nome,
    };
  }

  factory FinancialTransaction.fromMap(Map<String, dynamic> map, String id) {
    return FinancialTransaction(
      id: id,
      value: (map['value'] as num)
          .toDouble(), // Garante compatibilidade com Firestore
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      tipo: TipoTransacao.fromString(map['tipo'] ?? 'Despesa'),
      date: (map['date'] as Timestamp).toDate(),
      isExpense: map['isExpense'] ?? true,
     
    );
  }

  FinancialTransaction copyWith({
    String? id,
    double? value,
    String? description,
    String? category,
    DateTime? date,
    bool? isExpense,
    TipoTransacao? tipo,
  }) {
    return FinancialTransaction(
      id: id ?? this.id,
      value: value ?? this.value,
      description: description ?? this.description,
      category: category ?? this.category,
      date: date ?? this.date,
      isExpense: isExpense ?? this.isExpense,
      tipo: tipo ?? this.tipo,
    
    );
  }
}