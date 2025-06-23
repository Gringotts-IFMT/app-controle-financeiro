// ignore_for_file: unnecessary_this, curly_braces_in_flow_control_structures

class ConfiguracoesApp {
  bool notificacoesAtivas;
  String idioma;

  ConfiguracoesApp({
    required this.notificacoesAtivas,
    required this.idioma,
  });
}

class Usuario {
  int id;
  String nome;
  String email;
  String senha;
  String? tokenRecuperacao;
  DateTime dataCriacaoConta;
  DateTime ultimoAcesso;
  double saldoAtual;
  String? fotoPerfil;
  ConfiguracoesApp configuracoes;

  Usuario({
    required this.id,
    required this.nome,
    required this.email,
    required this.senha,
    required this.dataCriacaoConta,
    required this.ultimoAcesso,
    required this.saldoAtual,
    this.tokenRecuperacao,
    this.fotoPerfil,
    required this.configuracoes,
  });

  bool autenticar(String email, String senha) {
    return this.email == email && this.senha == senha;
  }

  bool alterarSenha(String senhaAtual, String novaSenha) {
    if (this.senha == senhaAtual) {
      this.senha = novaSenha;
      return true;
    }
    return false;
  }

  bool editarPerfil(Map<String, dynamic> dadosPerfil) {
    if (dadosPerfil.containsKey('nome')) nome = dadosPerfil['nome'];
    if (dadosPerfil.containsKey('fotoPerfil'))
      fotoPerfil = dadosPerfil['fotoPerfil'];
    return true;
  }

  double calcularSaldo() => saldoAtual;

  bool definirMetaEconomia(double valor, int mes) {
    // Simulação: apenas imprime a meta
    print('Meta definida: $valor para o mês $mes');
    return true;
  }
}
