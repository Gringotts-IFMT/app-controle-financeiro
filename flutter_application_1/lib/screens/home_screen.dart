import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transacao_provider.dart';
import '../models/transaction.dart';
import '../enums/tipo_transacao.dart';
import 'transacao_form_screen.dart'; // Para o FloatingActionButton
import '../widgets/transaction_list.dart'; // Para exibir a lista de todas as transações
import 'expense_screen.dart'; // Para a aba de gastos
import 'income_screen.dart'; // Para a aba de ganhos

// HomeScreen agora será um StatefulWidget para gerenciar o TabController
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); // 3 abas: Todas, Gastos, Ganhos
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Funções de construção de UI auxiliares (mantidas as que você já tinha)
  Widget _buildSaldoCard(TransacaoProvider provider) {
    // ... (Seu código existente para o card de saldo)
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.green, Colors.lightGreen],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Text(
            'Saldo Atual',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'R\$ ${provider.saldoTotal.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSaldoItem(
                'Receitas', 
                provider.getTotalPorTipo(TipoTransacao.receita),
                TipoTransacao.receita.icone,
              ),
              _buildSaldoItem(
                'Despesas', 
                provider.getTotalPorTipo(TipoTransacao.despesa),
                TipoTransacao.despesa.icone,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSaldoItem(String label, double valor, String icone) {
    // ... (Seu código existente para o item de saldo)
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icone, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(color: Colors.white70)),
          ],
        ),
        Text(
          'R\$ ${valor.toStringAsFixed(2)}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // Widget para exibir a lista de TODAS as transações (usado na primeira aba)
  Widget _buildTodasTransacoesList(TransacaoProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.erro != null) {
      return Center(child: Text('Erro: ${provider.erro}'));
    }
    if (provider.transacoes.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Nenhuma transação encontrada'),
            SizedBox(height: 8),
            Text('Toque no "+" para adicionar uma transação'),
          ],
        ),
      );
    }
    return TransactionList(
      transactions: provider.transacoes, // Exibe TODAS as transações
      onDelete: (id) async {
        await provider.removerTransacao(id);
      },
    );
  }

  // Função para mostrar o diálogo de adição de transação
  void _showAddTransactionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Adicionar Transação'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.arrow_upward, color: Colors.green),
                title: const Text('Nova Receita'),
                onTap: () {
                  Navigator.pop(dialogContext); // Fecha o diálogo
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      // Passa o isExpense para o TransacaoFormScreen se ele lidar com isso
                      builder: (context) => const TransacaoFormScreen(), 
                    ),
                  );
                  // Opcional: pré-selecionar o tipo na TransacaoFormScreen
                  // builder: (context) => const TransacaoFormScreen(isExpenseInitial: false),
                },
              ),
              ListTile(
                leading: const Icon(Icons.arrow_downward, color: Colors.red),
                title: const Text('Nova Despesa'),
                onTap: () {
                  Navigator.pop(dialogContext); // Fecha o diálogo
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      // Passa o isExpense para o TransacaoFormScreen se ele lidar com isso
                      builder: (context) => const TransacaoFormScreen(), 
                    ),
                  );
                  // Opcional: pré-selecionar o tipo na TransacaoFormScreen
                  // builder: (context) => const TransacaoFormScreen(isExpenseInitial: true),
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Controle Financeiro'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0, // Remover sombra para um visual mais limpo com as abas
        bottom: TabBar( // <--- Adicionando o TabBar aqui
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Todas'),
            Tab(text: 'Gastos'),
            Tab(text: 'Ganhos'),
          ],
        ),
      ),
      body: Consumer<TransacaoProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              // Card de Saldo
              _buildSaldoCard(provider),
              
              // Conteúdo das Abas (TransactionList, ExpenseScreen, IncomeScreen)
              Expanded(
                child: TabBarView( // <--- Adicionando o TabBarView
                  controller: _tabController,
                  children: [
                    _buildTodasTransacoesList(provider), // Todas as transações
                    const ExpenseScreen(), // A tela de gastos
                    const IncomeScreen(), // A tela de ganhos
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTransactionDialog, // Usa o diálogo para adicionar
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }
}