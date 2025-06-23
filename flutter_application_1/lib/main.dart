// main.dart
import 'package:controle_financeiro/screens/usuario_screen.dart';
import 'package:flutter/material.dart'; // Importa o pacote Flutter Material Design para construir a UI.
import 'package:firebase_core/firebase_core.dart'; // Importa o Firebase Core para inicialização do Firebase.
import 'screens/expense_screen.dart'; // Importa a tela de despesas.
import 'screens/income_screen.dart'; // Importa a tela de ganhos.
import 'services/usuario_service.dart'; // Importa o serviço de usuário para autenticação.

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
  runApp(const MyApp()); // Inicia a aplicação Flutter.
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
      home:
          const LoginPage(), // Define LoginPage como a tela inicial da aplicação.
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() =>
      _LoginPageState(); // Cria o estado para a LoginPage.
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController =
      TextEditingController(); // Controlador para o campo de email.
  final TextEditingController _passwordController =
      TextEditingController(); // Controlador para o campo de senha.
  final UsuarioPage _usuarioService =
      UsuarioPage(); // Instância do serviço de usuário para autenticação.

  void _login() async {
    final email = _emailController.text; // Obtém o texto do campo de email.
    final password =
        _passwordController.text; // Obtém o texto do campo de senha.

    // Autentica o usuário usando o UsuarioService.
    final user = _usuarioService.autenticar(email,
        password); // Chama o método de autenticação do serviço de usuário.

    if (user != null) {
      // Se a autenticação for bem-sucedida, navega para a HomePage, substituindo a tela atual.
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else {
      // Exibe uma mensagem de erro se as credenciais forem inválidas.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Credenciais inválidas')),
      );
    }
  }

  void _signup() {
    // Por simplicidade, uma mensagem é exibida. Em um aplicativo real, isso navegaria para uma tela de cadastro.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Funcionalidade de cadastro será implementada.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'), // Título da barra de aplicativos.
        centerTitle: true, // Centraliza o título.
      ),
      body: Padding(
        padding: const EdgeInsets.all(
            16.0), // Adiciona preenchimento ao redor do corpo.
        child: Column(
          mainAxisAlignment: MainAxisAlignment
              .center, // Centraliza os elementos na coluna verticalmente.
          children: [
            TextField(
              controller: _emailController, // Associa o controlador de email.
              decoration: const InputDecoration(
                labelText: 'Email', // Rótulo do campo de texto.
                border: OutlineInputBorder(), // Borda do campo de texto.
              ),
              keyboardType:
                  TextInputType.emailAddress, // Tipo de teclado para email.
            ),
            const SizedBox(height: 16), // Espaçamento vertical.
            TextField(
              controller:
                  _passwordController, // Associa o controlador de senha.
              decoration: const InputDecoration(
                labelText: 'Senha', // Rótulo do campo de texto.
                border: OutlineInputBorder(), // Borda do campo de texto.
              ),
              obscureText: true, // Oculta o texto para senhas.
            ),
            const SizedBox(height: 24), // Espaçamento vertical.
            ElevatedButton(
              onPressed:
                  _login, // Chama a função _login quando o botão é pressionado.
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(
                    50), // Define a altura mínima do botão.
              ),
              child: const Text('Entrar'), // Texto do botão.
            ),
            const SizedBox(height: 16), // Espaçamento vertical.
            TextButton(
              onPressed:
                  _signup, // Chama a função _signup quando o botão é pressionado.
              child: const Text('Criar uma nova conta'), // Texto do botão.
            ),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() =>
      _HomePageState(); // Cria o estado para a HomePage.
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController; // Controlador para as abas.
  int _index = 0; // Índice da aba selecionada na barra de navegação inferior.

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: 2, vsync: this); // Inicializa o TabController com 2 abas.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _index == 0 // Verifica se o índice é 0 (aba Home/Gastos/Ganhos).
          ? AppBar(
              centerTitle: true, // Centraliza o título.
              title: const Text(
                  'Controle Financeiro'), // Título da barra de aplicativos.
              bottom: TabBar(
                controller: _tabController, // Associa o TabController.
                tabs: const [
                  Tab(
                    icon: Icon(Icons.arrow_downward), // Ícone para gastos.
                    text: 'Gastos', // Texto da aba.
                  ),
                  Tab(
                    icon: Icon(Icons.arrow_upward), // Ícone para ganhos.
                    text: 'Ganhos', // Texto da aba.
                  ),
                ],
              ),
            )
          : AppBar(
              title: Text(
                _index == 1
                    ? 'Relatórios'
                    : 'Perfil do Usuário', // Título baseado no índice.
              ),
            ),
      body: _index == 0 // Exibe a TabBarView se o índice for 0.
          ? TabBarView(
              controller: _tabController, // Associa o TabController.
              children: const [
                ExpenseScreen(), // Tela de despesas.
                IncomeScreen(), // Tela de ganhos.
              ],
            )
          : Center(
              child: Text(
                _index == 1
                    ? 'Tela de Relatórios (em construção)' // Mensagem para a tela de relatórios.
                    : 'Tela de Perfil do Usuário (em construção)', // Mensagem para a tela de perfil.
                style: const TextStyle(fontSize: 18), // Estilo do texto.
              ),
            ),
      bottomNavigationBar: NavigationBar(
        selectedIndex:
            _index, // Define o item selecionado na barra de navegação.
        onDestinationSelected: (int newIndex) {
          setState(() {
            _index = newIndex; // Atualiza o índice selecionado.
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home), // Ícone para Home.
            label: 'Home', // Rótulo para Home.
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart), // Ícone para Relatórios.
            label: 'Relatórios', // Rótulo para Relatórios.
          ),
          NavigationDestination(
            icon: Icon(Icons.person), // Ícone para Perfil.
            label: 'Perfil do Usuário', // Rótulo para Perfil do Usuário.
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose(); // Libera os recursos do TabController.
    super.dispose();
  }
}
