import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:controle_financeiro/screens/login_screen.dart';
import 'package:controle_financeiro/screens/usuario_screen.dart';
import 'package:controle_financeiro/screens/login_screen.dart';
import 'screens/expense_screen.dart';
import 'screens/income_screen.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Garante que o Flutter esteja inicializado antes de usar plugins.
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyC1fdQ6PaN2tegYOzMdijfyhwsgEbf_fCE",
      authDomain: "voltaic-racer-230700.firebaseapp.com",
      projectId: "voltaic-racer-230700",
      storageBucket: "voltaic-racer-230700.appspot.com",
      messagingSenderId: "375462470587",
      appId: "1:375462470587:web:a380d4325684168ff19a9e",
      measurementId: "G-ZQ3GQ9P0VM",
    ),
  ); // Inicializa o Firebase com as credenciais fornecidas.
  runApp(const MyApp()); 
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Controle Financeiro', // Título da aplicação.
      theme: ThemeData(
        primarySwatch:
            Colors.green, // Define a cor primária do tema como verde.
        useMaterial3: true, // Habilita o Material Design 3.
      ),
      // Define a LoginScreen como a tela inicial
      home: const LoginScreen(),
      // Define as rotas nomeadas para navegação
      routes: {
        '/home': (context) => const HomePage(), // Rota para a sua HomePage
        '/login': (context) => const LoginScreen(), // Rota para a tela de login
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _index =
      0; 

  @override
  void initState() {
    super.initState();
    // O TabController controla as abas de Gastos e Ganhos
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _index == 0 
          ? AppBar(
              centerTitle: true,
              title: const Text('Controle Financeiro'),
              bottom: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(
                    icon: Icon(Icons.arrow_downward),
                    text: 'Gastos',
                  ),
                  Tab(
                    icon: Icon(Icons.arrow_upward),
                    text: 'Ganhos',
                  ),
                ],
              ),
            )
          : AppBar(
              title: Text(
                _index == 1
                    ? 'Relatórios'
                    : 'Perfil do Usuário', // Título baseado no índice
              ),
            ),
      body: _index == 0 // Exibe a TabBarView se o índice for 0
          ? TabBarView(
              controller: _tabController,
              children: const [
                ExpenseScreen(),
                IncomeScreen(),
              ],
            )
          : _index == 1 // Se for a aba de Relatórios
              ? const Center(
                  child: Text(
                    'Tela de Relatórios (em construção)',
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : _index == 2 // Se for a aba de Perfil do Usuário
                  ? const UsuarioPage() // Exibe a UsuarioPage
                  : const Center(
                      child: Text(
                        'Página não encontrada',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (int newIndex) {
          setState(() {
            _index = newIndex;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart),
            label: 'Relatórios',
          ),
          NavigationDestination(
            icon: Icon(Icons.person),
            label: 'Perfil do Usuário',
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
