import 'package:cloud_firestore/cloud_firestore.dart';
import '../enums/tipo_transacao.dart';
// import 'package:flutter/material.dart'; // <--- Geralmente não é necessário aqui

class FinancialTransaction {
  final String? id; // ID do documento no Firestore, opcional para novas transações
  final String userId; // <--- ADICIONADO: ID do usuário do Firebase Auth (UID)
  final double value;
  final String description;
  final String category;
  final DateTime date;
  final bool isExpense;
  final TipoTransacao tipo;

FinancialTransaction({
  this.id, // O id pode ser nulo ao criar uma nova transação
  required this.userId, // <--- Agora é obrigatório
  required this.value,
  required this.description,
  required this.category,
  required this.date,
  required this.isExpense,
  required this.tipo,
});

  Map<String, dynamic> toMap() {
    return {
      'userId': userId, // <--- Incluído no toMap
      'value': value,
      'description': description,
      'category': category,
      'date': Timestamp.fromDate(date),
      'isExpense': isExpense,
      'tipo': tipo.name, // <--- Usar .name para o enum (como fizemos no StatusMetaEconomia)
    };
  }

  factory FinancialTransaction.fromMap(Map<String, dynamic> map, String id) {
    return FinancialTransaction(
      id: id,
      userId: map['userId'] ?? '',
      value: (map['value'] as num).toDouble(),
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      // CORREÇÃO AQUI: Use TipoTransacao.values.firstWhere
      tipo: TipoTransacao.values.firstWhere(
        (e) => e.name == (map['tipo'] as String? ?? ''),
        orElse: () => TipoTransacao.despesa, // Padrão se não encontrar o tipo
      ),
      date: (map['date'] as Timestamp).toDate(),
      isExpense: map['isExpense'] ?? true,
    );
  }

  FinancialTransaction copyWith({
    String? id,
    String? userId, // <--- Incluído no copyWith
    double? value,
    String? description,
    String? category,
    DateTime? date,
    bool? isExpense,
    TipoTransacao? tipo,
  }) {
    return FinancialTransaction(
      id: id ?? this.id,
      userId: userId ?? this.userId, // <--- Copiando userId
      value: value ?? this.value,
      description: description ?? this.description,
      category: category ?? this.category,
      date: date ?? this.date,
      isExpense: isExpense ?? this.isExpense,
      tipo: tipo ?? this.tipo,
    );
  }

  @override
  String toString() {
    return 'FinancialTransaction{id: $id, userId: $userId, value: $value, description: $description, category: $category, date: $date, isExpense: $isExpense, tipo: $tipo}';
  }
}