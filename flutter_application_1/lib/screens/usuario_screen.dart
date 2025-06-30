import 'package:flutter/material.dart';
import 'package:controle_financeiro/models/usuario.dart'; // Importe o modelo Usuario
import 'package:controle_financeiro/services/usuario_service.dart'; // Importe o serviço
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:controle_financeiro/screens/login_screen.dart';

class UsuarioPage extends StatefulWidget {
  const UsuarioPage({super.key});

  @override
  State<UsuarioPage> createState() => _UsuarioPageState();
}

class _UsuarioPageState extends State<UsuarioPage> {
  Usuario? _usuario; // O objeto Usuario que será exibido
  bool _isLoading = true; // Para controlar o estado de carregamento
  String? _errorMessage; // Para exibir mensagens de erro

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Inicia o carregamento dos dados do usuário
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final fb_auth.User? firebaseUser = UsuarioService()
          .getCurrentUserFirebase(); // Obtém o usuário do Firebase Auth

      if (firebaseUser != null) {
        // Busca os dados adicionais do usuário no Firestore
        final Usuario? fetchedUser =
            await UsuarioService().getUserData(firebaseUser.uid);
        if (fetchedUser != null) {
          setState(() {
            _usuario = fetchedUser;
          });
        } else {
          setState(() {
            _errorMessage = 'Dados do usuário não encontrados no Bando de Dados.';
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Nenhum usuário logado.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao carregar dados do usuário: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil do Usuário'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator()) // Indicador de carregamento
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : _usuario == null
                  ? const Center(
                      child: Text(
                        'Nenhum dado de usuário disponível.',
                        style: TextStyle(fontSize: 18),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 40,
                            // Se tiver foto de perfil, use NetworkImage
                            // backgroundImage: _usuario!.fotoPerfil != null
                            //     ? NetworkImage(_usuario!.fotoPerfil!)
                            //     : null,
                            child: _usuario!.fotoPerfil == null
                                ? const Icon(Icons.person, size: 40)
                                : null, // Se tiver foto, o child é nulo para mostrar a imagem
                          ),
                          const SizedBox(height: 16),
                          Text('Nome: ${_usuario!.nome}',
                              style: const TextStyle(fontSize: 18)),
                          Text('Email: ${_usuario!.email}',
                              style: const TextStyle(fontSize: 18)),
                          const SizedBox(height: 16),
                          Text(
                            'Saldo atual: R\$ ${_usuario!.saldoAtual.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 18),
                          ),
                          const Spacer(),
                          // Exemplo de botão de logout
                          ElevatedButton(
                            onPressed: () async {
                              await UsuarioService().logout();
                              // Após o logout, navegue de volta para a tela de login
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (context) => const LoginScreen()),
                                (Route<dynamic> route) => false,
                              );
                            },
                            child: const Text('Sair'),
                          ),
                        ],
                      ),
                    ),
    );
  }
}
