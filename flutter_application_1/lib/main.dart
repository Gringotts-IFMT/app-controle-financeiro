import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/expense_screen.dart';
import 'screens/income_screen.dart';

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
                _index == 1 ? 'Relatórios' : 'Perfil do Usuário',
              ),
            ),
      body: _index == 0
          ? TabBarView(
              controller: _tabController,
              children: const [
                ExpenseScreen(),
                IncomeScreen(),
              ],
            )
          : Center(
              child: Text(
                _index == 1
                    ? 'Tela de Relatórios (em construção)'
                    : 'Tela de Perfil do Usuário (em construção)',
                style: const TextStyle(fontSize: 18),
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
