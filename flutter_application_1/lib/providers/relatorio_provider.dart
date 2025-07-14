import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Para obter o userId
import '../services/database_service.dart'; // Para buscar transações
import '../Models/relatorio.dart'; // O modelo de relatório
import '../Models/transaction.dart'; // O modelo de transação
import '../enums/tipo_relatorio.dart'; // O enum TipoRelatorio
import '../enums/tipo_transacao.dart'; // O enum TipoTransacao (para filtrar receitas/despesas)

class RelatorioProvider with ChangeNotifier {
  void limparDados() {
    _relatorioAtual = null;
    _erro = null;
    _isLoading = false;
    notifyListeners();
  }

  final DatabaseService _databaseService = DatabaseService();

  Relatorio? _relatorioAtual; // O último relatório gerado
  bool _isLoading = false;
  String? _erro;

  Relatorio? get relatorioAtual => _relatorioAtual;
  bool get isLoading => _isLoading;
  String? get erro => _erro;

  // Getter para o ID do usuário atual
  String? get currentUserId => FirebaseAuth.instance.currentUser?.uid;

  // Método principal para gerar o relatório
  Future<Relatorio?> gerarRelatorio(
    TipoRelatorio tipo, {
    DateTime? dataInicioCustomizada,
    DateTime? dataFimCustomizada,
  }) async {
    _setLoading(true);
    _erro = null;

    final userId = currentUserId;
    if (userId == null) {
      _erro = 'Usuário não logado para gerar relatório.';
      _setLoading(false);
      return null;
    }

    try {
      DateTime inicioPeriodo;
      DateTime fimPeriodo;

      // Definir o período do relatório com base no tipo
      if (tipo == TipoRelatorio.personalizado) {
        if (dataInicioCustomizada == null || dataFimCustomizada == null) {
          throw Exception(
              'Para relatório personalizado, datas de início e fim são obrigatórias.');
        }
        inicioPeriodo = dataInicioCustomizada;
        fimPeriodo = dataFimCustomizada;
      } else {
        // Lógica para definir período Diário, Semanal, Mensal, Anual
        final now = DateTime.now();
        switch (tipo) {
          case TipoRelatorio.diario:
            inicioPeriodo = DateTime(now.year, now.month, now.day);
            fimPeriodo = DateTime(
                now.year, now.month, now.day, 23, 59, 59); // Fim do dia
            break;
          case TipoRelatorio.semanal:
            // Início da semana (domingo)
            inicioPeriodo = now.subtract(
                Duration(days: now.weekday)); // now.weekday: 1 (seg) - 7 (dom)
            inicioPeriodo = DateTime(
                inicioPeriodo.year, inicioPeriodo.month, inicioPeriodo.day);
            // Fim da semana (sábado)
            fimPeriodo = inicioPeriodo.add(const Duration(days: 6));
            fimPeriodo = DateTime(
                fimPeriodo.year, fimPeriodo.month, fimPeriodo.day, 23, 59, 59);
            break;
          case TipoRelatorio.mensal:
            inicioPeriodo = DateTime(now.year, now.month, 1);
            fimPeriodo = DateTime(
                now.year, now.month + 1, 0, 23, 59, 59); // Último dia do mês
            break;
          case TipoRelatorio.anual:
            inicioPeriodo = DateTime(now.year, 1, 1);
            fimPeriodo =
                DateTime(now.year, 12, 31, 23, 59, 59); // Último dia do ano
            break;
          case TipoRelatorio.personalizado: // Já tratado acima
            inicioPeriodo = DateTime.now(); // Fallback, não deve acontecer
            fimPeriodo = DateTime.now(); // Fallback, não deve acontecer
            break;
        }
      }

      // Buscar as transações do período via DatabaseService
      final List<FinancialTransaction> transacoesNoPeriodo =
          await _databaseService.getTransactionsByDateRange(
              userId,
              inicioPeriodo,
              fimPeriodo); // <--- Novo método necessário no DatabaseService

      // Processar os dados das transações
      double totalReceitas = 0.0;
      double totalDespesas = 0.0;
      Map<String, double> gastosPorCategoria = {};
      Map<String, double> receitasPorCategoria = {};
      List<Map<String, dynamic>> evolucaoSaldoPorPeriodo = [];

      // Calcular totais, gastos por categoria e receitas por categoria
      for (var transacao in transacoesNoPeriodo) {
        if (transacao.tipo == TipoTransacao.receita) {
          totalReceitas += transacao.value.abs();
          receitasPorCategoria.update(
            transacao.category,
            (value) => value + transacao.value.abs(),
            ifAbsent: () => transacao.value.abs(),
          );
        } else {
          totalDespesas += transacao.value.abs();
          gastosPorCategoria.update(
            transacao.category,
            (value) => value + transacao.value.abs(),
            ifAbsent: () => transacao.value.abs(),
          );
        }
      }

      final saldoFinal = totalReceitas - totalDespesas;

      // Para gráficos de linha, você precisaria agrupar por dia/semana/mês e calcular o saldo cumulativo
      // Ex: List<Map<String, dynamic>> evolucaoSaldo = _calcularEvolucaoSaldo(transacoesNoPeriodo, inicioPeriodo, fimPeriodo, tipo);

      // Criar o objeto Relatorio
      _relatorioAtual = Relatorio(
        userId: userId,
        tipoRelatorio: tipo,
        dataInicio: inicioPeriodo,
        dataFim: fimPeriodo,
        totalReceitas: totalReceitas,
        totalDespesas: totalDespesas,
        saldoFinal: saldoFinal,
        gastosPorCategoria: gastosPorCategoria,
        receitasPorCategoria: receitasPorCategoria,
        evolucaoSaldoPorPeriodo: evolucaoSaldoPorPeriodo, // Por enquanto, vazio
      );
      _erro = null;
      return _relatorioAtual;
    } catch (e) {
      _erro = 'Erro ao gerar relatório: $e';
      print('RelatorioProvider: Erro ao gerar relatório: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Método auxiliar para setar loading e notificar
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Limpar erro
  void limparErro() {
    _erro = null;
    notifyListeners();
  }
}
