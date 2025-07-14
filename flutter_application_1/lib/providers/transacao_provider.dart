// lib/providers/transacao_provider.dart
// lib/providers/transacao_provider.dart
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart'; // <--- Adicionar esta importação
import '../Models/transaction.dart'; // Importa o modelo da transação
import '../enums/tipo_transacao.dart'; // Importa o enum TipoTransacao
import '../services/database_service.dart'; // <--- Adicionar esta importação

class TransacaoProvider with ChangeNotifier {
  List<FinancialTransaction> _transacoes = [];
  bool _isLoading = false;
  String?
      _erro; // Renomeado para _erro para consistência com MetaEconomiaProvider
  // StreamSubscription<List<FinancialTransaction>>? _transactionsSubscription; // Opcional se for usar stream direto no provider

  final DatabaseService _databaseService =
      DatabaseService(); // <--- Instância do DatabaseService

  List<FinancialTransaction> get transacoes => _transacoes;
  bool get isLoading => _isLoading;
  String? get erro => _erro; // Getter para o erro

  // Getter para o ID do usuário atual do Firebase Auth
  String? get currentUserId => FirebaseAuth.instance.currentUser?.uid;

  // Filtrar por tipo - já está no modelo
  // TipoTransacao _getTipoFromTransaction(FinancialTransaction transaction) {
  //   return transaction.tipo; // Já vem do modelo agora
  // }

  // Receitas e despesas (baseado na propriedade 'isExpense' do modelo)
  List<FinancialTransaction> get receitas =>
      _transacoes.where((t) => t.tipo == TipoTransacao.receita).toList();
  List<FinancialTransaction> get despesas =>
      _transacoes.where((t) => t.tipo == TipoTransacao.despesa).toList();

  // Calcular saldo total
  double get saldoTotal {
    double totalReceitas = receitas.fold(
        0,
        (sum, t) =>
            sum + t.value.abs()); // Usar abs() caso valor seja salvo negativo
    double totalDespesas = despesas.fold(0, (sum, t) => sum + t.value.abs());
    return totalReceitas - totalDespesas;
  }

  // Total por tipo
  double getTotalPorTipo(TipoTransacao tipo) {
    return _transacoes.where((t) => t.tipo == tipo).fold(
        0.0,
        (sum, t) =>
            sum + t.value.abs()); // Use abs() para garantir soma positiva
  }

  // Carregar transações (usado em main.dart no StreamBuilder)
  Future<void> carregarTransacoes() async {
    _setLoading(true);
    final userId = currentUserId; // Obtém o userId do Firebase Auth
    if (userId == null) {
      _erro = 'Usuário não logado para carregar transações.';
      _transacoes = []; // Limpa transações se não houver usuário logado
      _setLoading(false);
      return;
    }
    try {
      // Chama o DatabaseService para buscar todas as transações do userId
      _transacoes = await _databaseService
          .getAllTransactions(userId); // <--- Chama o DatabaseService
      _ordenarTransacoes(); // Adiciona a ordenação
      _erro = null;
    } catch (e) {
      _erro = 'Erro ao carregar transações: $e';
      print('Erro ao carregar transações: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Adicionar transação - usando seu modelo
  // O nome do método deve ser 'addTransaction' ou 'adicionarTransacao' consistentemente
  Future<bool> addTransaction(FinancialTransaction transaction) async {
    // Retorna bool para indicar sucesso/falha
    _setLoading(true);
    final userId = currentUserId; // Obtém o userId do Firebase Auth
    if (userId == null) {
      _erro = 'Usuário não logado para adicionar transação.';
      _setLoading(false);
      return false; // Retorna falso em caso de erro
    }
    try {
      // Cria uma cópia da transação COM o userId antes de enviar ao DatabaseService
      final transactionWithUserId = transaction.copyWith(id: userId);
      await _databaseService.addTransaction(
          transactionWithUserId, userId); // <--- Chama o DatabaseService
      _erro = null;
      // Após adicionar, recarregar as transações para atualizar a lista
      await carregarTransacoes();
      return true; // Sucesso
    } catch (e) {
      _erro = 'Erro ao adicionar transação: $e';
      print('Erro ao adicionar transação: $e');
      return false; // Falha
    } finally {
      _setLoading(false);
    }
  }

  // Remover transação
  Future<bool> removerTransacao(String id) async {
    // Retorna bool
    _setLoading(true);
    final userId = currentUserId; // Obtém o userId do Firebase Auth
    if (userId == null) {
      _erro = 'Usuário não logado para remover transação.';
      _setLoading(false);
      return false; // Falha
    }
    try {
      await _databaseService.deleteTransaction(
          id, userId); // <--- Chama o DatabaseService
      _erro = null;
      // Após remover, recarregar as transações
      await carregarTransacoes();
      return true; // Sucesso
    } catch (e) {
      _erro = 'Erro ao remover transação: $e';
      print('Erro ao remover transação: $e');
      return false; // Falha
    } finally {
      _setLoading(false);
    }
  }

  // Método para ordenar transações
  void _ordenarTransacoes() {
    _transacoes
        .sort((a, b) => b.date.compareTo(a.date)); // Mais recente primeiro
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

  @override
  void dispose() {
    // Se tiver um _transactionsSubscription, cancele-o aqui.
    super.dispose();
  }

  // Stream para obter transações de um tipo específico (usado em ExpenseScreen e IncomeScreen)
  Stream<List<FinancialTransaction>> getTransactionsStream(bool isExpense) {
    final userId = currentUserId;
    if (userId == null) {
      return Stream.value([]); // Retorna um stream vazio se não há userId
    }
    // Chama o DatabaseService para obter o stream filtrado por isExpense e userId
    return _databaseService.getTransactions(
        isExpense, userId); // <--- Chama o DatabaseService
  }
}
