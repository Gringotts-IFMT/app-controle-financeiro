import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/expense_screen.dart';
import 'screens/income_screen.dart';
import 'screens/usuario_screen.dart';

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
      routes: {
        '/usuario': (context) => const UsuarioPage(),
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
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
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

  /// AppBar dinâmica
  PreferredSizeWidget _buildAppBar() {
    if (_index == 0) {
      return AppBar(
        centerTitle: true,
        title: const Text('Controle Financeiro'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.arrow_downward), text: 'Gastos'),
            Tab(icon: Icon(Icons.arrow_upward), text: 'Ganhos'),
          ],
        ),
      );
    } else {
      return AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              _index = 0;
            });
          },
        ),
        title: Text(_index == 1 ? 'Relatórios' : 'Perfil do Usuário'),
      );
    }
  }

  /// Corpo da tela baseado no índice
  Widget _buildBody() {
    if (_index == 0) {
      return TabBarView(
        controller: _tabController,
        children: const [
          ExpenseScreen(),
          IncomeScreen(),
        ],
      );
    } else if (_index == 1) {
      return const Center(
        child: Text(
          'Tela de Relatórios (em construção)',
          style: TextStyle(fontSize: 18),
        ),
      );
    } else {
      return const UsuarioPage(); // Agora exibe a tela real
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
