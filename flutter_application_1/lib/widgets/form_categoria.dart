import 'package:controle_financeiro/models/Categoria/model_categoria.dart';
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
    {'name': 'category', 'icon': Icons.category, 'label': 'Geral'},
    {'name': 'restaurant', 'icon': Icons.restaurant, 'label': 'Comida'},
    {'name': 'directions_car', 'icon': Icons.directions_car, 'label': 'Carro'},
    {'name': 'movie', 'icon': Icons.movie, 'label': 'Lazer'},
    {'name': 'home', 'icon': Icons.home, 'label': 'Casa'},
    {'name': 'local_hospital', 'icon': Icons.local_hospital, 'label': 'Saúde'},
    {'name': 'school', 'icon': Icons.school, 'label': 'Escola'},
    {'name': 'checkroom', 'icon': Icons.checkroom, 'label': 'Roupa'},
    {'name': 'work', 'icon': Icons.work, 'label': 'Trabalho'},
    {'name': 'computer', 'icon': Icons.computer, 'label': 'Tech'},
    {'name': 'trending_up', 'icon': Icons.trending_up, 'label': 'Invest'},
    {'name': 'card_giftcard', 'icon': Icons.card_giftcard, 'label': 'Gift'},
    {'name': 'receipt', 'icon': Icons.receipt, 'label': 'Recibo'},
    {'name': 'shopping_cart', 'icon': Icons.shopping_cart, 'label': 'Compra'},
    {'name': 'fitness_center', 'icon': Icons.fitness_center, 'label': 'Gym'},
    {'name': 'pets', 'icon': Icons.pets, 'label': 'Pet'},
    {'name': 'child_care', 'icon': Icons.child_care, 'label': 'Criança'},
    {'name': 'more_horiz', 'icon': Icons.more_horiz, 'label': 'Outro'},
  ];

  final List<String> _availableColors = [
    '#F44336',
    '#E91E63',
    '#9C27B0',
    '#673AB7',
    '#3F51B5',
    '#2196F3',
    '#03A9F4',
    '#00BCD4',
    '#009688',
    '#4CAF50',
    '#8BC34A',
    '#CDDC39',
    '#FFEB3B',
    '#FFC107',
    '#FF9800',
    '#FF5722',
    '#795548',
    '#9E9E9E',
    '#607D8B',
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
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título
              Center(
                child: Text(
                  widget.categoria == null
                      ? 'Nova Categoria'
                      : 'Editar Categoria',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                ),
              ),
              const SizedBox(height: 32),

              // Preview da categoria - Cartão mais bonito
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [
                        _parseColor(_selectedColor).withOpacity(0.1),
                        _parseColor(_selectedColor).withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: _parseColor(_selectedColor),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  _parseColor(_selectedColor).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          _getIconData(_selectedIcon),
                          color: Colors.white,
                          size: 28,
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
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _descricaoController.text.isEmpty
                                  ? 'Descrição da categoria'
                                  : _descricaoController.text,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Campos de texto - Design melhorado
              TextFormField(
                controller: _nomeController,
                decoration: InputDecoration(
                  labelText: 'Nome da Categoria',
                  hintText: 'Ex: Alimentação, Transporte...',
                  prefixIcon:
                      Icon(Icons.title, color: _parseColor(_selectedColor)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: _parseColor(_selectedColor), width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o nome da categoria';
                  }
                  return null;
                },
                onChanged: (value) => setState(() {}),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _descricaoController,
                decoration: InputDecoration(
                  labelText: 'Descrição',
                  hintText: 'Descreva para que serve esta categoria...',
                  prefixIcon: Icon(Icons.description,
                      color: _parseColor(_selectedColor)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: _parseColor(_selectedColor), width: 2),
                  ),
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
              const SizedBox(height: 32),

              // Seleção de Ícone - Grid melhorado
              Text(
                'Escolha um ícone:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                    childAspectRatio: 1,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: _availableIcons.length,
                  itemBuilder: (context, index) {
                    final iconData = _availableIcons[index];
                    final isSelected = _selectedIcon == iconData['name'];

                    return Tooltip(
                      message: iconData['label'],
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _selectedIcon = iconData['name']),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? _parseColor(_selectedColor).withOpacity(0.2)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? _parseColor(_selectedColor)
                                  : Colors.grey.shade300,
                              width: isSelected ? 2 : 1,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: _parseColor(_selectedColor)
                                          .withOpacity(0.3),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Icon(
                            iconData['icon'],
                            color: isSelected
                                ? _parseColor(_selectedColor)
                                : Colors.grey.shade600,
                            size: 24,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),

              // Seleção de Cor - Grid melhorado
              Text(
                'Escolha uma cor:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    childAspectRatio: 1,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: _availableColors.length,
                  itemBuilder: (context, index) {
                    final color = _availableColors[index];
                    final isSelected = _selectedColor == color;

                    return GestureDetector(
                      onTap: () => setState(() => _selectedColor = color),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: _parseColor(color),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? Colors.black87 : Colors.white,
                            width: isSelected ? 3 : 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _parseColor(color).withOpacity(0.3),
                              blurRadius: isSelected ? 6 : 2,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 20,
                              )
                            : null,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 40),

              // Botão de Salvar - Design melhorado
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _parseColor(_selectedColor),
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shadowColor: _parseColor(_selectedColor).withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        widget.categoria == null ? Icons.add : Icons.save,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.categoria == null
                            ? 'Criar Categoria'
                            : 'Salvar Alterações',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
