import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Para formatação de datas e moedas
import '../providers/relatorio_provider.dart';
import '../models/relatorio.dart';
import '../enums/tipo_relatorio.dart';

class RelatorioScreen extends StatefulWidget {
  const RelatorioScreen({super.key});

  @override
  State<RelatorioScreen> createState() => _RelatorioScreenState();
}

class _RelatorioScreenState extends State<RelatorioScreen> {
  TipoRelatorio _tipoRelatorioSelecionado = TipoRelatorio.mensal;
  DateTime? _dataInicioCustomizada;
  DateTime? _dataFimCustomizada;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>(); // Para validação do formulário

  @override
  void initState() {
    super.initState();
    // Inicializar o relatório com o tipo mensal ao abrir a tela
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RelatorioProvider>(context, listen: false)
          .gerarRelatorio(TipoRelatorio.mensal);
    });
  }

  // Função para selecionar data
  Future<void> _selecionarData(BuildContext context, {required bool isStartDate}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      helpText: isStartDate ? 'Selecione a Data de Início' : 'Selecione a Data Fim',
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _dataInicioCustomizada = picked;
        } else {
          _dataFimCustomizada = picked;
        }
      });
    }
  }

  // Função para acionar a geração do relatório
  void _gerarRelatorio() {
    if (_tipoRelatorioSelecionado == TipoRelatorio.personalizado) {
      if (_dataInicioCustomizada == null || _dataFimCustomizada == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecione as datas para o relatório personalizado.'), backgroundColor: Colors.red),
        );
        return;
      }
      if (_dataFimCustomizada!.isBefore(_dataInicioCustomizada!)) {
         ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('A data final não pode ser anterior à data inicial.'), backgroundColor: Colors.red),
        );
        return;
      }
    }

    Provider.of<RelatorioProvider>(context, listen: false).gerarRelatorio(
      _tipoRelatorioSelecionado,
      dataInicioCustomizada: _dataInicioCustomizada,
      dataFimCustomizada: _dataFimCustomizada,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Relatórios Financeiros'),
        backgroundColor: Colors.blueGrey, // Uma cor diferente para relatórios
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<RelatorioProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Dropdown para Tipo de Relatório
                      DropdownButtonFormField<TipoRelatorio>(
                        value: _tipoRelatorioSelecionado,
                        decoration: const InputDecoration(
                          labelText: 'Tipo de Relatório',
                          border: OutlineInputBorder(),
                        ),
                        items: TipoRelatorio.values.map((tipo) {
                          return DropdownMenuItem(
                            value: tipo,
                            child: Text(tipo.descricao),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _tipoRelatorioSelecionado = value!;
                            // Limpar datas se mudar de personalizado
                            if (value != TipoRelatorio.personalizado) {
                              _dataInicioCustomizada = null;
                              _dataFimCustomizada = null;
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      // Seletores de data (visíveis apenas para tipo Personalizado)
                      if (_tipoRelatorioSelecionado == TipoRelatorio.personalizado)
                        Column(
                          children: [
                            ListTile(
                              title: Text(
                                _dataInicioCustomizada == null
                                    ? 'Selecione a Data de Início'
                                    : 'Início: ${DateFormat('dd/MM/yyyy').format(_dataInicioCustomizada!)}',
                              ),
                              trailing: const Icon(Icons.calendar_today),
                              onTap: () => _selecionarData(context, isStartDate: true),
                            ),
                            ListTile(
                              title: Text(
                                _dataFimCustomizada == null
                                    ? 'Selecione a Data Fim'
                                    : 'Fim: ${DateFormat('dd/MM/yyyy').format(_dataFimCustomizada!)}',
                              ),
                              trailing: const Icon(Icons.calendar_today),
                              onTap: () => _selecionarData(context, isStartDate: false),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      
                      ElevatedButton(
                        onPressed: provider.isLoading ? null : _gerarRelatorio,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueGrey,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(50),
                        ),
                        child: provider.isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Gerar Relatório', style: TextStyle(fontSize: 18)),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(),
              // Exibição do Relatório
              Expanded(
                child: _buildRelatorioContent(provider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRelatorioContent(RelatorioProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.erro != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text('Erro ao gerar relatório: ${provider.erro}', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  provider.limparErro();
                  _gerarRelatorio(); // Tenta gerar novamente
                },
                child: const Text('Tentar Novamente'),
              ),
            ],
          ),
        ),
      );
    }

    if (provider.relatorioAtual == null) {
      return const Center(
        child: Text('Gere um relatório para visualizar os dados.'),
      );
    }

    final Relatorio relatorio = provider.relatorioAtual!;
    final NumberFormat currencyFormatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumo do Relatório (${relatorio.tipoRelatorio.descricao})',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Período: ${DateFormat('dd/MM/yyyy').format(relatorio.dataInicio)} - ${DateFormat('dd/MM/yyyy').format(relatorio.dataFim)}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 20),
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildSummaryRow('Total de Receitas:', relatorio.totalReceitas, Colors.green),
                  _buildSummaryRow('Total de Despesas:', relatorio.totalDespesas, Colors.red),
                  Divider(),
                  _buildSummaryRow('Saldo Final:', relatorio.saldoFinal, relatorio.saldoFinal >= 0 ? Colors.blue : Colors.red),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Gastos por Categoria',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          if (relatorio.gastosPorCategoria.isEmpty)
            const Text('Nenhum gasto por categoria no período.')
          else
            ListView.builder(
              shrinkWrap: true, // Importante para ListView aninhado em Column/SingleChildScrollView
              physics: const NeverScrollableScrollPhysics(), // Desabilita scroll próprio
              itemCount: relatorio.gastosPorCategoria.length,
              itemBuilder: (context, index) {
                final entry = relatorio.gastosPorCategoria.entries.elementAt(index);
                return ListTile(
                  title: Text(entry.key),
                  trailing: Text(currencyFormatter.format(entry.value), style: const TextStyle(fontWeight: FontWeight.w600)),
                );
              },
            ),
          const SizedBox(height: 20),
          Text(
            'Evolução do Saldo (Em Desenvolvimento)',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          // TODO: Adicionar gráficos aqui quando a lógica de evolucaoSaldoPorPeriodo for implementada
          const Center(child: Text('Gráfico de evolução será exibido aqui.')),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double value, Color color) {
    final NumberFormat currencyFormatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(
            currencyFormatter.format(value),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}