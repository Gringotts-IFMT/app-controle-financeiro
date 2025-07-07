import 'package:cloud_firestore/cloud_firestore.dart'; // Para Timestamp
import '../enums/tipo_relatorio.dart'; // Importa o enum TipoRelatorio

class Relatorio {
  // Dados básicos do relatório
  final String? id; // Opcional, se o relatório for salvo no Firestore
  final String userId; // ID do usuário a quem este relatório pertence
  final TipoRelatorio tipoRelatorio; // Tipo do relatório (Mensal, Anual, etc.)
  final DateTime dataInicio; // Data de início do período do relatório
  final DateTime dataFim; // Data de fim do período do relatório
  final DateTime dataGeracao; // Data em que o relatório foi gerado

  // Resumos financeiros
  final double totalReceitas;
  final double totalDespesas;
  final double saldoFinal;

  // Dados para gráficos (simples, podem ser expandidos)
  final Map<String, double>
      gastosPorCategoria; // Ex: {'Alimentação': 150.0, 'Transporte': 80.0}
  // Para evolução de saldo, você pode ter uma lista de Maps ou objetos mais complexos
  // Ex: [{'date': DateTime, 'saldo': double}, ...]
  final List<Map<String, dynamic>> evolucaoSaldoPorPeriodo;

  Relatorio({
    this.id,
    required this.userId,
    required this.tipoRelatorio,
    required this.dataInicio,
    required this.dataFim,
    DateTime? dataGeracao,
    required this.totalReceitas,
    required this.totalDespesas,
    required this.saldoFinal,
    this.gastosPorCategoria = const {}, // Valor padrão
    this.evolucaoSaldoPorPeriodo = const [], // Valor padrão
  }) : dataGeracao = dataGeracao ?? DateTime.now();

  // Construtor de fábrica para criar de um Map (Firestore), se você decidir salvar relatórios
  factory Relatorio.fromMap(Map<String, dynamic> map, {String? id}) {
    return Relatorio(
      id: id ?? map['id'],
      userId: map['userId'] ?? '',
      tipoRelatorio:
          TipoRelatorioExtension.fromString(map['tipoRelatorio'] ?? 'mensal'),
      dataInicio: (map['dataInicio'] as Timestamp?)?.toDate() ?? DateTime.now(),
      dataFim: (map['dataFim'] as Timestamp?)?.toDate() ?? DateTime.now(),
      dataGeracao:
          (map['dataGeracao'] as Timestamp?)?.toDate() ?? DateTime.now(),
      totalReceitas: (map['totalReceitas'] as num?)?.toDouble() ?? 0.0,
      totalDespesas: (map['totalDespesas'] as num?)?.toDouble() ?? 0.0,
      saldoFinal: (map['saldoFinal'] as num?)?.toDouble() ?? 0.0,
      // Precisa de lógica para deserializar Map e List de Maps
      gastosPorCategoria:
          Map<String, double>.from(map['gastosPorCategoria'] ?? {}),
      evolucaoSaldoPorPeriodo:
          List<Map<String, dynamic>>.from(map['evolucaoSaldoPorPeriodo'] ?? []),
    );
  }

  // Método para converter para Map (para Firestore), se você decidir salvar relatórios
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'tipoRelatorio': tipoRelatorio.name, // Salva o nome do enum
      'dataInicio': Timestamp.fromDate(dataInicio),
      'dataFim': Timestamp.fromDate(dataFim),
      'dataGeracao': Timestamp.fromDate(dataGeracao),
      'totalReceitas': totalReceitas,
      'totalDespesas': totalDespesas,
      'saldoFinal': saldoFinal,
      'gastosPorCategoria': gastosPorCategoria,
      'evolucaoSaldoPorPeriodo': evolucaoSaldoPorPeriodo,
    };
  }

  // Método copyWith para facilitar a criação de cópias modificadas
  Relatorio copyWith({
    String? id,
    String? userId,
    TipoRelatorio? tipoRelatorio,
    DateTime? dataInicio,
    DateTime? dataFim,
    DateTime? dataGeracao,
    double? totalReceitas,
    double? totalDespesas,
    double? saldoFinal,
    Map<String, double>? gastosPorCategoria,
    List<Map<String, dynamic>>? evolucaoSaldoPorPeriodo,
  }) {
    return Relatorio(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      tipoRelatorio: tipoRelatorio ?? this.tipoRelatorio,
      dataInicio: dataInicio ?? this.dataInicio,
      dataFim: dataFim ?? this.dataFim,
      dataGeracao: dataGeracao ?? this.dataGeracao,
      totalReceitas: totalReceitas ?? this.totalReceitas,
      totalDespesas: totalDespesas ?? this.totalDespesas,
      saldoFinal: saldoFinal ?? this.saldoFinal,
      gastosPorCategoria: gastosPorCategoria ?? this.gastosPorCategoria,
      evolucaoSaldoPorPeriodo:
          evolucaoSaldoPorPeriodo ?? this.evolucaoSaldoPorPeriodo,
    );
  }

  @override
  String toString() {
    return 'Relatorio{userId: $userId, tipo: ${tipoRelatorio.descricao}, inicio: $dataInicio, fim: $dataFim, receitas: $totalReceitas, despesas: $totalDespesas, saldo: $saldoFinal}';
  }
}
