class Categoria {
  final String? id;
  final String nome;
  final String descricao;
  final String icon;
  final String cor;
  final bool padrao;
  final int? idUsuario;

  Categoria({
    this.id,
    required this.nome,
    required this.descricao,
    required this.icon,
    required this.cor,
    required this.padrao,
    this.idUsuario,
  });

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'descricao': descricao,
      'icon': icon,
      'cor': cor,
      'padrao': padrao,
      'idUsuario': idUsuario,
    };
  }

  factory Categoria.fromMap(Map<String, dynamic> map, String id) {
    return Categoria(
      id: id,
      nome: map['nome'] ?? '',
      descricao: map['descricao'] ?? '',
      icon: map['icon'] ?? 'category',
      cor: map['cor'] ?? '#2196F3',
      padrao: map['padrao'] ?? false,
      idUsuario: map['idUsuario'],
    );
  }

  Categoria copyWith({
    String? id,
    String? nome,
    String? descricao,
    String? icon,
    String? cor,
    bool? padrao,
    int? idUsuario,
  }) {
    return Categoria(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
      icon: icon ?? this.icon,
      cor: cor ?? this.cor,
      padrao: padrao ?? this.padrao,
      idUsuario: idUsuario ?? this.idUsuario,
    );
  }
}