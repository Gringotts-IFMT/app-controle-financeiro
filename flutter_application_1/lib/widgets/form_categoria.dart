import 'package:controle_financeiro/Models/categoria.dart';
import 'package:flutter/material.dart';

class CategoryForm extends StatefulWidget {
  final Function(String, String, String, String) onSubmit;
  final Categoria? categoria;

  const CategoryForm({
    super.key,
    required this.onSubmit,
    this.categoria,
  });

  @override
  State<CategoryForm> createState() => _CategoryFormState();
}

class _CategoryFormState extends State<CategoryForm> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();
  String _selectedIcon = 'category';
  String _selectedColor = '#2196F3';

  final List<Map<String, dynamic>> _availableIcons = [
    {'name': 'category', 'icon': Icons.category, 'label': 'Categoria'},
    {'name': 'restaurant', 'icon': Icons.restaurant, 'label': 'Alimentação'},
    {
      'name': 'directions_car',
      'icon': Icons.directions_car,
      'label': 'Transporte'
    },
    {'name': 'movie', 'icon': Icons.movie, 'label': 'Lazer'},
    {'name': 'home', 'icon': Icons.home, 'label': 'Casa'},
    {'name': 'local_hospital', 'icon': Icons.local_hospital, 'label': 'Saúde'},
    {'name': 'school', 'icon': Icons.school, 'label': 'Educação'},
    {'name': 'checkroom', 'icon': Icons.checkroom, 'label': 'Vestuário'},
    {'name': 'work', 'icon': Icons.work, 'label': 'Trabalho'},
    {'name': 'computer', 'icon': Icons.computer, 'label': 'Tecnologia'},
    {
      'name': 'trending_up',
      'icon': Icons.trending_up,
      'label': 'Investimentos'
    },
    {'name': 'card_giftcard', 'icon': Icons.card_giftcard, 'label': 'Presente'},
    {'name': 'receipt', 'icon': Icons.receipt, 'label': 'Recibo'},
    {'name': 'shopping_cart', 'icon': Icons.shopping_cart, 'label': 'Compras'},
    {
      'name': 'fitness_center',
      'icon': Icons.fitness_center,
      'label': 'Academia'
    },
    {'name': 'pets', 'icon': Icons.pets, 'label': 'Pets'},
    {'name': 'child_care', 'icon': Icons.child_care, 'label': 'Crianças'},
    {'name': 'more_horiz', 'icon': Icons.more_horiz, 'label': 'Outros'},
  ];

  final List<String> _availableColors = [
    '#F44336', // Red
    '#E91E63', // Pink
    '#9C27B0', // Purple
    '#673AB7', // Deep Purple
    '#3F51B5', // Indigo
    '#2196F3', // Blue
    '#03A9F4', // Light Blue
    '#00BCD4', // Cyan
    '#009688', // Teal
    '#4CAF50', // Green
    '#8BC34A', // Light Green
    '#CDDC39', // Lime
    '#FFEB3B', // Yellow
    '#FFC107', // Amber
    '#FF9800', // Orange
    '#FF5722', // Deep Orange
    '#795548', // Brown
    '#9E9E9E', // Grey
    '#607D8B', // Blue Grey
  ];

  @override
  void initState() {
    super.initState();
    if (widget.categoria != null) {
      _nomeController.text = widget.categoria!.nome;
      _descricaoController.text = widget.categoria!.descricao;
      _selectedIcon = widget.categoria!.icon;
      _selectedColor = widget.categoria!.cor;
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      widget.onSubmit(
        _nomeController.text,
        _descricaoController.text,
        _selectedIcon,
        _selectedColor,
      );
    }
  }

  Color _parseColor(String colorString) {
    String hex = colorString.replaceFirst('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    return Color(int.parse(hex, radix: 16));
  }

  IconData _getIconData(String iconName) {
    final iconData = _availableIcons.firstWhere(
      (element) => element['name'] == iconName,
      orElse: () => _availableIcons[0],
    );
    return iconData['icon'];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.categoria == null ? 'Nova Categoria' : 'Editar Categoria',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Preview da categoria
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: _parseColor(_selectedColor),
                    child: Icon(
                      _getIconData(_selectedIcon),
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _nomeController.text.isEmpty
                              ? 'Nome da Categoria'
                              : _nomeController.text,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          _descricaoController.text.isEmpty
                              ? 'Descrição da categoria'
                              : _descricaoController.text,
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Campo Nome
            TextFormField(
              controller: _nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome da Categoria',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira o nome da categoria';
                }
                return null;
              },
              onChanged: (value) => setState(() {}),
            ),
            const SizedBox(height: 16),

            // Campo Descrição
            TextFormField(
              controller: _descricaoController,
              decoration: const InputDecoration(
                labelText: 'Descrição',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 2,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira uma descrição';
                }
                return null;
              },
              onChanged: (value) => setState(() {}),
            ),
            const SizedBox(height: 16),

            // Seleção de Ícone
            const Text(
              'Escolha um ícone:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 100,
              child: GridView.builder(
                scrollDirection: Axis.horizontal,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1,
                ),
                itemCount: _availableIcons.length,
                itemBuilder: (context, index) {
                  final iconData = _availableIcons[index];
                  final isSelected = _selectedIcon == iconData['name'];

                  return GestureDetector(
                    onTap: () =>
                        setState(() => _selectedIcon = iconData['name']),
                    child: Container(
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color:
                              isSelected ? Colors.green : Colors.grey.shade300,
                          width: isSelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            iconData['icon'],
                            color: isSelected
                                ? Colors.green
                                : Colors.grey.shade600,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            iconData['label'],
                            style: TextStyle(
                              fontSize: 10,
                              color: isSelected
                                  ? Colors.green
                                  : Colors.grey.shade600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Seleção de Cor
            const Text(
              'Escolha uma cor:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _availableColors.length,
                itemBuilder: (context, index) {
                  final color = _availableColors[index];
                  final isSelected = _selectedColor == color;

                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = color),
                    child: Container(
                      width: 40,
                      height: 40,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: _parseColor(color),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Colors.black : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.white)
                          : null,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Botão de Salvar
            ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: Text(
                widget.categoria == null
                    ? 'Criar Categoria'
                    : 'Salvar Alterações',
              ),
            ),
          ],
        ),
      ),
    );
  }
}