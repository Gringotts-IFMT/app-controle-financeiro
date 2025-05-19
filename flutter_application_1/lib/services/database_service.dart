import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addTransaction(FinancialTransaction transaction) async {
    try {
      await _firestore.collection('transactions').add(transaction.toMap());
    } catch (e) {
      print('Erro ao adicionar transação: $e');
      rethrow;
    }
  }

  Stream<List<FinancialTransaction>> getTransactions(bool isExpense) {
    return _firestore
        .collection('transactions')
        .where('isExpense', isEqualTo: isExpense)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FinancialTransaction.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> deleteTransaction(String id) async {
    try {
      await _firestore.collection('transactions').doc(id).delete();
    } catch (e) {
      print('Erro ao excluir transação: $e');
      rethrow;
    }
  }
}
