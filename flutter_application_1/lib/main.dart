import 'package:controle_financeiro/widgets/icone_notificacoes.dart';
import 'package:controle_financeiro/providers/relatorio_provider.dart';
import 'package:controle_financeiro/providers/configuracoes_provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'providers/meta_economia_provider.dart';
import 'providers/transacao_provider.dart';

import 'screens/home_screen.dart';
import 'screens/metas_list_screen.dart';
import 'screens/login_screen.dart';
import 'screens/categoria_screen.dart';
import 'screens/relatorio_screen.dart';
import 'screens/configuracoes_screen.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
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
        ChangeNotifierProvider(create: (_) => RelatorioProvider()),
        ChangeNotifierProvider(create: (_) => ConfiguracoesProvider()),
      ],
      child: Consumer<ConfiguracoesProvider>(
        builder: (context, configProvider, child) {
          return MaterialApp(
            title: 'Controle Financeiro',
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF132C33),
                primary: const Color(0xFF132C33),
                onPrimary: Colors.white,
                brightness: Brightness.light,
              ),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF132C33),
                primary: const Color(0xFF132C33),
                onPrimary: Colors.white,
                brightness: Brightness.dark,
              ),
            ),
            themeMode: configProvider.config?.modoEscuro == true
                ? ThemeMode.dark
                : ThemeMode.light,
            home: StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                } else if (snapshot.hasData && snapshot.data != null) {
                  final uid = snapshot.data!.uid;
                  // Salva o UID anterior em uma variável estática
                  // e compara para garantir que é um novo login
                  // (evita reuso de dados do usuário anterior)
                  // ignore: prefer_const_declarations
                  const lastUidKey = 'lastUid';
                  // ignore: prefer_const_declarations
                  final storage = PageStorage.of(context);
                  final lastUid =
                      storage.readState(context, identifier: lastUidKey);
                  if (lastUid != uid) {
                    // Limpa os providers
                    Provider.of<TransacaoProvider>(context, listen: false)
                        .limparDados();
                    Provider.of<MetaEconomiaProvider>(context, listen: false)
                        .limparDados();
                    Provider.of<RelatorioProvider>(context, listen: false)
                        .limparDados();
                    Provider.of<ConfiguracoesProvider>(context, listen: false)
                        .limparDados();
                    // Salva o novo UID
                    storage.writeState(context, uid, identifier: lastUidKey);
                  }
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Provider.of<TransacaoProvider>(context, listen: false)
                        .carregarTransacoes();
                    Provider.of<MetaEconomiaProvider>(context, listen: false)
                        .inicializarListener();
                    Provider.of<ConfiguracoesProvider>(context, listen: false)
                        .carregarConfiguracoes();
                  });
                  return MainNavigator(key: ValueKey(uid));
                } else {
                  return const LoginScreen();
                }
              },
            ),
            debugShowCheckedModeBanner: false,
            routes: {
              '/login': (context) => const LoginScreen(),
              '/home': (context) => const MainNavigator(),
              '/metas': (context) => const MetasListScreen(),
              '/configuracoes': (context) => const ConfiguracoesScreen(),
            },
          );
        },
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

  final List<Widget> _screens = const [
    HomeScreen(),
    CategoriaScreen(),
    MetasListScreen(),
    RelatorioScreen(),
    ConfiguracoesScreen(), // Adicionada a tela de configurações
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Controle Financeiro'),
        actions: const [
          IconeNotificacoes(),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor:
            Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Categorias',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.savings),
            label: 'Metas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Relatórios',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Configurações',
          ),
        ],
      ),
    );
  }
}
