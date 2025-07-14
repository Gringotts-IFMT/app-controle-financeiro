# GRINGOTTS

# Aplicativo de Controle Financeiro Pessoal

Este projeto visa desenvolver um **aplicativo de controle financeiro pessoal** robusto e intuitivo, focado em auxiliar usuários a gerenciar suas finanças de forma eficiente.

---

## Funcionalidades Principais

- **Autenticação de Usuários:** Sistema completo de login, cadastro, recuperação de senha e gerenciamento de perfil, garantindo a segurança e privacidade dos dados financeiros.
- **Gestão de Transações:** Permite o registro detalhado de **receitas e despesas** com descrição, valor, data, categoria e tipo. Inclui funcionalidades para edição, exclusão e visualização de resumos diários, semanais e mensais.
- **Categorização Personalizada:** Oferece a criação de **categorias personalizadas** de gastos, além de uma lista pré-definida, com opções de edição e filtro para uma organização flexível.
- **Análise Financeira:** Geração de **gráficos e relatórios** interativos (pizza, linha, barra) para visualizar a distribuição de gastos, evolução do saldo e comparação de receitas vs. despesas. Os relatórios podem ser exportados em PDF ou CSV.
- **Metas e Alertas:** Funcionalidade para **definir metas de economia** e receber **alertas para gastos excessivos** em categorias específicas, com notificações push para manter o usuário no controle.
- **Interface e Experiência do Usuário (UI/UX):** Design intuitivo e responsivo, com modo claro/escuro, visão geral do saldo na tela inicial e feedback visual para uma experiência de usuário aprimorada.
- **Sincronização e Armazenamento:** Utiliza **Firebase Firestore ou SQLite** para persistência de dados local e, opcionalmente, sincronização em tempo real entre dispositivos, além de função de backup.Aplicativo de Controle Financeiro Pessoal

Foram adicionados dois gráficos de pizza (Pie Chart) interativos:

**Gráfico de Gastos por Categoria:** Exibe o percentual das despesas agrupadas por categoria, facilitando a visualização dos principais focos de gastos do usuário.
**Gráfico de Receitas por Categoria:** Mostra a distribuição percentual do total das receitas por categoria, utilizando tons de verde para diferenciar das despesas.
Os gráficos utilizam a biblioteca fl_chart para visualização dinâmica e responsiva.

A tela de relatório agora apresenta ambos os gráficos, permitindo comparar rapidamente a distribuição de receitas e despesas por categoria.

O layout foi ajustado para exibir os gráficos junto ao relatório detalhado, proporcionando uma experiência visual mais rica e informativa.

Essas melhorias tornam a análise financeira mais intuitiva, permitindo ao usuário identificar facilmente onde está gastando e de onde vêm suas receitas.
