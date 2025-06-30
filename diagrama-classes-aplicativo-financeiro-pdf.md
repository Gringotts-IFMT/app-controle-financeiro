# Diagrama de Classes - Aplicativo de Controle Financeiro Pessoal

## Visão Geral do Sistema

Este documento apresenta o diagrama de classes UML para um aplicativo de controle financeiro pessoal, baseado nos requisitos especificados. O diagrama ilustra as principais entidades, seus atributos, métodos e relacionamentos, fornecendo uma visão estrutural completa do sistema.

## Diagrama de Classes UML

```mermaid
classDiagram
    class Usuario {
        -int id
        -String nome
        -String email
        -String senha
        -String tokenRecuperacao
        -Date dataCriacaoConta
        -Date ultimoAcesso
        -float saldoAtual
        -String fotoPerfil
        -ConfiguracoesApp configuracoes
        +cadastrarUsuario() boolean
        +autenticar(email, senha) boolean
        +recuperarSenha(email) boolean
        +alterarSenha(senhaAtual, novaSenha) boolean
        +editarPerfil(dadosPerfil) boolean
        +calcularSaldo() float
        +definirMetaEconomia(valor, mes) boolean
    }

    class Transacao {
        -int id
        -String descricao
        -float valor
        -Date data
        -TipoTransacao tipo
        -int idUsuario
        -int idCategoria
        +getValor() float
        +getTipo() TipoTransacao
        +getCategoria() Categoria
        +excluir() boolean
        +atualizar(dadosTransacao) boolean
    }

    class Categoria {
        -int id
        -String nome
        -String descricao
        -String icone
        -String cor
        -boolean padrao
        -int idUsuario
        +cadastrarCategoria() boolean
        +editarCategoria() boolean
        +removerCategoria() boolean
        +isCategoriaPadrao() boolean
        +getCategoriasPadroes() List~Categoria~
        +getCategoriasPorUsuario(idUsuario) List~Categoria~
    }

    class MetaEconomia {
        -int id
        -float valorMeta
        -float valorAtual
        -int idUsuario
        -Date dataCriacao
        -Date dataLimite
        -int mes
        -int ano
        +calcularProgresso() float
        +verificarCumprimento() boolean
        +atualizarMeta(novoValor) boolean
    }

    class Alerta {
        -int id
        -String titulo
        -String descricao
        -float limiteGasto
        -TipoAlerta tipo
        -int idCategoria
        -int idUsuario
        -boolean ativo
        +verificarLimite(valorGasto) boolean
        +notificarUsuario() boolean
        +desativar() boolean
        +ativar() boolean
    }

    class Relatorio {
        -int id
        -Date dataInicio
        -Date dataFim
        -TipoRelatorio tipo
        -int idUsuario
        -List~Transacao~ transacoes
        +gerarRelatorio() RelatorioDados
        +exportarPDF() File
        +exportarCSV() File
    }

    class Grafico {
        -TipoGrafico tipo
        -Date dataInicio
        -Date dataFim
        -int idUsuario
        -List~DadosGrafico~ dados
        +gerarGraficoPizza() Chart
        +gerarGraficoLinha() Chart
        +gerarGraficoBarra() Chart
    }

    class DadosGrafico {
        -String label
        -float valor
        -String cor
    }

    class BackupService {
        -int idUsuario
        -Date ultimoBackup
        +realizarBackup() boolean
        +restaurarBackup(arquivoBackup) boolean
        +agendarBackupAutomatico(intervalo) boolean
    }

    class SincronizacaoService {
        -int idUsuario
        -Date ultimaSincronizacao
        -boolean sincronizacaoAutomatica
        +sincronizarDados() boolean
        +verificarConexao() boolean
        +configurarSincronizacaoAutomatica(ativar) boolean
    }

    class ConfiguracoesApp {
        -boolean modoEscuro
        -String idioma
        -boolean notificacoesAtivas
        -TamanhoFonte tamanhoFonte
        -boolean sincronizacaoAutomatica
        +alterarTema(modoEscuro) boolean
        +alterarIdioma(idioma) boolean
        +configurarNotificacoes(ativar) boolean
        +alterarTamanhoFonte(tamanho) boolean
    }

    class NotificacaoService {
        -int idUsuario
        -List~Notificacao~ notificacoes
        +enviarNotificacao(mensagem, tipo) boolean
        +marcarComoLida(idNotificacao) boolean
        +excluirNotificacao(idNotificacao) boolean
        +listarNotificacoes() List~Notificacao~
    }

    class Notificacao {
        -int id
        -String titulo
        -String mensagem
        -Date data
        -boolean lida
        -TipoNotificacao tipo
        -int idUsuario
    }

    class TipoTransacao {
        <<enumeration>>
        RECEITA
        DESPESA
    }

    class TipoNotificacao {
        <<enumeration>>
        META_ECONOMIA
        ALERTA_GASTO
        SISTEMA
    }

    class TipoAlerta {
        <<enumeration>>
        LIMITE_CATEGORIA
        ORCAMENTO_MENSAL
        GASTO_EXCESSIVO
    }

    class TipoGrafico {
        <<enumeration>>
        PIZZA
        LINHA
        BARRA
    }

    class TipoRelatorio {
        <<enumeration>>
        DIARIO
        SEMANAL
        MENSAL
        PERSONALIZADO
    }

    class TamanhoFonte {
        <<enumeration>>
        PEQUENO
        MEDIO
        GRANDE
        MUITO_GRANDE
    }

    class RepositorioTransacao {
        +salvar(transacao) Transacao
        +buscarPorId(id) Transacao
        +buscarPorUsuario(idUsuario) List~Transacao~
        +buscarPorPeriodo(idUsuario, inicio, fim) List~Transacao~
        +buscarPorCategoria(idCategoria) List~Transacao~
        +atualizar(transacao) boolean
        +remover(id) boolean
    }

    class RepositorioCategoria {
        +salvar(categoria) Categoria
        +buscarPorId(id) Categoria
        +buscarPorUsuario(idUsuario) List~Categoria~
        +buscarPadroes() List~Categoria~
        +atualizar(categoria) boolean
        +remover(id) boolean
    }
    
    Usuario "1" -- "0..*" Transacao : registra
    Usuario "1" -- "0..*" Categoria : personaliza
    Usuario "1" -- "0..*" MetaEconomia : define
    Usuario "1" -- "0..*" Alerta : configura
    Usuario "1" -- "1" ConfiguracoesApp : possui
    Transacao "0..*" -- "1" Categoria : pertence
    MetaEconomia -- NotificacaoService : notifica via
    Alerta -- NotificacaoService : envia através de
    RepositorioTransacao -- Transacao : gerencia
    RepositorioCategoria -- Categoria : gerencia
    BackupService -- Usuario : realiza backup para
    SincronizacaoService -- Usuario : sincroniza dados de
    Usuario -- NotificacaoService : recebe
    Relatorio -- Grafico : utiliza
    Grafico -- DadosGrafico : contém
    Relatorio -- Transacao : analisa
    NotificacaoService -- Notificacao : gerencia
```

