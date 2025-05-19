import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';

class TransactionList extends StatelessWidget {
  final List<FinancialTransaction> transactions;
  final Function(String) onDelete;

  const TransactionList({
    super.key,
    required this.transactions,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          elevation: 2,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor:
                  transaction.isExpense ? Colors.red : Colors.green,
              child: Icon(
                transaction.isExpense
                    ? Icons.arrow_downward
                    : Icons.arrow_upward,
                color: Colors.white,
              ),
            ),
            title: Text(
              transaction.description,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
                '${transaction.category} • ${DateFormat('dd/MM/yyyy').format(transaction.date)}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'R\$ ${transaction.value.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: transaction.isExpense ? Colors.red : Colors.green,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => onDelete(transaction.id),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
