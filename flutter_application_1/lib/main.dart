import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/expense_screen.dart';
import 'screens/income_screen.dart';
// ignore: unused_import
import 'models/transaction.dart';
// ignore: unused_import
import 'package:cloud_firestore/cloud_firestore.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
