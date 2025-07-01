// lib/Models/meta_economia.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../enums/status_meta_economia.dart';
// import 'package:controle_financeiro/Models/usuario.dart'; // Opcional, se precisar referenciar o modelo do Usuario aqui.
// Mas o MetaEconomia só precisa do userId (String)

class MetaEconomia {
  final String? id; // ID do documento no Firestore, opcional para novas metas
  final String userId; // <--- MUITO IMPORTANTE: CAMPO userId ADICIONADO AQUI
  final String titulo;
  final String descricao;
  final double valorMeta;
  final double valorAtual; // Progresso atual da meta
  final DateTime dataInicio;
  final DateTime dataFim;
  final String periodo; // <--- ADICIONADO: 'Mensal', 'Anual', 'Personalizado', etc.
  final StatusMetaEconomia status;
  final String? categoria; // Categoria da meta (pode ser nula se não for por categoria)
  final DateTime dataCriacao;
  final DateTime dataAtualizacao;

  MetaEconomia({
    this.id,
    required this.userId, // <--- MUITO IMPORTANTE: userId AGORA É OBRIGATÓRIO NO CONSTRUTOR
    required this.titulo,
    this.descricao = '', // Descrição opcional, com valor padrão
    required this.valorMeta,
    this.valorAtual = 0.0, // Valor padrão para metas novas
    required this.dataInicio,
    required this.dataFim,
    required this.periodo, // <--- Agora é obrigatório no construtor
    this.status = StatusMetaEconomia.ativa, // Status padrão
    this.categoria, // Categoria opcional
    DateTime? dataCriacao,
    DateTime? dataAtualizacao,
  })  : dataCriacao = dataCriacao ?? DateTime.now(),
        dataAtualizacao = dataAtualizacao ?? DateTime.now();

  // Getters para a lógica de UI/UX
  double get porcentagemProgresso {
    if (valorMeta <= 0) return 0.0;
    double progresso = (valorAtual / valorMeta) * 100;
    return progresso > 100 ? 100.0 : progresso;
  }

  bool get metaAtingida => valorAtual >= valorMeta;

  double get valorRestante {
    double restante = valorMeta - valorAtual;
    return restante > 0 ? restante : 0.0;
  }

  bool get metaVencida => DateTime.now().isAfter(dataFim) && !metaAtingida && status == StatusMetaEconomia.ativa; // Apenas se estiver ativa

  int get diasRestantes {
    if (DateTime.now().isAfter(dataFim)) return 0;
    return dataFim.difference(DateTime.now()).inDays;
  }

  // Método para converter para Map (para Firebase Firestore)
  Map<String, dynamic> toMap() {
    return {
      // O 'id' não é incluído aqui, pois é o ID do documento no Firestore
      'userId': userId, // <--- MUITO IMPORTANTE: userId INCLUÍDO NO toMap
      'titulo': titulo,
      'descricao': descricao,
      'valorMeta': valorMeta,
      'valorAtual': valorAtual,
      'dataInicio': Timestamp.fromDate(dataInicio),
      'dataFim': Timestamp.fromDate(dataFim),
      'periodo': periodo,
      'status': status.name, // Salva o nome do enum como string
      'categoria': categoria,
      'dataCriacao': Timestamp.fromDate(dataCriacao),
      'dataAtualizacao': Timestamp.fromDate(dataAtualizacao),
    };
  }

  // Construtor de fábrica para criar instância a partir de Map (do Firebase Firestore)
  factory MetaEconomia.fromMap(Map<String, dynamic> map, String id) {
    return MetaEconomia(
      id: id, // O ID do documento do Firestore
      userId: map['userId'] ?? '', // <--- MUITO IMPORTANTE: userId LIDO DO MAP
      titulo: map['titulo'] ?? '',
      descricao: map['descricao'] ?? '',
      valorMeta: (map['valorMeta'] as num?)?.toDouble() ?? 0.0,
      valorAtual: (map['valorAtual'] as num?)?.toDouble() ?? 0.0,
      dataInicio: (map['dataInicio'] as Timestamp?)?.toDate() ?? DateTime.now(),
      dataFim: (map['dataFim'] as Timestamp?)?.toDate() ?? DateTime.now(),
      periodo: map['periodo'] ?? 'Mensal',
      status: StatusMetaEconomia.values.firstWhere(
        (e) => e.name == (map['status'] as String? ?? ''),
        orElse: () => StatusMetaEconomia.ativa,
      ),
      categoria: map['categoria'],
      dataCriacao: (map['dataCriacao'] as Timestamp?)?.toDate() ?? DateTime.now(),
      dataAtualizacao: (map['dataAtualizacao'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Método para criar cópia com modificações (útil para atualizações)
  MetaEconomia copyWith({
    String? id,
    String? userId, // <--- MUITO IMPORTANTE: userId INCLUÍDO NO copyWith
    String? titulo,
    String? descricao,
    double? valorMeta,
    double? valorAtual,
    DateTime? dataInicio,
    DateTime? dataFim,
    String? periodo,
    StatusMetaEconomia? status,
    String? categoria,
    DateTime? dataCriacao,
    DateTime? dataAtualizacao,
  }) {
    return MetaEconomia(
      id: id ?? this.id,
      userId: userId ?? this.userId, // <--- MUITO IMPORTANTE: userId COPIADO AQUI
      titulo: titulo ?? this.titulo,
      descricao: descricao ?? this.descricao,
      valorMeta: valorMeta ?? this.valorMeta,
      valorAtual: valorAtual ?? this.valorAtual,
      dataInicio: dataInicio ?? this.dataInicio,
      dataFim: dataFim ?? this.dataFim,
      periodo: periodo ?? this.periodo,
      status: status ?? this.status,
      categoria: categoria ?? this.categoria,
      dataCriacao: dataCriacao ?? this.dataCriacao,
      dataAtualizacao: dataAtualizacao ?? DateTime.now(), // Atualiza para o momento da cópia
    );
  }

  @override
  String toString() {
    return 'MetaEconomia{id: $id, userId: $userId, titulo: $titulo, valorMeta: $valorMeta, valorAtual: $valorAtual, status: $status, periodo: $periodo}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MetaEconomia && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}