## Descrição das Classes Principais

### Classes de Entidade
1. **Usuario**: Gerencia informações de perfil e autenticação do usuário.
2. **Transacao**: Representa as operações financeiras (receitas e despesas) do usuário.
3. **Categoria**: Define classificações para transações, podendo ser padrão ou personalizada.
4. **MetaEconomia**: Armazena objetivos financeiros estabelecidos pelo usuário.
5. **Alerta**: Configura notificações para controle de gastos.

### Classes de Serviço
1. **NotificacaoService**: Gerencia o sistema de notificações.
2. **BackupService**: Realiza operações de backup e restauração de dados.
3. **SincronizacaoService**: Sincroniza dados entre dispositivos e servidor.

### Repositórios
1. **RepositorioTransacao**: Persiste e recupera dados de transações.
2. **RepositorioCategoria**: Persiste e recupera dados de categorias.

### Visualização e Configuração
1. **Relatorio**: Gera relatórios financeiros customizáveis.
2. **Grafico**: Cria visualizações gráficas dos dados financeiros.
3. **ConfiguracoesApp**: Armazena preferências do usuário.

### Enumerações
1. **TipoTransacao**: Define tipos de transação (RECEITA, DESPESA).
2. **TipoNotificacao**: Classifica as notificações do sistema.
3. **TipoAlerta**: Define tipos de alertas financeiros.
4. **TipoGrafico**: Especifica tipos de gráficos disponíveis.
5. **TipoRelatorio**: Define períodos para relatórios financeiros.
6. **TamanhoFonte**: Configura tamanhos de fonte da interface.

## Relacionamentos Principais

- Um usuário registra múltiplas transações (1:N)
- Um usuário personaliza múltiplas categorias (1:N)
- Cada transação pertence a uma categoria (N:1)
- Um usuário define múltiplas metas de economia (1:N)
- Um usuário configura múltiplos alertas (1:N)
- Um usuário possui uma configuração de aplicativo (1:1)

## Funcionalidades Implementadas

O diagrama contempla as seguintes funcionalidades do aplicativo:

1. **Autenticação de Usuários**: Login, cadastro e recuperação de senha
2. **Gestão de Transações**: Registro de receitas e despesas
3. **Categorização**: Criação e gestão de categorias personalizadas
4. **Análise Financeira**: Gráficos e relatórios
5. **Metas e Alertas**: Definição de objetivos e notificações de gastos
6. **Personalização**: Interface adaptável (modo claro/escuro)
7. **Segurança de Dados**: Backup e sincronização

---

Elaborado por: [Nome do Desenvolvedor: Cezarino M. Hora/Equipe: Grupo 01 - Cezarino, Eduarda, Laura e Guilherme]
Data: 13 de abril de 2025
