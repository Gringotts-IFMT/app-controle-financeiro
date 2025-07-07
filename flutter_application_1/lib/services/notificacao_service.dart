import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notificacao.dart';

class NotificacaoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Notificacao>> getNotificacoes(int idUsuario) {
    return _firestore
        .collection('notificacoes')
        .where('idUsuario', isEqualTo: idUsuario)
        .orderBy('data', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Notificacao.fromMap(doc.data()))
            .toList());
  }

  Future<void> marcarComoLida(int id) async {
    final query = await _firestore
        .collection('notificacoes')
        .where('id', isEqualTo: id)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      await query.docs.first.reference.update({'lida': true});
    }
  }

  Future<void> criarNotificacao(Notificacao notificacao) async {
    await _firestore.collection('notificacoes').add(notificacao.toMap());
  }
}
