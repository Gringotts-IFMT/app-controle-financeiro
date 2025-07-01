import 'package:controle_financeiro/providers/relatorio_provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart'; // <--- Adicionado: Importar Firebase Auth

import 'providers/meta_economia_provider.dart';
import 'providers/transacao_provider.dart';
import 'providers/relatorio_provider.dart';

import 'screens/home_screen.dart';
import 'screens/metas_list_screen.dart';
import 'screens/login_screen.dart'; // <--- Adicionado: Importar sua tela de login
import 'screens/categoria_screen.dart';
import 'screens/relatorio_screen.dart';

import 'firebase_options.dart'; // <--- Nova linha de importação

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // <--- Use esta linha!
  );
  runApp(const MyApp());
}

// ... o restante do seu código (MyApp, MainNavigator, TabBarScreens) continua o mesmo.
// O StreamBuilder em MyApp.build() já está configurado para o fluxo de login.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TransacaoProvider()),
        ChangeNotifierProvider(create: (_) => MetaEconomiaProvider()),
        ChangeNotifierProvider(create: (_) => RelatorioProvider()), // <--- Adicionado: Provider para Categorias
        // Adicione outros providers aqui, como CategoriaService, UsuarioService, se eles também usarem ChangeNotifier
      ],
      child: MaterialApp(
        title: 'Controle Financeiro',
        theme: ThemeData(
          primarySwatch: Colors.green,
          useMaterial3: true,
        ),
        // A GRANDE MUDANÇA ESTÁ AQUI: Usar StreamBuilder para verificar o estado de autenticação
        home: StreamBuilder<User?>(
          // Escuta por mudanças no usuário logado
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Mostra um indicador de carregamento enquanto espera o estado de autenticação
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            } else if (snapshot.hasData && snapshot.data != null) {
              // Se o usuário está logado (snapshot.hasData e snapshot.data não são nulos)
              // Inicializa os listeners dos providers AGORA, pois o userId está disponível
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Provider.of<TransacaoProvider>(context, listen: false)
                    .carregarTransacoes();
                Provider.of<MetaEconomiaProvider>(context, listen: false)
                    .inicializarListener();
                // Outros listeners/carregamentos que dependem do userId
              });
              return const MainNavigator(); // Redireciona para sua navegação principal
            } else {
              // Se não há usuário logado (snapshot.hasData é false ou snapshot.data é null)
              return const LoginScreen(); // Redireciona para a tela de login
            }
          },
        ),
        debugShowCheckedModeBanner: false,
        // ROTAS NOMEADAS (OPCIONAL, mas útil para navegação sem parâmetros)
        routes: {
          '/login': (context) => const LoginScreen(),
          '/home': (context) =>
              const MainNavigator(), // Ou se MainNavigator for sua home principal
          '/metas': (context) => const MetasListScreen(),
          // Adicione rotas para MetaFormScreen e TransacaoFormScreen se você estiver usando Navigator.pushNamed
          // '/meta-form': (context) => const MetaFormScreen(),
          // '/transacao-form': (context) => const TransacaoFormScreen(),
        },
      ),
    );
  }
}

// Mantenha MainNavigator e TabBarScreens como estão
class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _currentIndex = 0;

  // Lista de telas para a BottomNavigationBar
  final List<Widget> _screens = const [ // <--- MUITO IMPORTANTE: Usar 'const' se as telas forem const
    HomeScreen(),          // A nova HomeScreen com abas de transações/gastos/ganhos
    CategoriaScreen(),     // <--- A tela de Categorias real do Guilherme
    MetasListScreen(),     // Sua tela de metas
    RelatorioScreen(),     // Sua tela de relatórios
  ];

  @override
  void initState() {
    super.initState();
    // Chamadas de carregamento já estão no StreamBuilder do MyApp
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: Colors.white, // Define a cor de fundo da barra (pode ser qualquer cor)
        selectedItemColor: Colors.green[700], // Cor do item selecionado
        unselectedItemColor: Colors.grey[600], // Cor dos itens não selecionados
        type: BottomNavigationBarType.fixed, // Necessário quando há 4 ou mais itens
        showUnselectedLabels: true, // Mostra o texto dos itens não selecionados
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category), // Ícone de categoria
            label: 'Categorias',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.savings),
            label: 'Metas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart), // Ícone de relatório
            label: 'Relatórios',
          ),
        ],
      ),
    );
  }
}




