import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:controle_financeiro/Models/categoria.dart';

class CategoriaService {
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
          idUsuario: null),
      Categoria(
          nome: 'Transporte',
          descricao: 'Gastos com transporte público, combustível',
          icon: 'directions_car',
          cor: '#2196F3',
          padrao: true,
          idUsuario: null),
      Categoria(
          nome: 'Lazer',
          descricao: 'Entretenimento, cinema, jogos',
          icon: 'movie',
          cor: '#9C27B0',
          padrao: true,
          idUsuario: null),
      Categoria(
          nome: 'Moradia',
          descricao: 'Aluguel, contas da casa, manutenção',
          icon: 'home',
          cor: '#795548',
          padrao: true,
          idUsuario: null),
      Categoria(
          nome: 'Saúde',
          descricao: 'Medicamentos, consultas médicas',
          icon: 'local_hospital',
          cor: '#F44336',
          padrao: true,
          idUsuario: null),
      Categoria(
          nome: 'Educação',
          descricao: 'Cursos, livros, material escolar',
          icon: 'school',
          cor: '#3F51B5',
          padrao: true,
          idUsuario: null),
      Categoria(
          nome: 'Vestuário',
          descricao: 'Roupas, calçados, acessórios',
          icon: 'checkroom',
          cor: '#E91E63',
          padrao: true,
          idUsuario: null),
      // Categorias de Receitas
      Categoria(
          nome: 'Salário',
          descricao: 'Salário mensal, 13º salário',
          icon: 'work',
          cor: '#4CAF50',
          padrao: true,
          idUsuario: null),
      Categoria(
          nome: 'Freelance',
          descricao: 'Trabalhos autônomos',
          icon: 'computer',
          cor: '#00BCD4',
          padrao: true,
          idUsuario: null),
      Categoria(
          nome: 'Investimentos',
          descricao: 'Rendimentos de investimentos',
          icon: 'trending_up',
          cor: '#607D8B',
          padrao: true,
          idUsuario: null),
      Categoria(
          nome: 'Presente',
          descricao: 'Dinheiro recebido de presente',
          icon: 'card_giftcard',
          cor: '#FF5722',
          padrao: true,
          idUsuario: null),
      Categoria(
          nome: 'Reembolso',
          descricao: 'Dinheiro reembolsado',
          icon: 'receipt',
          cor: '#FFC107',
          padrao: true,
          idUsuario: null),
      Categoria(
          nome: 'Outros',
          descricao: 'Outras receitas',
          icon: 'more_horiz',
          cor: '#9E9E9E',
          padrao: true,
          idUsuario: null),
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
  Stream<List<Categoria>> getCategorias(int? idUsuario) {
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
  Stream<List<Categoria>> getCategoriasUsuario(int idUsuario) {
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