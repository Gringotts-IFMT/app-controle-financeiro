import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/meta_economia.dart'; // Ajuste o caminho para usar 'models' (minúsculo)
import '../../providers/meta_economia_provider.dart'; // Ajuste o caminho se necessário
import '../../enums/status_meta_economia.dart'; // Importe o enum de status
import 'package:intl/intl.dart'; // Para formatação de datas.
import 'package:firebase_auth/firebase_auth.dart'; // <--- Adicionado: Importar Firebase Auth

class MetaFormScreen extends StatefulWidget {
  final MetaEconomia?
      meta; // A meta pode ser nula (para adicionar) ou preenchida (para editar)

  const MetaFormScreen({super.key, this.meta});

  @override
  State<MetaFormScreen> createState() => _MetaFormScreenState();
}

class _MetaFormScreenState extends State<MetaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  final TextEditingController _valorMetaController = TextEditingController();

  DateTime? _dataInicioSelecionada;
  DateTime? _dataFimSelecionada;
  String?
      _periodoSelecionado; // Ex: 'Diário', 'Semanal', 'Mensal', 'Anual', 'Personalizado'
  StatusMetaEconomia? _statusSelecionado;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.meta != null) {
      // Se estamos editando, preencher os controladores e as variáveis de estado
      _tituloController.text = widget.meta!.titulo;
      _descricaoController.text = widget.meta!.descricao;
      _valorMetaController.text = widget.meta!.valorMeta.toStringAsFixed(2);
      _dataInicioSelecionada = widget.meta!.dataInicio;
      _dataFimSelecionada = widget.meta!.dataFim;
      _periodoSelecionado =
          widget.meta!.periodo; // <--- Inicializa o período para edição
      _statusSelecionado = widget.meta!.status;
    } else {
      // Valores padrão para uma nova meta
      _dataInicioSelecionada = DateTime.now();
      _dataFimSelecionada = DateTime.now()
          .add(const Duration(days: 30)); // Exemplo: meta de 1 mês para frente
      _periodoSelecionado = 'Mensal'; // Período padrão
      _statusSelecionado = StatusMetaEconomia.ativa; // Status padrão
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    _valorMetaController.dispose();
    super.dispose();
  }

  Future<void> _selecionarData(BuildContext context,
      {required bool isStartDate}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? (_dataInicioSelecionada ?? DateTime.now())
          : (_dataFimSelecionada ??
              DateTime.now().add(const Duration(days: 30))),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      helpText:
          isStartDate ? 'Selecione a Data de Início' : 'Selecione a Data Final',
      cancelText: 'Cancelar',
      confirmText: 'Confirmar',
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.green[600]!, // Cor primária do seletor de data
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
            dialogTheme: DialogThemeData(backgroundColor: Colors.white),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _dataInicioSelecionada = picked;
        } else {
          _dataFimSelecionada = picked;
        }
      });
    }
  }

  Future<void> _salvarMeta() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final provider =
          Provider.of<MetaEconomiaProvider>(context, listen: false);

      final titulo = _tituloController.text.trim();
      final descricao = _descricaoController.text.trim();
      final valorMeta =
          double.tryParse(_valorMetaController.text.replaceAll(',', '.'));

      // --- Obtenção do userId do Firebase Auth ---
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      if (currentUserId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Erro: Usuário não logado. Faça login novamente.'),
              backgroundColor: Colors.red),
        );
        setState(() => _isLoading = false);
        return;
      }
      // -------------------------------------------

      // Validações adicionais
      if (valorMeta == null || valorMeta <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Por favor, insira um valor da meta válido e maior que zero.'),
              backgroundColor: Colors.red),
        );
        setState(() => _isLoading = false);
        return;
      }
      if (_dataInicioSelecionada == null || _dataFimSelecionada == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Por favor, selecione as datas de início e fim.'),
              backgroundColor: Colors.red),
        );
        setState(() => _isLoading = false);
        return;
      }
      if (_dataFimSelecionada!.isBefore(_dataInicioSelecionada!)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('A data final não pode ser anterior à data inicial.'),
              backgroundColor: Colors.red),
        );
        setState(() => _isLoading = false);
        return;
      }
      if (_periodoSelecionado == null || _periodoSelecionado!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Por favor, selecione o período da meta.'),
              backgroundColor: Colors.red),
        );
        setState(() => _isLoading = false);
        return;
      }
      if (_statusSelecionado == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Por favor, selecione o status da meta.'),
              backgroundColor: Colors.red),
        );
        setState(() => _isLoading = false);
        return;
      }

      try {
        if (widget.meta == null) {
          // Criando uma nova meta
          final novaMeta = MetaEconomia(
            id: null, // O Firebase irá gerar o ID para uma nova meta
            userId: currentUserId, // <--- Agora obtido do Firebase Auth
            titulo: titulo,
            descricao: descricao,
            valorMeta: valorMeta,
            valorAtual: 0.0, // Uma nova meta começa com valor atual zero
            dataInicio: _dataInicioSelecionada!,
            dataFim: _dataFimSelecionada!,
            periodo: _periodoSelecionado!,
            status: _statusSelecionado!,
          );
          await provider.adicionarMeta(novaMeta);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Meta adicionada com sucesso!'),
                backgroundColor: Colors.green),
          );
        } else {
          // Editando uma meta existente
          final metaAtualizada = widget.meta!.copyWith(
            // userId não é alterado na edição, pois a meta já pertence ao usuário
            titulo: titulo,
            descricao: descricao,
            valorMeta: valorMeta,
            // valorAtual não deve ser editado aqui
            dataInicio: _dataInicioSelecionada,
            dataFim: _dataFimSelecionada,
            periodo: _periodoSelecionado, // <--- Passa o período na atualização
            status: _statusSelecionado,
          );
          await provider.atualizarMeta(metaAtualizada);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Meta atualizada com sucesso!'),
                backgroundColor: Colors.green),
          );
        }
        Navigator.pop(context); // Volta para a tela anterior
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erro ao salvar meta: $e'),
              backgroundColor: Colors.red),
        );
        print('Erro ao salvar meta: $e'); // Para debug
      } finally {
        setState(
            () => _isLoading = false); // Desativa o indicador de carregamento
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.meta != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? "Editar Meta" : "Nova Meta"),
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _tituloController,
                decoration: const InputDecoration(labelText: "Título da Meta"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Por favor, informe o título da meta.";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descricaoController,
                decoration:
                    const InputDecoration(labelText: "Descrição (Opcional)"),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _valorMetaController,
                decoration:
                    const InputDecoration(labelText: "Valor da Meta (R\$)"),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Por favor, informe o valor da meta.";
                  }
                  final parsedValue =
                      double.tryParse(value.replaceAll(',', '.'));
                  if (parsedValue == null || parsedValue <= 0) {
                    return "Informe um valor numérico válido e maior que zero.";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Campo para Data de Início
              ListTile(
                title: Text(
                  _dataInicioSelecionada == null
                      ? 'Selecione a Data de Início'
                      : 'Início: ${DateFormat('dd/MM/yyyy').format(_dataInicioSelecionada!)}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selecionarData(context, isStartDate: true),
              ),
              const SizedBox(height: 8),

              // Campo para Data Final
              ListTile(
                title: Text(
                  _dataFimSelecionada == null
                      ? 'Selecione a Data Final'
                      : 'Fim: ${DateFormat('dd/MM/yyyy').format(_dataFimSelecionada!)}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selecionarData(context, isStartDate: false),
              ),
              const SizedBox(height: 16),

              // Dropdown para Período
              DropdownButtonFormField<String>(
                value: _periodoSelecionado,
                decoration: const InputDecoration(labelText: 'Período da Meta'),
                items: <String>[
                  'Diário',
                  'Semanal',
                  'Mensal',
                  'Anual',
                  'Personalizado'
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _periodoSelecionado = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, selecione o período da meta.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Dropdown para Status (se permitido editar o status)
              DropdownButtonFormField<StatusMetaEconomia>(
                value: _statusSelecionado,
                decoration: const InputDecoration(labelText: 'Status da Meta'),
                items:
                    StatusMetaEconomia.values.map((StatusMetaEconomia status) {
                  return DropdownMenuItem<StatusMetaEconomia>(
                    value: status,
                    child: Text(
                        status.descricao), // Usa o getter 'descricao' do enum
                  );
                }).toList(),
                onChanged: (StatusMetaEconomia? newValue) {
                  setState(() {
                    _statusSelecionado = newValue;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Por favor, selecione o status da meta.';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _isLoading
                    ? null
                    : _salvarMeta, // Desabilita o botão enquanto carrega
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.save, color: Colors.white),
                label: Text(
                  isEdit ? "Atualizar Meta" : "Cadastrar Meta",
                  style: const TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  minimumSize:
                      const Size.fromHeight(50), // Botão de largura total
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
