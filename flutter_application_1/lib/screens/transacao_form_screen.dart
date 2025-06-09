import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transacao_provider.dart';
import '../models/transaction.dart';
import '../enums/tipo_transacao.dart';

class TransacaoFormScreen extends StatefulWidget {
  @override
  _TransacaoFormScreenState createState() => _TransacaoFormScreenState();
}

class _TransacaoFormScreenState extends State<TransacaoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descricaoController = TextEditingController();
  final _valorController = TextEditingController();
  
  TipoTransacao _tipoSelecionado = TipoTransacao.despesa;
  String _categoriaSelecionada = 'Alimentação';
  DateTime _dataSelecionada = DateTime.now();

  final List<String> _categorias = [
    'Alimentação', 'Transporte', 'Lazer', 'Saúde', 'Educação', 'Casa', 'Outros'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nova Transação'),
        backgroundColor: _tipoSelecionado.cor,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            // Seletor de Tipo (Receita/Despesa)
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tipo de Transação', 
                         style: Theme.of(context).textTheme.titleMedium),
                    Row(
                      children: TipoTransacao.values.map((tipo) {
                        return Expanded(
                          child: RadioListTile<TipoTransacao>(
                            title: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(tipo.icone),
                                SizedBox(width: 8),
                                Text(tipo.nome),
                              ],
                            ),
                            value: tipo,
                            groupValue: _tipoSelecionado,
                            onChanged: (value) {
                              setState(() {
                                _tipoSelecionado = value!;
                              });
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
            
            SizedBox(height: 16),

            // Campo Descrição
            TextFormField(
              controller: _descricaoController,
              decoration: InputDecoration(
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

            SizedBox(height: 16),

            // Campo Valor
            TextFormField(
              controller: _valorController,
              decoration: InputDecoration(
                labelText: 'Valor',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
                prefixText: 'R\$ ',
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
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

            SizedBox(height: 16),

            // Dropdown Categoria
            DropdownButtonFormField<String>(
              value: _categoriaSelecionada,
              decoration: InputDecoration(
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
            ),

            SizedBox(height: 32),

            // Botão Salvar
            Consumer<TransacaoProvider>(
              builder: (context, provider, child) {
                return ElevatedButton(
                  onPressed: provider.isLoading ? null : _salvarTransacao,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _tipoSelecionado.cor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: provider.isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text('Salvar', style: TextStyle(fontSize: 16)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _salvarTransacao() async {
    if (!_formKey.currentState!.validate()) return;

    double valor = double.parse(_valorController.text.replaceAll(',', '.'));
    
    // Ajustar valor baseado no tipo (negativo para despesa)
    if (_tipoSelecionado == TipoTransacao.despesa) {
      valor = -valor.abs(); // Força negativo
    } else {
      valor = valor.abs(); // Força positivo
    }
    
    // Criar transação usando seu modelo existente
    final transacao = FinancialTransaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      description: _descricaoController.text.trim(),
      value: valor,
      date: _dataSelecionada,
      category: _categoriaSelecionada,
      isExpense: _tipoSelecionado == TipoTransacao.despesa,
      tipo: _tipoSelecionado,
    );

    final provider = Provider.of<TransacaoProvider>(context, listen: false);
    
    await provider.adicionarTransacao(transacao);

    if (provider.error == null) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Transação adicionada com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}