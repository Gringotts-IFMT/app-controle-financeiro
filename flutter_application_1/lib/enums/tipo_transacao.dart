// lib/enums/tipo_transacao.dart
import 'package:flutter/material.dart'; // Importa Material para Colors e IconData

enum TipoTransacao {
  receita,
  despesa,
}

extension TipoTransacaoExtension on TipoTransacao {
  String get name { // <-- Este getter 'name' é o que 'tipo.name' usa
    switch (this) {
      case TipoTransacao.receita:
        return 'receita';
      case TipoTransacao.despesa:
        return 'despesa';
    }
  }

  // Descrição amigável para a UI
  String get descricao {
    switch (this) {
      case TipoTransacao.receita:
        return 'Receita';
      case TipoTransacao.despesa:
        return 'Despesa';
    }
  }

  // <--- ADICIONADO: Getter para ícone (Emoji String)
  String get icone {
    switch (this) {
      case TipoTransacao.receita:
        return '💰'; // Exemplo de emoji para receita
      case TipoTransacao.despesa:
        return '💸'; // Exemplo de emoji para despesa
    }
  }

  // <--- ADICIONADO: Getter para cor
  Color get cor {
    switch (this) {
      case TipoTransacao.receita:
        return Colors.green;
      case TipoTransacao.despesa:
        return Colors.red;
    }
  }

  // Factory para criar o enum a partir de uma String (usado em fromMap)
  static TipoTransacao fromString(String typeString) {
    switch (typeString.toLowerCase()) {
      case 'receita':
        return TipoTransacao.receita;
      case 'despesa':
        return TipoTransacao.despesa;
      default:
        return TipoTransacao.despesa; // Padrão
    }
  }
}