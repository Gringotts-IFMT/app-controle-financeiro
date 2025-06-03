import '../enums/status_meta_economia.dart';

class MetaEconomia {
  final String? id;
  final String titulo;
  final String descricao;
  final double valorMeta;
  final double valorAtual;
  final DateTime dataInicio;
  final DateTime dataFim;
  final StatusMetaEconomia status;
  final String? categoria;
  final DateTime dataCriacao;
  final DateTime dataAtualizacao;

  MetaEconomia({
    this.id,
    required this.titulo,
    required this.descricao,
    required this.valorMeta,
    this.valorAtual = 0.0,
    required this.dataInicio,
    required this.dataFim,
    this.status = StatusMetaEconomia.ativa,
    this.categoria,
    DateTime? dataCriacao,
    DateTime? dataAtualizacao,
  })  : dataCriacao = dataCriacao ?? DateTime.now(),
        dataAtualizacao = dataAtualizacao ?? DateTime.now();

  // Método para calcular porcentagem do progresso
  double get porcentagemProgresso {
    if (valorMeta <= 0) return 0.0;
    double progresso = (valorAtual / valorMeta) * 100;
    return progresso > 100 ? 100.0 : progresso;
  }

  // Método para verificar se a meta foi atingida
  bool get metaAtingida => valorAtual >= valorMeta;

  // Método para calcular valor restante
  double get valorRestante {
    double restante = valorMeta - valorAtual;
    return restante > 0 ? restante : 0.0;
  }

  // Método para verificar se a meta está vencida
  bool get metaVencida => DateTime.now().isAfter(dataFim) && !metaAtingida;

  // Método para calcular dias restantes
  int get diasRestantes {
    if (DateTime.now().isAfter(dataFim)) return 0;
    return dataFim.difference(DateTime.now()).inDays;
  }

  // Método para converter para Map (para banco de dados)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'descricao': descricao,
      'valorMeta': valorMeta,
      'valorAtual': valorAtual,
      'dataInicio': dataInicio.toIso8601String(),
      'dataFim': dataFim.toIso8601String(),
      'status': status.name,
      'categoria': categoria,
      'dataCriacao': dataCriacao.toIso8601String(),
      'dataAtualizacao': dataAtualizacao.toIso8601String(),
    };
  }

  // Método para criar instância a partir de Map
  factory MetaEconomia.fromMap(Map<String, dynamic> map) {
    return MetaEconomia(
      id: map['id'],
      titulo: map['titulo'] ?? '',
      descricao: map['descricao'] ?? '',
      valorMeta: (map['valorMeta'] ?? 0.0).toDouble(),
      valorAtual: (map['valorAtual'] ?? 0.0).toDouble(),
      dataInicio: DateTime.parse(map['dataInicio']),
      dataFim: DateTime.parse(map['dataFim']),
      status: StatusMetaEconomia.fromString(map['status'] ?? 'ativa'),
      categoria: map['categoria'],
      dataCriacao: DateTime.parse(map['dataCriacao']),
      dataAtualizacao: DateTime.parse(map['dataAtualizacao']),
    );
  }

  // Método para criar cópia com modificações
  MetaEconomia copyWith({
    String? id,
    String? titulo,
    String? descricao,
    double? valorMeta,
    double? valorAtual,
    DateTime? dataInicio,
    DateTime? dataFim,
    StatusMetaEconomia? status,
    String? categoria,
    DateTime? dataCriacao,
    DateTime? dataAtualizacao,
  }) {
    return MetaEconomia(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descricao: descricao ?? this.descricao,
      valorMeta: valorMeta ?? this.valorMeta,
      valorAtual: valorAtual ?? this.valorAtual,
      dataInicio: dataInicio ?? this.dataInicio,
      dataFim: dataFim ?? this.dataFim,
      status: status ?? this.status,
      categoria: categoria ?? this.categoria,
      dataCriacao: dataCriacao ?? this.dataCriacao,
      dataAtualizacao: dataAtualizacao ?? DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'MetaEconomia{id: $id, titulo: $titulo, valorMeta: $valorMeta, valorAtual: $valorAtual, status: $status}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MetaEconomia && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  static novaMeta(
      {required String titulo,
      required String descricao,
      required double valorMeta,
      required double valorAtual}) {}

  static novaMeta(
      {required String titulo,
      required String descricao,
      required double valorMeta,
      required double valorAtual}) {}

  static novaMeta(
      {required String titulo,
      required String descricao,
      required double valorMeta,
      required double valorAtual}) {}
}
