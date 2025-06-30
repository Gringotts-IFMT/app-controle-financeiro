import 'dart:convert';
import '../models/usuario.dart';
import '../services/usuario_service.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart' as shelf_router;

final usuarioService = UsuarioService();

/// Rota para gerenciar usuários
shelf_router.Router usuarioRouter() {
  final router = shelf_router.Router();

  // Rota para listar todos os usuários
  router.post('/cadastrar', (Request req) async {
    final payload = jsonDecode(await req.readAsString());
    final novoUsuario = Usuario(
      id: DateTime.now().millisecondsSinceEpoch,
      nome: payload['nome'],
      email: payload['email'],
      senha: payload['senha'],
      dataCriacaoConta: DateTime.now(),
      ultimoAcesso: DateTime.now(),
      saldoAtual: 0.0,
      configuracoes: ConfiguracoesApp(
        notificacoesAtivas: true,
        idioma: 'pt',
      ),
    );

    final sucesso = usuarioService.cadastrarUsuario(novoUsuario);
    return Response.ok(jsonEncode({'sucesso': sucesso}));
  });

  // Rota para listar todos os usuários
  router.post('/login', (Request req) async {
    final payload = jsonDecode(await req.readAsString());
    final usuario =
        usuarioService.autenticar(payload['email'], payload['senha']);
    if (usuario != null) {
      return Response.ok(jsonEncode({'sucesso': true, 'nome': usuario.nome}));
    }
    return Response.forbidden(
        jsonEncode({'sucesso': false, 'mensagem': 'Credenciais inválidas'}));
  });

  // Rota para alterar a senha do usuário
  router.post('/recuperar-senha', (Request req) async {
    final payload = jsonDecode(await req.readAsString());
    final sucesso = usuarioService.recuperarSenha(payload['email']);
    return Response.ok(jsonEncode({'sucesso': sucesso}));
  });

  return router;
}
