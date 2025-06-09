import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transacao_provider.dart';
import '../enums/tipo_transacao.dart';
import 'transacao_form_screen.dart';
import '../models/transaction.dart';
import 'metas_list_screen.dart';



class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Controle Financeiro'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Consumer<TransacaoProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              // Card de Saldo
              _buildSaldoCard(provider),
              
              // Lista de Transações
              Expanded(
                child: _buildTransacoesList(provider),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TransacaoFormScreen()),
          );
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSaldoCard(TransacaoProvider provider) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.green, Colors.lightGreen],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Text(
            'Saldo Atual',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'R\$ ${provider.saldoTotal.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSaldoItem(
                'Receitas', 
                provider.getTotalPorTipo(TipoTransacao.receita),
                TipoTransacao.receita.icone,
              ),
              _buildSaldoItem(
                'Despesas', 
                provider.getTotalPorTipo(TipoTransacao.despesa),
                TipoTransacao.despesa.icone,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSaldoItem(String label, double valor, String icone) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icone, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(color: Colors.white70)),
          ],
        ),
        Text(
          'R\$ ${valor.toStringAsFixed(2)}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildTransacoesList(TransacaoProvider provider) {
    if (provider.transacoes.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Nenhuma transação encontrada'),
            SizedBox(height: 8),
            Text('Toque no + para adicionar uma transação'),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: provider.transacoes.length,
      itemBuilder: (context, index) {
        final transacao = provider.transacoes[index];
        final tipo = _getTipoFromAmount(transacao.value);
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: tipo.cor.withOpacity(0.1),
              child: Text(tipo.icone, style: const TextStyle(fontSize: 20)),
            ),
            title: Text(transacao.description),
            subtitle: Text('${transacao.category} • ${_formatarData(transacao.date)}'),
            trailing: Text(
              '${_getTipoFromAmount(transacao.value) == TipoTransacao.receita ? '+' : '-'} R\$ ${transacao.value.abs().toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _getTipoFromAmount(transacao.value).cor,
              ),
            ),
            onTap: () {
              // Aqui você pode adicionar ação ao tocar na transação
              // Por exemplo, editar ou ver detalhes
            },
          ),
        );
      },
    );
  }

  String _formatarData(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';
  }

  TipoTransacao _getTipoFromAmount(double amount) {
    return amount >= 0 ? TipoTransacao.receita : TipoTransacao.despesa;
  }
}