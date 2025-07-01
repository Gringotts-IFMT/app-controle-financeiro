// ignore_for_file: use_build_context_synchronously

import 'package:controle_financeiro/Models/categoria.dart';
import 'package:controle_financeiro/services/catagoria_service.dart';
import 'package:flutter/material.dart';
import '../../widgets/form_categoria.dart';

class CategoriaScreen extends StatefulWidget {
  final int? idUsuario;

  const CategoriaScreen({super.key, this.idUsuario});

  @override
  State<CategoriaScreen> createState() => _CategoriaScreenState();
}

class _CategoriaScreenState extends State<CategoriaScreen> {
  final CategoriaService _categoriaService = CategoriaService();

  @override
  void initState() {
    super.initState();
    // Criar categorias padrão se necessário
    _categoriaService.criarCategoriasPadrao();
  }

  void _showAddCategoryForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: CategoryForm(
          onSubmit: (nome, descricao, icon, cor) async {
            final categoria = Categoria(
              nome: nome,
              descricao: descricao,
              icon: icon,
              cor: cor,
              padrao: false,
              idUsuario: widget.idUsuario,
            );
            await _categoriaService.adicionarCategoria(categoria);
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Categoria criada com sucesso!')),
            );
          },
        ),
      ),
    );
  }

  void _showEditCategoryForm(Categoria categoria) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: CategoryForm(
          categoria: categoria,
          onSubmit: (nome, descricao, icon, cor) async {
            final categoriaAtualizada = categoria.copyWith(
              nome: nome,
              descricao: descricao,
              icon: icon,
              cor: cor,
            );
            await _categoriaService.atualizarCategoria(
                categoria.id!, categoriaAtualizada);
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Categoria atualizada com sucesso!')),
            );
          },
        ),
      ),
    );
  }

  Color _parseColor(String colorString) {
    String hex = colorString.replaceFirst('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    return Color(int.parse(hex, radix: 16));
  }

  IconData _parseIcon(String iconName) {
    switch (iconName) {
      case 'restaurant':
        return Icons.restaurant;
      case 'directions_car':
        return Icons.directions_car;
      case 'movie':
        return Icons.movie;
      case 'home':
        return Icons.home;
      case 'local_hospital':
        return Icons.local_hospital;
      case 'school':
        return Icons.school;
      case 'checkroom':
        return Icons.checkroom;
      case 'work':
        return Icons.work;
      case 'computer':
        return Icons.computer;
      case 'trending_up':
        return Icons.trending_up;
      case 'card_giftcard':
        return Icons.card_giftcard;
      case 'receipt':
        return Icons.receipt;
      case 'more_horiz':
        return Icons.more_horiz;
      case 'shopping_cart':
        return Icons.shopping_cart;
      case 'fitness_center':
        return Icons.fitness_center;
      case 'pets':
        return Icons.pets;
      case 'child_care':
        return Icons.child_care;
      default:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Categorias'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<Categoria>>(
        stream: _categoriaService.getCategorias(widget.idUsuario),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          final categorias = snapshot.data ?? [];

          if (categorias.isEmpty) {
            return const Center(
              child: Text('Nenhuma categoria encontrada.'),
            );
          }

          // Separar categorias padrão das personalizadas
          final categoriasPadrao = categorias.where((c) => c.padrao).toList();
          final categoriasPersonalizadas =
              categorias.where((c) => !c.padrao).toList();

          return ListView(
            children: [
              if (categoriasPadrao.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Categorias Padrão',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
                ...categoriasPadrao
                    .map((categoria) => _buildCategoryTile(categoria, false)),
              ],
              if (categoriasPersonalizadas.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Minhas Categorias',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
                ...categoriasPersonalizadas
                    .map((categoria) => _buildCategoryTile(categoria, true)),
              ],
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCategoryForm,
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
        tooltip: 'Adicionar Categoria',
      ),
    );
  }

  Widget _buildCategoryTile(Categoria categoria, bool canEdit) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _parseColor(categoria.cor),
          child: Icon(
            _parseIcon(categoria.icon),
            color: Colors.white,
          ),
        ),
        title: Text(
          categoria.nome,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(categoria.descricao),
        trailing: canEdit
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _showEditCategoryForm(categoria),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _showDeleteDialog(categoria),
                  ),
                ],
              )
            : null,
      ),
    );
  }

  void _showDeleteDialog(Categoria categoria) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Categoria'),
        content:
            Text('Deseja realmente excluir a categoria "${categoria.nome}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              await _categoriaService.excluirCategoria(categoria.id!);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Categoria excluída com sucesso!')),
              );
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
