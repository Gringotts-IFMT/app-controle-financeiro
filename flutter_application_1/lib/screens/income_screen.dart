import '../enums/tipo_transacao.dart';
import 'package:controle_financeiro/providers/transacao_provider.dart';
import 'package:controle_financeiro/screens/transacao_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:firebase_auth/firebase_auth.dart'; // Importar FirebaseAuth

import '../models/transaction.dart';
// import '../services/database_service.dart';
// import '../widgets/transaction_form.dart';
import '../widgets/transaction_list.dart';
// import '../enums/tipo_transacao.dart';

class IncomeScreen extends StatefulWidget {
  const IncomeScreen({super.key}); // Construtor constante

  @override
  State<IncomeScreen> createState() => _IncomeScreenState();
}

class _IncomeScreenState extends State<IncomeScreen> {
  // Remova _databaseService
  // final DatabaseService _databaseService = DatabaseService();

  void _showAddIncomeForm() {
    // Renomeado para claridade
    final provider = Provider.of<TransacaoProvider>(context, listen: false);
    if (provider.currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Por favor, faça login para adicionar transações.'),
            backgroundColor: Colors.red),
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
        child: TransacaoFormScreen(tipoInicial: TipoTransacao.receita),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransacaoProvider>(context);

    final userId = provider.currentUserId;
    if (userId == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Faça login para ver seus ganhos.'),
          ],
        ),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<FinancialTransaction>>(
              stream: provider
                  .getTransactionsStream(false), // Passa false para receitas
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  print('Erro no StreamBuilder de Ganhos: ${snapshot.error}');
                  return Center(
                      child:
                          Text('Erro ao carregar ganhos: ${snapshot.error}'));
                }

                final incomes = snapshot.data ?? [];

                if (incomes.isEmpty) {
                  return const Center(
                    child: Text(
                        'Nenhum ganho registrado ainda.\nClique no "+" para adicionar um novo.'),
                  );
                }

                return TransactionList(
                  transactions: incomes,
                  onDelete: (id) async {
                    try {
                      bool sucesso = await provider.removerTransacao(id);
                      if (sucesso) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Ganho excluído com sucesso!'),
                              backgroundColor: Colors.green),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  provider.erro ?? 'Erro ao excluir ganho.'),
                              backgroundColor: Colors.red),
                        );
                      }
                    } catch (e) {
                      print('Erro inesperado ao excluir ganho: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                'Erro inesperado ao excluir ganho: ${e.toString()}'),
                            backgroundColor: Colors.red),
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
        onPressed: _showAddIncomeForm, // Chama a função para adicionar ganho
        child: const Icon(Icons.add),
        tooltip: 'Adicionar Ganho',
      ),
    );
  }
}
