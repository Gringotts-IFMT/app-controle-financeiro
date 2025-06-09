import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../services/database_service.dart';
import '../widgets/transaction_form.dart';
import '../widgets/transaction_list.dart';
import '../enums/tipo_transacao.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  final DatabaseService _databaseService = DatabaseService();

  void _showAddExpenseForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: TransactionForm(
          isExpense: true,
          onSubmit: (value, description, category, date) {
            final expense = FinancialTransaction(
              id: '',
              value: value,
              description: description,
              category: category,
              date: date,
              tipo: TipoTransacao.despesa,
              isExpense: true,
              
            );
            _databaseService.addTransaction(expense);
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<FinancialTransaction>>(
              stream: _databaseService.getTransactions(true),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Erro: ${snapshot.error}'));
                }

                final expenses = snapshot.data ?? [];

                if (expenses.isEmpty) {
                  return const Center(
                    child: Text('Nenhum gasto registrado ainda.'),
                  );
                }

                return TransactionList(
                  transactions: expenses,
                  onDelete: (id) => _databaseService.deleteTransaction(id),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddExpenseForm,
        // ignore: sort_child_properties_last
        child: const Icon(Icons.add),
        tooltip: 'Adicionar Gasto',
      ),
    );
  }
}
