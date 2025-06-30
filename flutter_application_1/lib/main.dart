import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/expense_screen.dart';
import 'screens/income_screen.dart';
import 'screens/Categoria/screen.categoria.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Controle Financeiro',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      home: const HomePage(),
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
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  // Função para retornar o título da AppBar baseado no índice
  String _getAppBarTitle() {
    switch (_index) {
      case 0:
        return 'Controle Financeiro';
      case 1:
        return 'Relatórios';
      case 2:
        return 'Perfil do Usuário';
      case 3:
        return 'Categorias';
      default:
        return 'Controle Financeiro';
    }
  }

  // Função para retornar o corpo da tela baseado no índice
  Widget _getBody() {
    switch (_index) {
      case 0:
        return TabBarView(
          controller: _tabController,
          children: const [
            ExpenseScreen(),
            IncomeScreen(),
          ],
        );
      case 1:
        return const Center(
          child: Text(
            'Tela de Relatórios (em construção)',
            style: TextStyle(fontSize: 18),
          ),
        );
      case 2:
        return const Center(
          child: Text(
            'Tela de Perfil do Usuário (em construção)',
            style: TextStyle(fontSize: 18),
          ),
        );
      case 3:
        return const CategoriaScreen(); // Aqui é onde sua tela de categoria será exibida
      default:
        return const Center(
          child: Text(
            'Tela não encontrada',
            style: TextStyle(fontSize: 18),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(_getAppBarTitle()),
        // Só mostra as abas quando estiver na tela Home (índice 0)
        bottom: _index == 0
            ? TabBar(
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
              )
            : null,
      ),
      body: _getBody(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (int newIndex) {
          setState(() {
            _index = newIndex;
          });
          // Se clicar no botão de categoria (índice 3), abre a tela de categorias
          if (newIndex == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CategoriaScreen(),
              ),
            );
          }
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
          NavigationDestination(
            icon: Icon(Icons.category),
            label: 'Categorias',
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
