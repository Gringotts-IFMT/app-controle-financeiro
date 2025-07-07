import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'
    as firebase_auth; // Alias para evitar conflitos

// Classe para configurações do aplicativo (se for salvar no Firestore junto com o usuário)
class ConfiguracoesApp {
  bool notificacoesAtivas;
  String idioma;

  ConfiguracoesApp({
    required this.notificacoesAtivas,
    required this.idioma,
  });

  // Convertendo ConfiguracoesApp para Map (para Firestore)
  Map<String, dynamic> toMap() {
    return {
      'notificacoesAtivas': notificacoesAtivas,
      'idioma': idioma,
    };
  }

  // Criando ConfiguracoesApp a partir de Map (do Firestore)
  factory ConfiguracoesApp.fromMap(Map<String, dynamic>? map) {
    // Usar 'map?' para lidar com caso de 'configuracoes' ser nulo no Firestore
    return ConfiguracoesApp(
      notificacoesAtivas: map?['notificacoesAtivas'] ?? true, // Padrão: ativas
      idioma: map?['idioma'] ?? 'pt_BR', // Padrão: português
    );
  }
}

class Usuario {
  final String id; // Este será o UID do Firebase Auth (String, não int)
  final String nome;
  final String email;
  final String? fotoPerfil;
  final DateTime dataCriacaoConta;
  final DateTime ultimoAcesso;
  final double
      saldoAtual; // Este saldo será calculado com base nas transações do Firestore, não armazenado diretamente aqui. Pode ser zero por padrão no perfil.
  final ConfiguracoesApp configuracoes; // Usando a classe ConfiguracoesApp

  Usuario({
    required this.id,
    required this.nome,
    required this.email,
    this.fotoPerfil,
    required this.dataCriacaoConta,
    required this.ultimoAcesso,
    this.saldoAtual = 0.0, // Valor padrão inicial
    ConfiguracoesApp? configuracoes, // Pode ser opcional, com um padrão
  }) : configuracoes = configuracoes ??
            ConfiguracoesApp(notificacoesAtivas: true, idioma: 'pt_BR');

  // NENHUM CAMPO 'SENHA' AQUI. O Firebase Auth lida com isso.
  // NENHUM MÉTODO 'autenticar', 'alterarSenha' AQUI. O Firebase Auth lida com isso.

  // --- CONSTRUTORES DE FÁBRICA E MÉTODOS PARA FIREBASE ---

  // Construtor de fábrica para criar um Usuario a partir de um Firebase User (do pacote firebase_auth)
  // Usado quando um usuário faz login/registro e você quer criar um objeto Usuario a partir dos dados básicos do Firebase Auth
  factory Usuario.fromFirebaseUser(firebase_auth.User user) {
    return Usuario(
      id: user.uid,
      nome: user.displayName ??
          user.email!.split(
              '@')[0], // Tenta pegar displayName, senão usa parte do email
      email: user.email!,
      fotoPerfil: user.photoURL,
      dataCriacaoConta: user.metadata.creationTime ?? DateTime.now(),
      ultimoAcesso: user.metadata.lastSignInTime ?? DateTime.now(),
      saldoAtual: 0.0, // Este será atualizado ou calculado dinamicamente
      configuracoes: ConfiguracoesApp(
          notificacoesAtivas: true,
          idioma: 'pt_BR'), // Padrão ao criar do Firebase User
    );
  }

  // Construtor de fábrica para criar um Usuario a partir de um DocumentSnapshot do Firestore
  // Usado para ler dados de perfil do usuário da coleção 'users' no Firestore
  factory Usuario.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final map = doc.data()!; // Pega os dados do documento
    return Usuario(
      id: doc
          .id, // O ID do documento no Firestore é o UID do usuário do Firebase Auth
      nome: map['nome'] ?? '',
      email: map['email'] ?? '',
      fotoPerfil: map['fotoPerfil'],
      dataCriacaoConta:
          (map['dataCriacaoConta'] as Timestamp?)?.toDate() ?? DateTime.now(),
      ultimoAcesso:
          (map['ultimoAcesso'] as Timestamp?)?.toDate() ?? DateTime.now(),
      saldoAtual: (map['saldoAtual'] as num?)?.toDouble() ?? 0.0,
      configuracoes: ConfiguracoesApp.fromMap(
          map['configuracoes'] as Map<String, dynamic>?),
    );
  }

  // Método para converter o objeto Usuario para um Map (para salvar/atualizar no Firestore)
  // Este é o 'toFirestore' que será usado para a coleção 'users'
  Map<String, dynamic> toFirestore() {
    return {
      'nome': nome,
      'email': email,
      'fotoPerfil': fotoPerfil,
      'dataCriacaoConta': Timestamp.fromDate(dataCriacaoConta),
      'ultimoAcesso': Timestamp.fromDate(ultimoAcesso),
      'saldoAtual':
          saldoAtual, // Pode ser removido se for sempre calculado dinamicamente
      'configuracoes': configuracoes.toMap(),
    };
  }

  // Método copyWith para facilitar a criação de cópias modificadas (útil para edição de perfil)
  Usuario copyWith({
    String? id,
    String? nome,
    String? email,
    String? fotoPerfil,
    DateTime? dataCriacaoConta,
    DateTime? ultimoAcesso,
    double? saldoAtual,
    ConfiguracoesApp? configuracoes,
  }) {
    return Usuario(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      email: email ?? this.email,
      fotoPerfil: fotoPerfil ?? this.fotoPerfil,
      dataCriacaoConta: dataCriacaoConta ?? this.dataCriacaoConta,
      ultimoAcesso: ultimoAcesso ?? this.ultimoAcesso,
      saldoAtual: saldoAtual ?? this.saldoAtual,
      configuracoes: configuracoes ?? this.configuracoes,
    );
  }

  @override
  String toString() {
    return 'Usuario{id: $id, nome: $nome, email: $email, saldoAtual: $saldoAtual}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Usuario &&
        other.id == id; // Comparar pelo ID (UID do Firebase)
  }

  @override
  int get hashCode => id.hashCode;

  // Métodos como calcularSaldo, definirMetaEconomia, etc., NÃO devem estar aqui.
  // calcularSaldo deve ser feito no TransacaoProvider ou um BalanceService
  // definirMetaEconomia é uma ação do MetaEconomiaProvider/Service
}
