enum TipoRelatorio {
  diario,
  semanal,
  mensal,
  anual,
  personalizado,
}

extension TipoRelatorioExtension on TipoRelatorio {

  String get nome {
    return this.toString().split('.').last;
  }

  String get descricao {
    switch (this) {
      case TipoRelatorio.diario:
        return 'Diário';
      case TipoRelatorio.semanal:
        return 'Semanal';
      case TipoRelatorio.mensal:
        return 'Mensal';
      case TipoRelatorio.anual:
        return 'Anual';
      case TipoRelatorio.personalizado:
        return 'Personalizado';
    }
  }

  static TipoRelatorio fromString( String typeString){
    switch (typeString.toLowerCase()){
      case 'diario':
        return TipoRelatorio.diario;
      case 'semanal':
        return TipoRelatorio.semanal;
      case 'mensal':
        return TipoRelatorio.mensal;
      case 'anual':
        return TipoRelatorio.anual;
      case 'personalizado':
        return TipoRelatorio.personalizado;
      default:
        throw ArgumentError('Tipo de relatório desconhecido: $typeString');
    }
  }
}