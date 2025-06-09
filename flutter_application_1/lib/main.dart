import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'providers/meta_economia_provider.dart';
import 'providers/transacao_provider.dart';
import 'screens/expense_screen.dart';
import 'screens/income_screen.dart';
import 'screens/home_screen.dart'; // Adicione esta linha
import 'screens/metas_list_screen.dart';

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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TransacaoProvider()),
        ChangeNotifierProvider(create: (_) => MetaEconomiaProvider()),
      ],
      child: MaterialApp(
        title: 'Controle Financeiro',
        theme: ThemeData(
          primarySwatch: Colors.green,
          useMaterial3: true,
        ),
        home: const MainNavigator(), // Mudança aqui
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _currentIndex = 0;

  // Lista de telas
  final List<Widget> _screens = [
    const HomeScreen(), // Tela nova com saldo e lista completa
    const TabBarScreens(), // Suas telas antigas (Gastos/Ganhos)
    const MetasListScreen(), // Tela de metas
  ];

  @override
  void initState() {
    super.initState();
    // Carregar transações ao iniciar o app
    Future.microtask(() {
      Provider.of<TransacaoProvider>(context, listen: false)
          .carregarTransacoes();
    });
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
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Categorias',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.savings),
            label: 'Metas',
          ),
        ],
      ),
    );
  }
}

// Suas telas antigas em uma classe separada
class TabBarScreens extends StatefulWidget {
  const TabBarScreens({super.key});

  @override
  State<TabBarScreens> createState() => _TabBarScreensState();
}

class _TabBarScreensState extends State<TabBarScreens>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gastos e Ganhos'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.arrow_downward), text: 'Gastos'),
            Tab(icon: Icon(Icons.arrow_upward), text: 'Ganhos'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          ExpenseScreen(),
          IncomeScreen(),
        ],
      ),
    );
  }
}