import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart'; // <--- Adicionado: Para obter o userId
import 'package:intl/intl.dart'; // Para formatação de data
import '../providers/transacao_provider.dart';
import '../models/transaction.dart';
import '../enums/tipo_transacao.dart';
import '../services/catagoria_service.dart';
// import '../Models/usuario.dart'; // Certifique-se de que este import está correto

class TransacaoFormScreen extends StatefulWidget {
  // Removi o 'isExpense' do construtor se você prefere sempre o RadioListTile
  // Se quiser que a tela possa ser inicializada com um tipo específico, adicione-o de volta:
  // final bool? isExpenseInitial;
  // const TransacaoFormScreen({super.key, this.isExpenseInitial});

  const TransacaoFormScreen(
      {super.key}); // Para o caso de não receber parâmetro

  @override
  _TransacaoFormScreenState createState() => _TransacaoFormScreenState();
}

class _TransacaoFormScreenState extends State<TransacaoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descricaoController = TextEditingController();
  final _valorController = TextEditingController();

  TipoTransacao _tipoSelecionado = TipoTransacao.despesa;
  String _categoriaSelecionada = 'Alimentação';
  DateTime _dataSelecionada = DateTime.now(); // Data padrão atual

  List<String> _categorias = [];
  bool _carregandoCategorias = true;

  @override
  void initState() {
    super.initState();
    _buscarCategorias();
  }

  Future<void> _buscarCategorias() async {
    setState(() => _carregandoCategorias = true);
    final categoriaService = CategoriaService();
    int? idUsuario;
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.uid.isNotEmpty) {
      // Se o idUsuario for String, converta conforme seu modelo
      idUsuario = int.tryParse(user.uid) ?? null;
    }
    final categorias = await categoriaService
        .getCategoriasPorTipo(_tipoSelecionado, idUsuario: idUsuario);
    setState(() {
      _categorias = categorias.map((cat) => cat.nome).toList();
      _categoriaSelecionada = _categorias.isNotEmpty ? _categorias.first : '';
      _carregandoCategorias = false;
    });
  }

  @override
  void dispose() {
    _descricaoController.dispose();
    _valorController.dispose();
    super.dispose();
  }

  // Função para abrir o seletor de data
  Future<void> _selecionarData(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada,
      firstDate: DateTime(2000),
      lastDate: DateTime.now()
          .add(const Duration(days: 365)), // Ex: Até 1 ano no futuro
      helpText: 'Selecione a Data da Transação',
      cancelText: 'Cancelar',
      confirmText: 'Confirmar',
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: _tipoSelecionado
                  .cor, // Cor do seletor de data baseado no tipo
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _dataSelecionada) {
      setState(() {
        _dataSelecionada = picked;
      });
    }
  }

  void _salvarTransacao() async {
    if (!_formKey.currentState!.validate()) return;

    // --- Obtenção do userId do Firebase Auth ---
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Erro: Usuário não logado. Faça login novamente.'),
            backgroundColor: Colors.red),
      );
      return; // Interrompe a função se o usuário não estiver logado
    }
    // -------------------------------------------

    double valor = double.parse(_valorController.text.replaceAll(',', '.'));

    // Ajustar valor baseado no tipo (negativo para despesa)
    if (_tipoSelecionado == TipoTransacao.despesa) {
      valor = -valor.abs(); // Força negativo para despesas
    } else {
      valor = valor.abs(); // Força positivo para receitas
    }

    // Criar transação usando seu modelo existente
    final transacao = FinancialTransaction(
      id: '', // O Firebase Firestore irá gerar o ID do documento
      userId: currentUserId, // Adicionado: userId obrigatório
      description: _descricaoController.text.trim(),
      value: valor,
      date: _dataSelecionada,
      category: _categoriaSelecionada,
      isExpense: _tipoSelecionado == TipoTransacao.despesa,
      tipo: _tipoSelecionado,
    );

    final provider = Provider.of<TransacaoProvider>(context, listen: false);

    // Adicionar transação usando o provider
    bool sucesso = await provider
        .addTransaction(transacao); // O provider já lida com o isLoading

    if (sucesso) {
      // Verificar o resultado da operação do provider
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transação adicionada com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          // O provider.error já deve ter uma mensagem útil do TransacaoProvider
          content: Text('Erro ao adicionar transação.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Transação'),
        backgroundColor:
            _tipoSelecionado.cor, // AppBar muda de cor conforme o tipo
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Seletor de Tipo (Receita/Despesa)
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tipo de Transação',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Row(
                      children: TipoTransacao.values.map((tipo) {
                        return Expanded(
                          child: RadioListTile<TipoTransacao>(
                            title: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(tipo.icone,
                                    style: const TextStyle(
                                        fontSize: 20)), // Usar .icone
                                const SizedBox(width: 8),
                                Text(tipo.descricao), // Usar .descricao
                              ],
                            ),
                            value: tipo,
                            groupValue: _tipoSelecionado,
                            onChanged: (value) {
                              setState(() {
                                _tipoSelecionado = value!;
                              });
                              _buscarCategorias();
                            },
                            activeColor: tipo.cor,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
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
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Informe uma descrição';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Campo Valor
            TextFormField(
              controller: _valorController,
              decoration: const InputDecoration(
                labelText: 'Valor',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
                prefixText: 'R\$ ',
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Informe o valor';
                }
                if (double.tryParse(value.replaceAll(',', '.')) == null) {
                  return 'Valor inválido';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Campo de seleção de Data
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text(
                'Data: ${DateFormat('dd/MM/yyyy').format(_dataSelecionada)}',
              ),
              trailing: const Icon(Icons.edit),
              onTap: () => _selecionarData(context), // Abre o seletor de data
            ),

            const SizedBox(height: 16),

            // Dropdown Categoria
            _carregandoCategorias
                ? const Center(child: CircularProgressIndicator())
                : DropdownButtonFormField<String>(
                    value: _categoriaSelecionada.isNotEmpty
                        ? _categoriaSelecionada
                        : null,
                    decoration: const InputDecoration(
                      labelText: 'Categoria',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.category),
                    ),
                    items: _categorias.map((categoria) {
                      return DropdownMenuItem(
                        value: categoria,
                        child: Text(categoria),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _categoriaSelecionada = value!;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Selecione uma categoria';
                      }
                      return null;
                    },
                  ),

            const SizedBox(height: 32),

            // Botão Salvar
            Consumer<TransacaoProvider>(
              builder: (context, provider, child) {
                return ElevatedButton(
                  onPressed: provider.isLoading ? null : _salvarTransacao,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _tipoSelecionado.cor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: provider.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Salvar', style: TextStyle(fontSize: 18)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
