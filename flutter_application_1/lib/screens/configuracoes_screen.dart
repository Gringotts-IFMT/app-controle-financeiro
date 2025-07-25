import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/configuracoes_provider.dart';
import '../models/configuracoesApp.dart';

class ConfiguracoesScreen extends StatefulWidget {
  const ConfiguracoesScreen({super.key});

  @override
  State<ConfiguracoesScreen> createState() => _ConfiguracoesScreenState();
}

class _ConfiguracoesScreenState extends State<ConfiguracoesScreen> {
  @override
  void initState() {
    super.initState();
    // Carrega as configurações quando a tela é inicializada
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ConfiguracoesProvider>(context, listen: false)
          .carregarConfiguracoes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ConfiguracoesProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (provider.config == null) {
          return const Scaffold(
            body: Center(child: Text('Erro ao carregar configurações')),
          );
        }

        final config = provider.config!;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Configurações'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  _mostrarDialogReset(context);
                },
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Modo Escuro'),
                      subtitle: const Text('Ativar tema escuro'),
                      value: config.modoEscuro,
                      onChanged: (value) {
                        provider.atualizarConfiguracoes(
                          config.copyWith(modoEscuro: value),
                        );
                      },
                    ),
                    SwitchListTile(
                      title: const Text('Notificações Ativas'),
                      subtitle: const Text('Receber notificações do app'),
                      value: config.notificacoesAtivas,
                      onChanged: (value) {
                        provider.atualizarConfiguracoes(
                          config.copyWith(notificacoesAtivas: value),
                        );
                      },
                    ),
                    SwitchListTile(
                      title: const Text('Sincronização Automática'),
                      subtitle: const Text('Sincronizar dados automaticamente'),
                      value: config.sincronizacaoAutomatica,
                      onChanged: (value) {
                        provider.atualizarConfiguracoes(
                          config.copyWith(sincronizacaoAutomatica: value),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tamanho da Fonte',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Slider(
                        value: config.tamanhoFonte,
                        min: 10,
                        max: 24,
                        divisions: 7,
                        label: '${config.tamanhoFonte.toStringAsFixed(0)}pt',
                        onChanged: (value) {
                          provider.atualizarConfiguracoes(
                            config.copyWith(tamanhoFonte: value),
                          );
                        },
                      ),
                      Center(
                        child: Text(
                          'Texto de exemplo',
                          style: TextStyle(fontSize: config.tamanhoFonte),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Idioma',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: config.idioma,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12),
                        ),
                        onChanged: (value) {
                          if (value != null) {
                            provider.atualizarConfiguracoes(
                              config.copyWith(idioma: value),
                            );
                          }
                        },
                        items: const [
                          DropdownMenuItem(
                            value: 'pt',
                            child: Row(
                              children: [
                                Text('🇧🇷'),
                                SizedBox(width: 8),
                                Text('Português'),
                              ],
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'en',
                            child: Row(
                              children: [
                                Text('🇺🇸'),
                                SizedBox(width: 8),
                                Text('Inglês'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _mostrarDialogReset(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resetar Configurações'),
        content: const Text(
            'Tem certeza que deseja resetar todas as configurações para o padrão?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Provider.of<ConfiguracoesProvider>(context, listen: false)
                  .resetarConfiguracoes();
            },
            child: const Text('Resetar'),
          ),
        ],
      ),
    );
  }
}
