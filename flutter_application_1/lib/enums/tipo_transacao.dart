import 'package:flutter/material.dart';

enum TipoTransacao {
  receita('Receita'),
  despesa('Despesa');

  // Construtor correto para enums com valores associados
  const TipoTransacao(this.nome);

  final String nome;

  // Método de conversão de string para enum
  static TipoTransacao fromString(String value) {
    return TipoTransacao.values.firstWhere(
      (tipo) => tipo.nome.toLowerCase() == value.toLowerCase(),
      orElse: () => TipoTransacao.despesa,
    );
  }

  // Retorna ícone como string
  String get icone {
    switch (this) {
      case TipoTransacao.receita:
        return '↗️';
      case TipoTransacao.despesa:
        return '↘️';
    }
  }

  // Retorna cor associada
  Color get cor {
    switch (this) {
      case TipoTransacao.receita:
        return Colors.green;
      case TipoTransacao.despesa:
        return Colors.red;
    }
  }
}
