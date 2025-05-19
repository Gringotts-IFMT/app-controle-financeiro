import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../services/database_service.dart';
import '../widgets/transaction_form.dart';
import '../widgets/transaction_list.dart';

class IncomeScreen extends StatefulWidget {
  const IncomeScreen({super.key});

  @override
  State<IncomeScreen> createState() => _IncomeScreenState();
}

class _IncomeScreenState extends State<IncomeScreen> {
  final DatabaseService _databaseService = DatabaseService();

  void _showAddIncomeForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: TransactionForm(
          isExpense: false,
          onSubmit: (value, description, category, date) {
            final income = FinancialTransaction(
              id: '',
              value: value,
              description: description,
              category: category,
              date: date,
              isExpense: false,
            );
            _databaseService.addTransaction(income);
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
              stream: _databaseService.getTransactions(false),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Erro: ${snapshot.error}'));
                }

                final incomes = snapshot.data ?? [];

                if (incomes.isEmpty) {
                  return const Center(
                    child: Text('Nenhum ganho registrado ainda.'),
                  );
                }

                return TransactionList(
                  transactions: incomes,
                  onDelete: (id) => _databaseService.deleteTransaction(id),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddIncomeForm,
        // ignore: sort_child_properties_last
        child: const Icon(Icons.add),
        tooltip: 'Adicionar Ganho',
      ),
    );
  }
}
