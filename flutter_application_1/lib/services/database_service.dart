// lib/services/database_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction.dart';
import '../models/meta_economia.dart';
import '../enums/status_meta_economia.dart'; // Importe este enum se for usado em regras de status
// import '../Models/usuario.dart'; // Importe se você for gerenciar perfis de usuários no Firestore

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Nomes das coleções no Firestore - CONFIRME ESTES NOMES NO SEU CONSOLE DO FIREBASE
  // DEVEM SER EXATAMENTE IGUAIS AOS NOMES NO FIRESTORE.
  final String _transactionsCollection = 'transactions';
  final String _metasEconomiaCollection = 'metas_economia';
  final String _usersCollection = 'users';

  // --- Métodos para Perfil de Usuários (se você for gerenciar perfis no Firestore) ---
  // Salvar/Atualizar perfil do usuário no Firestore
  // Este método seria chamado após o registro ou login, ou ao editar o perfil
  Future<void> saveUserProfile(
      String userId, Map<String, dynamic> userData) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .set(userData, SetOptions(merge: true));
    } catch (e) {
      print('DatabaseService: Erro ao salvar perfil do usuário: $e');
      rethrow;
    }
  }

  // Obter perfil do usuário do Firestore
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection(_usersCollection).doc(userId).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      print('DatabaseService: Erro ao obter perfil do usuário: $e');
      rethrow;
    }
  }

  // --- Métodos para Transações Financeiras ---

  // Adicionar nova transação
  // A transação deve vir com o userId já preenchido do TransacaoProvider
  Future<void> addTransaction(
      FinancialTransaction transaction, String userId) async {
    try {
      // CORREÇÃO AQUI: Comparar transaction.userId com userId passado
      if (transaction.userId != userId) {
        throw Exception(
            "DatabaseService: Inconsistência de UserId na transação ao adicionar.");
      }
      await _firestore
          .collection(_transactionsCollection)
          .add(transaction.toMap());
    } catch (e) {
      print('DatabaseService: Erro ao adicionar transação no Firebase: $e');
      rethrow;
    }
  }

  // Obter TODAS as transações para um usuário específico (usado pelo TransacaoProvider.carregarTransacoes)
  Future<List<FinancialTransaction>> getAllTransactions(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_transactionsCollection)
          .where('userId', isEqualTo: userId) // Filtra pelo userId
          .orderBy('date',
              descending: true) // Ordena pela data, mais recente primeiro
          .get();

      return querySnapshot.docs
          .map((doc) => FinancialTransaction.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('DatabaseService: Erro ao obter todas as transações: $e');
      rethrow;
    }
  }

  // Obter stream de transações para um usuário e tipo específico (usado por StreamBuilder em Expense/IncomeScreen)
  Stream<List<FinancialTransaction>> getTransactions(
      bool isExpense, String userId) {
    return _firestore
        .collection(_transactionsCollection)
        .where('userId', isEqualTo: userId) // Filtra pelo userId
        .where('isExpense', isEqualTo: isExpense) // Filtra por receita/despesa
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FinancialTransaction.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Deletar uma transação
  Future<void> deleteTransaction(String transactionId, String userId) async {
    try {
      final doc = await _firestore
          .collection(_transactionsCollection)
          .doc(transactionId)
          .get();
      if (!doc.exists) {
        print(
            'DatabaseService: Transação com ID $transactionId não encontrada para exclusão.');
        return;
      }
      if (doc.data()?['userId'] != userId) {
        throw Exception(
            "DatabaseService: Você não tem permissão para deletar esta transação.");
      }
      await _firestore
          .collection(_transactionsCollection)
          .doc(transactionId)
          .delete();
    } catch (e) {
      print('DatabaseService: Erro ao deletar transação: $e');
      rethrow;
    }
  }

  // --- Métodos para Metas de Economia ---

  // Adicionar ou atualizar uma meta de economia
  Future<void> addOrUpdateMetaEconomia(MetaEconomia meta, String userId) async {
    try {
      if (meta.userId != userId) {
        throw Exception(
            "DatabaseService: Inconsistência de UserId na meta ao adicionar/atualizar.");
      }
      if (meta.id == null || meta.id!.isEmpty) {
        // Adicionar nova meta (Firestore gera o ID)
        await _firestore.collection(_metasEconomiaCollection).add(meta.toMap());
      } else {
        // Atualizar meta existente
        final doc = await _firestore
            .collection(_metasEconomiaCollection)
            .doc(meta.id)
            .get();
        if (!doc.exists) {
          print(
              'DatabaseService: Meta com ID ${meta.id} não encontrada para atualização.');
          throw Exception("Meta não encontrada para atualização.");
        }
        if (doc.data()?['userId'] != userId) {
          throw Exception(
              "DatabaseService: Você não tem permissão para atualizar esta meta.");
        }
        await _firestore
            .collection(_metasEconomiaCollection)
            .doc(meta.id)
            .update(meta.toMap());
      }
    } catch (e) {
      print(
          'DatabaseService: Erro ao adicionar/atualizar meta de economia: $e');
      rethrow;
    }
  }

  // Obter stream de metas de economia para um usuário específico
  Stream<List<MetaEconomia>> streamMetas(String userId) {
    return _firestore
        .collection(_metasEconomiaCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('dataAtualizacao', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MetaEconomia.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Buscar metas (sem stream) - Usado pelo MetaEconomiaProvider.carregarMetas
  Future<List<MetaEconomia>> buscarMetas(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_metasEconomiaCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('dataAtualizacao', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => MetaEconomia.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('DatabaseService: Erro ao buscar metas no Firebase: $e');
      rethrow;
    }
  }

  // Deletar uma meta de economia
  Future<void> deleteMetaEconomia(String metaId, String userId) async {
    try {
      final doc = await _firestore
          .collection(_metasEconomiaCollection)
          .doc(metaId)
          .get();
      if (!doc.exists) {
        print(
            'DatabaseService: Meta com ID $metaId não encontrada para exclusão.');
        return;
      }
      if (doc.data()?['userId'] != userId) {
        throw Exception(
            "DatabaseService: Você não tem permissão para deletar esta meta.");
      }
      await _firestore
          .collection(_metasEconomiaCollection)
          .doc(metaId)
          .delete();
    } catch (e) {
      print(
          'DatabaseService: Erro ao deletar meta de economia no Firebase: $e');
      rethrow;
    }
  }

  // --- Métodos de Status e Valor para Metas (específicos) ---

  // Atualizar apenas o valor atual da meta
  Future<bool> atualizarValorAtualMeta(
      String id, double novoValor, String userId) async {
    try {
      final doc =
          await _firestore.collection(_metasEconomiaCollection).doc(id).get();
      if (!doc.exists) return false;
      if (doc.data()?['userId'] != userId) {
        throw Exception(
            "DatabaseService: Acesso não autorizado para atualizar valor da meta.");
      }
      await _firestore.collection(_metasEconomiaCollection).doc(id).update({
        'valorAtual': novoValor,
        'dataAtualizacao': Timestamp.now(),
      });
      return true;
    } catch (e) {
      print('DatabaseService: Erro ao atualizar valor atual da meta: $e');
      return false;
    }
  }

  // Atualizar apenas o status da meta
  Future<bool> atualizarStatusMeta(
      String id, String novoStatus, String userId) async {
    try {
      final doc =
          await _firestore.collection(_metasEconomiaCollection).doc(id).get();
      if (!doc.exists) return false;
      if (doc.data()?['userId'] != userId) {
        throw Exception(
            "DatabaseService: Acesso não autorizado para atualizar status da meta.");
      }
      await _firestore.collection(_metasEconomiaCollection).doc(id).update({
        'status': novoStatus,
        'dataAtualizacao': Timestamp.now(),
      });
      return true;
    } catch (e) {
      print('DatabaseService: Erro ao atualizar status da meta: $e');
      return false;
    }
  }

  // Buscar metas que estão vencendo (nos próximos X dias)
  Future<List<MetaEconomia>> buscarMetasVencendo(
      int diasParaVencer, String userId) async {
    try {
      final DateTime now = DateTime.now();
      final DateTime limiteData = now.add(Duration(days: diasParaVencer));

      final QuerySnapshot querySnapshot = await _firestore
          .collection(_metasEconomiaCollection)
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: StatusMetaEconomia.ativa.name)
          .where('dataFim', isLessThanOrEqualTo: Timestamp.fromDate(limiteData))
          .where('dataFim', isGreaterThan: Timestamp.fromDate(now))
          .orderBy('dataFim')
          .get();

      return querySnapshot.docs
          .map((doc) =>
              MetaEconomia.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print('DatabaseService: Erro ao buscar metas vencendo: $e');
      rethrow;
    }
  }

   // Obter transações por intervalo de datas para um usuário específico
Future<List<FinancialTransaction>> getTransactionsByDateRange(
    String userId, DateTime startDate, DateTime endDate) async {
  try {
    final querySnapshot = await _firestore
        .collection(_transactionsCollection)
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .orderBy('date', descending: true) // Ou ascendente, dependendo da necessidade
        .get();

    return querySnapshot.docs
        .map((doc) => FinancialTransaction.fromMap(doc.data(), doc.id))
        .toList();
  } catch (e) {
    print('DatabaseService: Erro ao buscar transações por data: $e');
    rethrow;
  }
}
}
