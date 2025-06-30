import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/meta_economia_provider.dart';
import '../models/meta_economia.dart';
import '../enums/status_meta_economia.dart';
import 'package:intl/intl.dart';
import 'package:controle_financeiro/screens/meta_form_screen.dart'; // Importa a tela do formulário de meta
import 'package:firebase_auth/firebase_auth.dart'; // <--- Adicionado: Para obter o userId

class MetasListScreen extends StatefulWidget {
  const MetasListScreen({Key? key}) : super(key: key);

  @override
  State<MetasListScreen> createState() => _MetasListScreenState();
}

class _MetasListScreenState extends State<MetasListScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final NumberFormat _currencyFormatter = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // REMOVIDO: A inicialização do listener do provider deve ser feita no main.dart
    // APÓS o login do usuário, para garantir que o userId esteja disponível.
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   final provider = Provider.of<MetaEconomiaProvider>(context, listen: false);
    //   provider.inicializarListener();
    // });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Metas de Economia',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green[600],
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Todas'),
            Tab(text: 'Ativas'),
            Tab(text: 'Concluídas'),
            Tab(text: 'Vencidas'),
          ],
        ),
      ),
      body: Consumer<MetaEconomiaProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.metas.isEmpty) { // Mostra loading apenas se estiver carregando e a lista estiver vazia
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.erro != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Erro ao carregar metas',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    provider.erro!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      provider.limparErro();
                      provider.carregarMetas(); // Tenta recarregar
                    },
                    child: const Text('Tentar Novamente'),
                  ),
                ],
              ),
            );
          }

          // Se não há loading, não há erro, mas a lista está vazia
          if (provider.metas.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.savings_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhuma meta encontrada',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Adicione uma nova meta para começar!',
                    style: TextStyle(
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Card de Resumo
              _buildResumoCard(provider),
              
              // Lista de Metas
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildMetasList(provider.metas),
                    _buildMetasList(provider.metasAtivas),
                    _buildMetasList(provider.metasConcluidas),
                    _buildMetasList(provider.metasVencidas),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navegar para tela de cadastro de nova meta
          _mostrarFormularioCadastroMeta(); // Chamando a função de navegação correta
        },
        backgroundColor: Colors.green[600],
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Nova Meta',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildResumoCard(MetaEconomiaProvider provider) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green[400]!, Colors.green[600]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildResumoItem(
                'Total Economizado',
                _currencyFormatter.format(provider.totalEconomizado),
                Icons.savings,
              ),
              _buildResumoItem(
                'Metas Ativas',
                provider.metasAtivas.length.toString(),
                Icons.flag,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildResumoItem(
                'Progresso Geral',
                '${provider.progressoGeralMetas.toStringAsFixed(1)}%',
                Icons.trending_up,
              ),
              _buildResumoItem(
                'Concluídas',
                provider.metasConcluidas.length.toString(),
                Icons.check_circle,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResumoItem(String titulo, String valor, IconData icone) {
    return Column(
      children: [
        Icon(icone, color: Colors.white, size: 24),
        const SizedBox(height: 4),
        Text(
          valor,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          titulo,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildMetasList(List<MetaEconomia> metas) {
    if (metas.isEmpty) {
      // Este caso já é tratado pelo Consumer se provider.metas.isEmpty no build principal
      // mas mantido para clareza dentro das abas
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.savings_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhuma meta encontrada',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Adicione uma nova meta para começar!',
              style: TextStyle(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: metas.length,
      itemBuilder: (context, index) {
        final meta = metas[index];
        return _buildMetaCard(meta);
      },
    );
  }

  Widget _buildMetaCard(MetaEconomia meta) {
    final Color statusColor = _getStatusColor(meta.status);
    final IconData statusIcon = _getStatusIcon(meta.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          // Navegar para detalhes da meta
          _mostrarDetalhes(meta);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          meta.titulo,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (meta.descricao.isNotEmpty)
                          Text(
                            meta.descricao,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 16, color: statusColor),
                        const SizedBox(width: 4),
                        Text(
                          meta.status.descricao,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Progresso
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _currencyFormatter.format(meta.valorAtual),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[600],
                    ),
                  ),
                  Text(
                    'de ${_currencyFormatter.format(meta.valorMeta)}',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Barra de progresso
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: meta.porcentagemProgresso / 100,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    meta.metaAtingida ? Colors.green : Colors.blue,
                  ),
                  minHeight: 8,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Informações adicionais
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${meta.porcentagemProgresso.toStringAsFixed(1)}% concluído',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  if (meta.status == StatusMetaEconomia.ativa)
                    Text(
                      meta.diasRestantes > 0
                          ? '${meta.diasRestantes} dias restantes'
                          : 'Vencida',
                      style: TextStyle(
                        color: meta.metaVencida ? Colors.red : Colors.grey[600],
                        fontSize: 12,
                        fontWeight: meta.metaVencida ? FontWeight.w500 : FontWeight.normal,
                      ),
                    ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Botões de ação
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _adicionarValor(meta),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Adicionar'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.green[600],
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _editarMeta(meta),
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Editar'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.blue[600],
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) => _executarAcao(value, meta),
                    itemBuilder: (context) => [
                      if (meta.status == StatusMetaEconomia.ativa)
                        const PopupMenuItem(
                          value: 'pausar',
                          child: Row(
                            children: [
                              Icon(Icons.pause, size: 16),
                              SizedBox(width: 8),
                              Text('Pausar'),
                            ],
                          ),
                        ),
                      if (meta.status == StatusMetaEconomia.pausada)
                        const PopupMenuItem(
                          value: 'reativar',
                          child: Row(
                            children: [
                              Icon(Icons.play_arrow, size: 16),
                              SizedBox(width: 8),
                              Text('Reativar'),
                            ],
                          ),
                        ),
                      const PopupMenuItem(
                        value: 'excluir',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 16, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Excluir', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    child: const Icon(Icons.more_vert, size: 20),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(StatusMetaEconomia status) {
    switch (status) {
      case StatusMetaEconomia.ativa:
        return Colors.blue;
      case StatusMetaEconomia.pausada:
        return Colors.orange;
      case StatusMetaEconomia.concluida:
        return Colors.green;
      case StatusMetaEconomia.cancelada:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(StatusMetaEconomia status) {
    switch (status) {
      case StatusMetaEconomia.ativa:
        return Icons.flag;
      case StatusMetaEconomia.pausada:
        return Icons.pause;
      case StatusMetaEconomia.concluida:
        return Icons.check_circle;
      case StatusMetaEconomia.cancelada:
        return Icons.cancel;
    }
  }

  void _mostrarDetalhes(MetaEconomia meta) {
    // Implementar navegação para detalhes
    print('Mostrar detalhes da meta: ${meta.titulo}');
    // Exemplo: Navigator.of(context).push(MaterialPageRoute(builder: (context) => MetaDetailScreen(meta: meta)));
  }

  void _mostrarFormularioCadastroMeta() { // Renomeada para ser mais clara
    print('Mostrar formulário de cadastro');
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const MetaFormScreen(), // Para adicionar nova meta
      ),
    );
  }

  void _adicionarValor(MetaEconomia meta) {
    showDialog(
      context: context,
      builder: (context) => _AdicionarValorDialog(meta: meta),
    );
  }

  void _editarMeta(MetaEconomia meta) {
    print('Editar meta: ${meta.titulo}');
    // NAVEGAR PARA A TELA DE EDIÇÃO PASSANDO A META
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MetaFormScreen(meta: meta), // Passa a meta para o formulário
      ),
    );
  }

  void _executarAcao(String acao, MetaEconomia meta) async {
    final provider = Provider.of<MetaEconomiaProvider>(context, listen: false);
    
    switch (acao) {
      case 'pausar':
        await provider.pausarMeta(meta.id!);
        break;
      case 'reativar':
        await provider.reativarMeta(meta.id!);
        break;
      case 'excluir':
        _confirmarExclusao(meta);
        break;
    }
  }

  void _confirmarExclusao(MetaEconomia meta) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Tem certeza que deseja excluir a meta "${meta.titulo}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final provider = Provider.of<MetaEconomiaProvider>(context, listen: false);
              await provider.excluirMeta(meta.id!); // O provider já tem o userId interno
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}

class _AdicionarValorDialog extends StatefulWidget {
  final MetaEconomia meta;

  const _AdicionarValorDialog({required this.meta});

  @override
  State<_AdicionarValorDialog> createState() => _AdicionarValorDialogState();
}

class _AdicionarValorDialogState extends State<_AdicionarValorDialog> {
  final TextEditingController _valorController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Adicionar à ${widget.meta.titulo}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Valor atual: ${NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(widget.meta.valorAtual)}',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _valorController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Valor a adicionar',
              prefixText: 'R\$ ',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _adicionarValor,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Adicionar'),
        ),
      ],
    );
  }

  void _adicionarValor() async {
    final valorTexto = _valorController.text.replaceAll(',', '.');
    final valor = double.tryParse(valorTexto);

    if (valor == null || valor <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite um valor válido'), backgroundColor: Colors.red), // Adicionado cor para erro
      );
      return;
    }

    setState(() => _isLoading = true);

    final provider = Provider.of<MetaEconomiaProvider>(context, listen: false);
    final novoValor = widget.meta.valorAtual + valor;
    
    // CHAMADA CORRETA: O provider já obtém o userId internamente
    final sucesso = await provider.atualizarValorMeta(widget.meta.id!, novoValor);

    setState(() => _isLoading = false);

    if (sucesso) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Valor adicionado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao adicionar valor. Verifique sua conexão e login.'), // Mensagem mais útil
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}