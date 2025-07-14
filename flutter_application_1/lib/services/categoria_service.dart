import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:controle_financeiro/Models/categoria.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../enums/tipo_transacao.dart';

class CategoriaService {
  Stream<List<Categoria>> getCategoriasUsuarioOuPadrao() {
    final user = FirebaseAuth.instance.currentUser;
    String? idUsuario;
    if (user != null && user.uid.isNotEmpty) {
      idUsuario = user.uid;
    }
    return getCategorias(idUsuario);
  }

  Future<List<Categoria>> getCategoriasPorTipo(TipoTransacao tipo,
      {String? idUsuario}) async {
    // Busca categorias padrão
    final padraoSnapshot = await _firestore
        .collection('categorias')
        .where('padrao', isEqualTo: true)
        .get();
    final categoriasPadrao = padraoSnapshot.docs
        .map((doc) => Categoria.fromMap(doc.data(), doc.id))
        .toList();

    // Busca categorias do usuário (se idUsuario informado)
    List<Categoria> categoriasUsuario = [];
    if (idUsuario != null) {
      final usuarioSnapshot = await _firestore
          .collection('categorias')
          .where('idUsuario', isEqualTo: idUsuario)
          .get();
      categoriasUsuario = usuarioSnapshot.docs
          .map((doc) => Categoria.fromMap(doc.data(), doc.id))
          .toList();
    }

    final todas = [...categoriasPadrao, ...categoriasUsuario];
    final tipoStr = tipo == TipoTransacao.despesa ? 'despesa' : 'receita';
    return todas.where((cat) => cat.tipo == tipoStr).toList();
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Criar categorias padrão no primeiro uso
  Future<void> criarCategoriasPadrao() async {
    final categoriasPadrao = [
      // Categorias de Gastos
      Categoria(
          nome: 'Alimentação',
          descricao: 'Gastos com comida e bebida',
          icon: 'restaurant',
          cor: '#FF9800',
          padrao: true,
          idUsuario: null,
          tipo: 'despesa'),
      Categoria(
          nome: 'Transporte',
          descricao: 'Gastos com transporte público, combustível',
          icon: 'directions_car',
          cor: '#2196F3',
          padrao: true,
          idUsuario: null,
          tipo: 'despesa'),
      Categoria(
          nome: 'Lazer',
          descricao: 'Entretenimento, cinema, jogos',
          icon: 'movie',
          cor: '#9C27B0',
          padrao: true,
          idUsuario: null,
          tipo: 'despesa'),
      Categoria(
          nome: 'Moradia',
          descricao: 'Aluguel, contas da casa, manutenção',
          icon: 'home',
          cor: '#795548',
          padrao: true,
          idUsuario: null,
          tipo: 'despesa'),
      Categoria(
          nome: 'Saúde',
          descricao: 'Medicamentos, consultas médicas',
          icon: 'local_hospital',
          cor: '#F44336',
          padrao: true,
          idUsuario: null,
          tipo: 'despesa'),
      Categoria(
          nome: 'Educação',
          descricao: 'Cursos, livros, material escolar',
          icon: 'school',
          cor: '#3F51B5',
          padrao: true,
          idUsuario: null,
          tipo: 'despesa'),
      Categoria(
          nome: 'Vestuário',
          descricao: 'Roupas, calçados, acessórios',
          icon: 'checkroom',
          cor: '#E91E63',
          padrao: true,
          idUsuario: null,
          tipo: 'despesa'),
      // Categorias de Receitas
      Categoria(
          nome: 'Salário',
          descricao: 'Salário mensal, 13º salário',
          icon: 'work',
          cor: '#4CAF50',
          padrao: true,
          idUsuario: null,
          tipo: 'receita'),
      Categoria(
          nome: 'Freelance',
          descricao: 'Trabalhos autônomos',
          icon: 'computer',
          cor: '#00BCD4',
          padrao: true,
          idUsuario: null,
          tipo: 'receita'),
      Categoria(
          nome: 'Investimentos',
          descricao: 'Rendimentos de investimentos',
          icon: 'trending_up',
          cor: '#607D8B',
          padrao: true,
          idUsuario: null,
          tipo: 'receita'),
      Categoria(
          nome: 'Presente',
          descricao: 'Dinheiro recebido de presente',
          icon: 'card_giftcard',
          cor: '#FF5722',
          padrao: true,
          idUsuario: null,
          tipo: 'receita'),
      Categoria(
          nome: 'Reembolso',
          descricao: 'Dinheiro reembolsado',
          icon: 'receipt',
          cor: '#FFC107',
          padrao: true,
          idUsuario: null,
          tipo: 'receita'),
      Categoria(
          nome: 'Outros',
          descricao: 'Outras receitas',
          icon: 'more_horiz',
          cor: '#9E9E9E',
          padrao: true,
          idUsuario: null,
          tipo: 'receita'),
    ];

    // Verificar se já existem categorias padrão
    final snapshot = await _firestore
        .collection('categorias')
        .where('padrao', isEqualTo: true)
        .get();

    if (snapshot.docs.isEmpty) {
      // Criar as categorias padrão
      for (final categoria in categoriasPadrao) {
        await _firestore.collection('categorias').add(categoria.toMap());
      }
    }
  }

  // Adicionar nova categoria
  Future<void> adicionarCategoria(Categoria categoria) async {
    try {
      await _firestore.collection('categorias').add(categoria.toMap());
    } catch (e) {
      print('Erro ao adicionar categoria: $e');
      rethrow;
    }
  }

  // Buscar categorias (padrão + do usuário)
  Stream<List<Categoria>> getCategorias(String? idUsuario) {
    return _firestore
        .collection('categorias')
        .where('padrao', isEqualTo: true)
        .snapshots()
        .asyncMap((padraoSnapshot) async {
      final categoriasPadrao = padraoSnapshot.docs
          .map((doc) => Categoria.fromMap(doc.data(), doc.id))
          .toList();

      List<Categoria> categoriasUsuario = [];
      if (idUsuario != null) {
        final usuarioSnapshot = await _firestore
            .collection('categorias')
            .where('idUsuario', isEqualTo: idUsuario)
            .get();

        categoriasUsuario = usuarioSnapshot.docs
            .map((doc) => Categoria.fromMap(doc.data(), doc.id))
            .toList();
      }

      return [...categoriasPadrao, ...categoriasUsuario];
    });
  }

  // Buscar apenas categorias do usuário
  Stream<List<Categoria>> getCategoriasUsuario(String idUsuario) {
    return _firestore
        .collection('categorias')
        .where('idUsuario', isEqualTo: idUsuario)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Categoria.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Atualizar categoria
  Future<void> atualizarCategoria(String id, Categoria categoria) async {
    try {
      await _firestore
          .collection('categorias')
          .doc(id)
          .update(categoria.toMap());
    } catch (e) {
      print('Erro ao atualizar categoria: $e');
      rethrow;
    }
  }

  // Excluir categoria
  Future<void> excluirCategoria(String id) async {
    try {
      await _firestore.collection('categorias').doc(id).delete();
    } catch (e) {
      print('Erro ao excluir categoria: $e');
      rethrow;
    }
  }
}
