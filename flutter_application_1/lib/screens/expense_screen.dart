import 'package:controle_financeiro/providers/transacao_provider.dart';
import 'package:controle_financeiro/screens/transacao_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/transaction.dart';
import '../services/database_service.dart'; // Certifique-se de que este import está correto
import '../widgets/transaction_form.dart';
import '../widgets/transaction_list.dart';
import '../enums/tipo_transacao.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key}); // Construtor constante

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  // Remova _databaseService se TransacaoProvider já o usa
  // final DatabaseService _databaseService = DatabaseService();

  void _showAddExpenseForm() {
    final provider = Provider.of<TransacaoProvider>(context, listen: false);
    if (provider.currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, faça login para adicionar transações.'), backgroundColor: Colors.red),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        // Passa isExpense para o formulário se ele for lidar com ambos os tipos
        // Se TransacaoFormScreen tem RadioListTile, pode ser const TransacaoFormScreen()
        child: const TransacaoFormScreen(), // Assuming TransacaoFormScreen handles type selection
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransacaoProvider>(context);

    // Verifica o userId aqui para exibir uma mensagem se não logado
    final userId = provider.currentUserId;
    if (userId == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Faça login para ver seus gastos.'),
          ],
        ),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<FinancialTransaction>>(
              stream: provider.getTransactionsStream(true), // Passa true para despesas
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  print('Erro no StreamBuilder de Gastos: ${snapshot.error}');
                  return Center(child: Text('Erro ao carregar gastos: ${snapshot.error}'));
                }

                final expenses = snapshot.data ?? [];

                if (expenses.isEmpty) {
                  return const Center(
                    child: Text('Nenhum gasto registrado ainda.\nClique no "+" para adicionar um novo.'),
                  );
                }

                return TransactionList(
                  transactions: expenses,
                  onDelete: (id) async {
                    try {
                      bool sucesso = await provider.removerTransacao(id);
                      if (sucesso) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Gasto excluído com sucesso!'), backgroundColor: Colors.green),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(provider.erro ?? 'Erro ao excluir gasto.'), backgroundColor: Colors.red),
                        );
                      }
                    } catch (e) {
                      print('Erro inesperado ao excluir gasto: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Erro inesperado ao excluir gasto: ${e.toString()}'), backgroundColor: Colors.red),
                      );
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddExpenseForm,
        child: const Icon(Icons.add),
        tooltip: 'Adicionar Gasto',
      ),
    );
  }
}