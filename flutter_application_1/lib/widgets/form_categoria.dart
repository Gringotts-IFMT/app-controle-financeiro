import 'package:flutter/material.dart';

class CategoryForm extends StatefulWidget {
  final Function(
          String nome, String descricao, String icon, String cor, String tipo)
      onSubmit;
  final dynamic categoria;

  const CategoryForm({Key? key, required this.onSubmit, this.categoria})
      : super(key: key);

  @override
  State<CategoryForm> createState() => _CategoryFormState();
}

class _CategoryFormState extends State<CategoryForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  String _selectedTipo = 'despesa';
  String _selectedIcon = 'restaurant';
  String _selectedColor = '#F44336';

  final List<Map<String, dynamic>> _availableIcons = [
    {'name': 'restaurant', 'icon': Icons.restaurant, 'label': 'Alimentação'},
    {
      'name': 'directions_car',
      'icon': Icons.directions_car,
      'label': 'Transporte'
    },
    {'name': 'movie', 'icon': Icons.movie, 'label': 'Lazer'},
    {'name': 'home', 'icon': Icons.home, 'label': 'Moradia'},
    {'name': 'local_hospital', 'icon': Icons.local_hospital, 'label': 'Saúde'},
    {'name': 'school', 'icon': Icons.school, 'label': 'Educação'},
    {'name': 'checkroom', 'icon': Icons.checkroom, 'label': 'Vestuário'},
    {'name': 'work', 'icon': Icons.work, 'label': 'Trabalho'},
    {'name': 'computer', 'icon': Icons.computer, 'label': 'Tecnologia'},
    {'name': 'trending_up', 'icon': Icons.trending_up, 'label': 'Investimento'},
    {
      'name': 'card_giftcard',
      'icon': Icons.card_giftcard,
      'label': 'Presentes'
    },
    {'name': 'receipt', 'icon': Icons.receipt, 'label': 'Contas'},
    {'name': 'more_horiz', 'icon': Icons.more_horiz, 'label': 'Outros'},
    {'name': 'shopping_cart', 'icon': Icons.shopping_cart, 'label': 'Compras'},
    {
      'name': 'fitness_center',
      'icon': Icons.fitness_center,
      'label': 'Academia'
    },
    {'name': 'pets', 'icon': Icons.pets, 'label': 'Pets'},
    {'name': 'child_care', 'icon': Icons.child_care, 'label': 'Filhos'},
  ];

  final List<String> _availableColors = [
    '#F44336', // Red
    '#E91E63', // Pink
    '#9C27B0', // Purple
    '#2196F3', // Blue
    '#009688', // Teal
    '#4CAF50', // Green
    '#FFEB3B', // Yellow
    '#FF9800', // Orange
    '#795548', // Brown
    '#607D8B', // Blue Grey
  ];

  @override
  void initState() {
    super.initState();
    if (widget.categoria != null) {
      _nomeController.text = widget.categoria.nome;
      _descricaoController.text = widget.categoria.descricao;
      _selectedTipo = widget.categoria.tipo;
      _selectedIcon = widget.categoria.icon;
      _selectedColor = widget.categoria.cor;
    }
  }

  Color _parseColor(String colorString) {
    String hex = colorString.replaceFirst('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    return Color(int.parse(hex, radix: 16));
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      widget.onSubmit(
        _nomeController.text,
        _descricaoController.text,
        _selectedIcon,
        _selectedColor,
        _selectedTipo,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Informe o nome' : null,
              ),
              TextFormField(
                controller: _descricaoController,
                decoration: const InputDecoration(labelText: 'Descrição'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Despesa'),
                      value: 'despesa',
                      groupValue: _selectedTipo,
                      onChanged: (value) {
                        setState(() {
                          _selectedTipo = value!;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Receita'),
                      value: 'receita',
                      groupValue: _selectedTipo,
                      onChanged: (value) {
                        setState(() {
                          _selectedTipo = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
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
                            color: isSelected
                                ? Colors.green
                                : Colors.grey.shade300,
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
                            color:
                                isSelected ? Colors.black : Colors.transparent,
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
      ),
    );
  }
}
