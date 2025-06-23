import '../models/usuario.dart';

// Serviço para gerenciar usuários
class UsuarioService {
  final List<Usuario> _usuarios = [];

// Método para cadastrar um novo usuário
  bool cadastrarUsuario(Usuario usuario) {
    if (_usuarios.any((u) => u.email == usuario.email)) return false;
    _usuarios.add(usuario);
    return true;
  }

  // Método para autenticar um usuário
  // Retorna o usuário se as credenciais estiverem corretas, ou null caso contrário
  Usuario? autenticar(String email, String senha) {
    try {
      return _usuarios.firstWhere(
        (u) => u.email == email && u.senha == senha,
      );
    } catch (e) {
      return null;
    }
  }

  // Método para alterar a senha do usuário
  bool recuperarSenha(String email) {
    final user = _usuarios.where((u) => u.email == email).isNotEmpty
        ? _usuarios.firstWhere((u) => u.email == email)
        : null;
    if (user != null) {
      user.tokenRecuperacao = 'TOKEN123'; // Simulação
      return true;
    }
    return false;
  }

  List<Usuario> listarUsuarios() => _usuarios;
}
