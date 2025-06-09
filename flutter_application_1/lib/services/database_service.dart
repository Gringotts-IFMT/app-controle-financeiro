import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction.dart';
import '../Models/meta_economia.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _metasCollection = 'metas_economia';

   Future<String?> inserirMeta(MetaEconomia meta) async {
    try {
      // Criar referência do documento
      final docRef = _firestore.collection(_metasCollection).doc();
      
      // Criar meta com ID gerado
      final metaComId = meta.copyWith(id: docRef.id);
      
      // Salvar no Firestore
      await docRef.set(metaComId.toMap());
      
      return docRef.id;
    } catch (e) {
      print('Erro ao inserir meta no Firebase: $e');
      return null;
    }
  }

  // Buscar todas as metas
  Future<List<MetaEconomia>> buscarMetas() async {
    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection(_metasCollection)
          .orderBy('dataAtualizacao', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Garantir que o ID está presente
        return MetaEconomia.fromMap(data);
      }).toList();
    } catch (e) {
      print('Erro ao buscar metas no Firebase: $e');
      return [];
    }
  }

  // Buscar meta por ID
  Future<MetaEconomia?> buscarMetaPorId(String id) async {
    try {
      final DocumentSnapshot doc = await _firestore
          .collection(_metasCollection)
          .doc(id)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return MetaEconomia.fromMap(data);
      }
      return null;
    } catch (e) {
      print('Erro ao buscar meta por ID no Firebase: $e');
      return null;
    }
  }

  // Atualizar meta
  Future<bool> atualizarMeta(MetaEconomia meta) async {
    try {
      if (meta.id == null) return false;
      
      await _firestore
          .collection(_metasCollection)
          .doc(meta.id)
          .update(meta.toMap());
      
      return true;
    } catch (e) {
      print('Erro ao atualizar meta no Firebase: $e');
      return false;
    }
  }

  // Excluir meta
  Future<bool> excluirMeta(String id) async {
    try {
      await _firestore
          .collection(_metasCollection)
          .doc(id)
          .delete();
      
      return true;
    } catch (e) {
      print('Erro ao excluir meta no Firebase: $e');
      return false;
    }
  }

  // Buscar metas por status
  Future<List<MetaEconomia>> buscarMetasPorStatus(String status) async {
    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection(_metasCollection)
          .where('status', isEqualTo: status)
          .orderBy('dataFim')
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return MetaEconomia.fromMap(data);
      }).toList();
    } catch (e) {
      print('Erro ao buscar metas por status no Firebase: $e');
      return [];
    }
  }

  // Buscar metas por categoria
  Future<List<MetaEconomia>> buscarMetasPorCategoria(String categoria) async {
    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection(_metasCollection)
          .where('categoria', isEqualTo: categoria)
          .orderBy('dataAtualizacao', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return MetaEconomia.fromMap(data);
      }).toList();
    } catch (e) {
      print('Erro ao buscar metas por categoria no Firebase: $e');
      return [];
    }
  }

  // Buscar metas por período
  Future<List<MetaEconomia>> buscarMetasPorPeriodo(
    DateTime dataInicio, 
    DateTime dataFim
  ) async {
    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection(_metasCollection)
          .where('dataInicio', isGreaterThanOrEqualTo: dataInicio.toIso8601String())
          .where('dataFim', isLessThanOrEqualTo: dataFim.toIso8601String())
          .orderBy('dataInicio')
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return MetaEconomia.fromMap(data);
      }).toList();
    } catch (e) {
      print('Erro ao buscar metas por período no Firebase: $e');
      return [];
    }
  }

  // Stream para escutar mudanças em tempo real (opcional)
  Stream<List<MetaEconomia>> streamMetas() {
    return _firestore
        .collection(_metasCollection)
        .orderBy('dataAtualizacao', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return MetaEconomia.fromMap(data);
      }).toList();
    });
  }

  // Stream para uma meta específica
  Stream<MetaEconomia?> streamMetaPorId(String id) {
    return _firestore
        .collection(_metasCollection)
        .doc(id)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        final data = doc.data()!;
        data['id'] = doc.id;
        return MetaEconomia.fromMap(data);
      }
      return null;
    });
  }

  // Buscar metas ativas que estão vencendo (nos próximos X dias)
  Future<List<MetaEconomia>> buscarMetasVencendo(int diasParaVencer) async {
    try {
      final DateTime limiteData = DateTime.now().add(Duration(days: diasParaVencer));
      
      final QuerySnapshot querySnapshot = await _firestore
          .collection(_metasCollection)
          .where('status', isEqualTo: 'ativa')
          .where('dataFim', isLessThanOrEqualTo: limiteData.toIso8601String())
          .where('dataFim', isGreaterThan: DateTime.now().toIso8601String())
          .orderBy('dataFim')
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return MetaEconomia.fromMap(data);
      }).toList();
    } catch (e) {
      print('Erro ao buscar metas vencendo no Firebase: $e');
      return [];
    }
  }

  // Atualizar apenas o valor atual da meta (para performance)
  Future<bool> atualizarValorAtualMeta(String id, double novoValor) async {
    try {
      await _firestore
          .collection(_metasCollection)
          .doc(id)
          .update({
        'valorAtual': novoValor,
        'dataAtualizacao': DateTime.now().toIso8601String(),
      });
      
      return true;
    } catch (e) {
      print('Erro ao atualizar valor da meta no Firebase: $e');
      return false;
    }
  }

  // Atualizar apenas o status da meta
  Future<bool> atualizarStatusMeta(String id, String novoStatus) async {
    try {
      await _firestore
          .collection(_metasCollection)
          .doc(id)
          .update({
        'status': novoStatus,
        'dataAtualizacao': DateTime.now().toIso8601String(),
      });
      
      return true;
    } catch (e) {
      print('Erro ao atualizar status da meta no Firebase: $e');
      return false;
    }
  }

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
