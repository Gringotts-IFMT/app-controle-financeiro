import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Models/meta_economia.dart';
import '../../providers/meta_economia_provider.dart';

class MetaFormScreen extends StatefulWidget {
  final MetaEconomia? meta;

  const MetaFormScreen({super.key, this.meta});

  @override
  State<MetaFormScreen> createState() => _MetaFormScreenState();
}

class _MetaFormScreenState extends State<MetaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _titulo;
  late String _descricao;
  double _valorMeta = 0;
  double _valorAtual = 0;

  @override
  void initState() {
    super.initState();
    if (widget.meta != null) {
      _titulo = widget.meta!.titulo;
      _descricao = widget.meta!.descricao;
      _valorMeta = widget.meta!.valorMeta;
      _valorAtual = widget.meta!.valorAtual;
    } else {
      _titulo = '';
      _descricao = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.meta != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? "Editar Meta" : "Nova Meta")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _titulo,
                decoration: const InputDecoration(labelText: "Título"),
                onSaved: (value) => _titulo = value ?? '',
                validator: (value) =>
                    value!.isEmpty ? "Informe o título" : null,
              ),
              TextFormField(
                initialValue: _descricao,
                decoration: const InputDecoration(labelText: "Descrição"),
                onSaved: (value) => _descricao = value ?? '',
              ),
              TextFormField(
                initialValue: _valorMeta.toString(),
                decoration:
                    const InputDecoration(labelText: "Valor da Meta (R\$)"),
                keyboardType: TextInputType.number,
                onSaved: (value) => _valorMeta = double.tryParse(value!) ?? 0,
              ),
              TextFormField(
                initialValue: _valorAtual.toString(),
                decoration:
                    const InputDecoration(labelText: "Valor Atual (R\$)"),
                keyboardType: TextInputType.number,
                onSaved: (value) => _valorAtual = double.tryParse(value!) ?? 0,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _salvarMeta,
                child: Text(isEdit ? "Atualizar Meta" : "Cadastrar Meta"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _salvarMeta() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final provider =
          Provider.of<MetaEconomiaProvider>(context, listen: false);

      if (widget.meta == null) {
        final novaMeta = MetaEconomia.novaMeta(
          titulo: _titulo,
          descricao: _descricao,
          valorMeta: _valorMeta,
          valorAtual: _valorAtual,
        );
        provider.adicionarMeta(novaMeta);
      } else {
        final metaAtualizada = widget.meta!.copyWith(
          titulo: _titulo,
          descricao: _descricao,
          valorMeta: _valorMeta,
          valorAtual: _valorAtual,
        );
        provider.atualizarMeta(metaAtualizada);
      }

      Navigator.pop(context);
    }
  }
}
