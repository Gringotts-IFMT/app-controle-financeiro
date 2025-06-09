import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../enums/tipo_transacao.dart';

class TransacaoProvider with ChangeNotifier {
  List<FinancialTransaction> _transacoes = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<FinancialTransaction> get transacoes => _transacoes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Filtrar por tipo - adaptado para seu modelo
  List<FinancialTransaction> getTransacoesPorTipo(TipoTransacao tipo) {
    return _transacoes.where((t) => _getTipoFromTransaction(t) == tipo).toList();
  }

  // Converter seu modelo para o enum
  TipoTransacao _getTipoFromTransaction(FinancialTransaction transaction) {
    // Assumindo que seu modelo tem uma forma de identificar receitas/despesas
    // Você pode ajustar esta lógica conforme seu modelo
    if (transaction.value > 0) {
      return TipoTransacao.receita; // ou baseado em algum campo específico
    } else {
      return TipoTransacao.despesa;
    }
  }

  // Receitas e despesas
  List<FinancialTransaction> get receitas => getTransacoesPorTipo(TipoTransacao.receita);
  List<FinancialTransaction> get despesas => getTransacoesPorTipo(TipoTransacao.despesa);

  // Calcular saldo total
  double get saldoTotal {
    double totalReceitas = receitas.fold(0, (sum, t) => sum + t.value.abs());
    double totalDespesas = despesas.fold(0, (sum, t) => sum + t.value.abs());
    return totalReceitas - totalDespesas;
  }

  // Total por tipo
  double getTotalPorTipo(TipoTransacao tipo) {
    return getTransacoesPorTipo(tipo).fold(0, (sum, t) => sum + t.value.abs());
  }

  // Carregar transações (método que você já deve ter)
  Future<void> carregarTransacoes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Aqui você carrega do seu Firebase ou banco
      // Por enquanto, vou deixar uma simulação
      await Future.delayed(Duration(milliseconds: 500));
      
      // Adicione sua lógica de carregamento aqui
      // _transacoes = await seuServicoDeTransacoes.carregarTodas();
      
    } catch (e) {
      _error = 'Erro ao carregar transações: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Adicionar transação - usando seu modelo
  Future<void> adicionarTransacao(FinancialTransaction transacao) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simular delay (substitua pela sua lógica de salvamento)
      await Future.delayed(Duration(milliseconds: 500));
      
      _transacoes.add(transacao);
      _transacoes.sort((a, b) => b.date.compareTo(a.date)); // Mais recente primeiro
      
    } catch (e) {
      _error = 'Erro ao adicionar transação: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Remover transação
  Future<void> removerTransacao(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(Duration(milliseconds: 500));
      _transacoes.removeWhere((t) => t.id == id);
    } catch (e) {
      _error = 'Erro ao remover: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
