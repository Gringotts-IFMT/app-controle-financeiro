import 'package:cloud_firestore/cloud_firestore.dart';

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
    if (senha == senhaAtual) {
      senha = novaSenha;
      return true;
    }
    return false;
  }

  bool editarPerfil(Map<String, dynamic> dadosPerfil) {
    if (dadosPerfil.containsKey('nome')) nome = dadosPerfil['nome'];
    if (dadosPerfil.containsKey('fotoPerfil')) {
      fotoPerfil = dadosPerfil['fotoPerfil'];
    }
    return true;
  }

  double calcularSaldo() => saldoAtual;

  bool definirMetaEconomia(double valor, int mes) {
    // Simulação: apenas imprime a meta
    print(
        'Meta destatic Future<Usuario?> fromFirestore(Map<String, dynamic> data, String id) {}finida: $valor para id mês $mes');
    return true;
  }

  //
  static Future<Usuario?> fromFirestoreData(
      Map<String, dynamic> data, String id) async {
        return null;
      }

  factory Usuario.fromFirestore(
      Map<String, dynamic> firestoreData, String uid) {
    // Certifique-se de que 'saldoAtual' é tratado como num para double, e 'configuracoes' é acessado com segurança
    return Usuario(
      id: int.tryParse(uid.hashCode.toString()) ??
          0, // Convertendo UID para int, use 0 como fallback
      nome: firestoreData['nome'] ?? 'Nome não disponível',
      email: firestoreData['email'] ?? '',
      senha: '', // Senha nunca deve ser lida do Firestore
      dataCriacaoConta:
          (firestoreData['dataCriacaoConta'] as Timestamp).toDate(),
      ultimoAcesso: (firestoreData['ultimoAcesso'] as Timestamp).toDate(),
      saldoAtual: (firestoreData['saldoAtual'] as num?)?.toDouble() ?? 0.0,
      fotoPerfil: firestoreData['fotoPerfil'],
      configuracoes: ConfiguracoesApp(
        notificacoesAtivas:
            firestoreData['configuracoes']?['notificacoesAtivas'] ?? true,
        idioma: firestoreData['configuracoes']?['idioma'] ?? 'pt',
      ),
    );
  }
}
