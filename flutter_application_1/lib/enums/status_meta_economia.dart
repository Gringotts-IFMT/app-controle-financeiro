enum StatusMetaEconomia {
  ativa('Ativa'),
  pausada('Pausada'),
  concluida('Concluída'),
  cancelada('Cancelada');

  const StatusMetaEconomia(this.descricao);
  
  final String descricao;

  @override
  String toString() => descricao;

  // Método para converter string em enum
  static StatusMetaEconomia fromString(String status) {
    switch (status.toLowerCase()) {
      case 'ativa':
        return StatusMetaEconomia.ativa;
      case 'pausada':
        return StatusMetaEconomia.pausada;
      case 'concluida':
      case 'concluída':
        return StatusMetaEconomia.concluida;
      case 'cancelada':
        return StatusMetaEconomia.cancelada;
      default:
        return StatusMetaEconomia.ativa;
    }
  }

  // Método para obter todas as opções como lista de strings
  static List<String> get opcoes => StatusMetaEconomia.values
      .map((status) => status.descricao)
      .toList();
}