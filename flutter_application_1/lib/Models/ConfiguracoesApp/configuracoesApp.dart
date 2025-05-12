class ConfiguracoesUsuario {
  bool modoEscuro = false;
  String idioma = 'pt-BR';
  bool notificacoesAtivadas = true;
  double tamanhoFonte = 14.0;

  bool alterarTema(bool novoModoEscuro) {
    if (modoEscuro != novoModoEscuro) {
      modoEscuro = novoModoEscuro;
      return true;
    }
    return false;
  }

  bool alterarIdioma(String novoIdioma) {
    if (idioma != novoIdioma && novoIdioma.isNotEmpty) {
      idioma = novoIdioma;
      return true;
    }
    return false;
  }

  bool configurarNotificacoes(bool ativar) {
    if (notificacoesAtivadas != ativar) {
      notificacoesAtivadas = ativar;
      return true;
    }
    return false;
  }

  bool alterarTamanhoFonte(double novoTamanho) {
    if (novoTamanho >= 10.0 &&
        novoTamanho <= 30.0 &&
        tamanhoFonte != novoTamanho) {
      tamanhoFonte = novoTamanho;
      return true;
    }
    return false;
  }

  @override
  String toString() {
    return 'Tema escuro: $modoEscuro, Idioma: $idioma, Notificações: $notificacoesAtivadas, Tamanho da Fonte: $tamanhoFonte';
  }
}
