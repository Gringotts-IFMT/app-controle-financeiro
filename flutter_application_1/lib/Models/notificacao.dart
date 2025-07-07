enum TipoNotificacao {
  sistema,
  lembrete,
  alerta,
}

class Notificacao {
  int id;
  String titulo;
  String mensagem;
  DateTime data;
  bool lida;
  TipoNotificacao tipo;
  int idUsuario;

  Notificacao({
    required this.id,
    required this.titulo,
    required this.mensagem,
    required this.data,
    required this.lida,
    required this.tipo,
    required this.idUsuario,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'mensagem': mensagem,
      'data': data.toIso8601String(),
      'lida': lida,
      'tipo': tipo.name,
      'idUsuario': idUsuario,
    };
  }

  factory Notificacao.fromMap(Map<String, dynamic> map) {
    return Notificacao(
      id: map['id'],
      titulo: map['titulo'],
      mensagem: map['mensagem'],
      data: DateTime.parse(map['data']),
      lida: map['lida'] ?? false,
      tipo: TipoNotificacao.values.firstWhere(
        (e) => e.name == map['tipo'],
        orElse: () => TipoNotificacao.sistema,
      ),
      idUsuario: map['idUsuario'],
    );
  }
}
