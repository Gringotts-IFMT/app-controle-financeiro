class ConfiguracoesApp {
  bool modoEscuro;
  String idioma;
  bool notificacoesAtivas;
  double tamanhoFonte;
  bool sincronizacaoAutomatica;

  ConfiguracoesApp({
    required this.modoEscuro,
    required this.idioma,
    required this.notificacoesAtivas,
    required this.tamanhoFonte,
    required this.sincronizacaoAutomatica,
  });

  Map<String, dynamic> toMap() {
    return {
      'modoEscuro': modoEscuro,
      'idioma': idioma,
      'notificacoesAtivas': notificacoesAtivas,
      'tamanhoFonte': tamanhoFonte,
      'sincronizacaoAutomatica': sincronizacaoAutomatica,
    };
  }

  factory ConfiguracoesApp.fromMap(Map<String, dynamic> map) {
    return ConfiguracoesApp(
      modoEscuro: map['modoEscuro'] ?? false,
      idioma: map['idioma'] ?? 'pt',
      notificacoesAtivas: map['notificacoesAtivas'] ?? true,
      tamanhoFonte: (map['tamanhoFonte'] ?? 14.0).toDouble(),
      sincronizacaoAutomatica: map['sincronizacaoAutomatica'] ?? true,
    );
  }

  ConfiguracoesApp copyWith({
    bool? modoEscuro,
    String? idioma,
    bool? notificacoesAtivas,
    double? tamanhoFonte,
    bool? sincronizacaoAutomatica,
  }) {
    return ConfiguracoesApp(
      modoEscuro: modoEscuro ?? this.modoEscuro,
      idioma: idioma ?? this.idioma,
      notificacoesAtivas: notificacoesAtivas ?? this.notificacoesAtivas,
      tamanhoFonte: tamanhoFonte ?? this.tamanhoFonte,
      sincronizacaoAutomatica:
          sincronizacaoAutomatica ?? this.sincronizacaoAutomatica,
    );
  }
}
