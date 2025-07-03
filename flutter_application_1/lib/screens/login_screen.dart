import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core_web/firebase_core_web.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira seu email.';
    }
    if (!value.contains('@') || !value.contains('.')) {
      return 'Email inválido.';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira sua senha.';
    }
    if (value.length < 6) {
      return 'A senha deve ter pelo menos 6 caracteres.';
    }
    return null;
  }

  Future<void> _signIn() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
        // Login bem-sucedido: Navegar para a tela inicial
        Navigator.of(context).pushReplacementNamed('/home');
      } on FirebaseAuthException catch (e) {
        String message;
        if (e.code == 'user-not-found') {
          message = 'Nenhum usuário encontrado para esse email.';
        } else if (e.code == 'wrong-password') {
          message = 'Senha incorreta para esse email.';
        } else {
          message = 'Erro ao fazer login. Tente novamente.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
        // Registro bem-sucedido: Navegar para a tela inicial ou exibir mensagem
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Conta criada com sucesso!')),
        );
        Navigator.of(context).pushReplacementNamed('/home');
      } on FirebaseAuthException catch (e) {
        String message;
        if (e.code == 'weak-password') {
          message = 'A senha fornecida é muito fraca.';
        } else if (e.code == 'email-already-in-use') {
          message = 'O email já está em uso por outra conta.';
        } else {
          message = 'Erro ao criar conta. Tente novamente.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // AGORA VOCÊ PEGA A COR PRIMÁRIA DIRETAMENTE DO TEMA CONFIGURADO NO MAIN.DART
    final primaryColorFromTheme = Theme.of(context).colorScheme.primary; 

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // --- LOGO DO APP ---
                Image.asset(
                  'assets/images/logo.png',
                  height: 200,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 8),

                // Título de boas-vindas
                Text(
                  'Bem-vindo(a)!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: primaryColorFromTheme, // <--- USANDO A COR DO TEMA AQUI
                  ),
                ),
                const SizedBox(height: 30),

                // Campo de Email
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'exemplo@email.com',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    prefixIcon: Icon(Icons.email, color: primaryColorFromTheme), // <--- USANDO A COR DO TEMA AQUI
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  validator: _validateEmail,
                ),
                const SizedBox(height: 20),

                // Campo de Senha
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    hintText: 'Mínimo de 6 caracteres',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    prefixIcon: Icon(Icons.lock, color: primaryColorFromTheme), // <--- USANDO A COR DO TEMA AQUI
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  validator: _validatePassword,
                ),
                const SizedBox(height: 30),

                // Botão de Entrar
                _isLoading
                    ? CircularProgressIndicator(color: primaryColorFromTheme) // <--- USANDO A COR DO TEMA AQUI
                    : ElevatedButton(
                        onPressed: _signIn,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 55),
                          backgroundColor: primaryColorFromTheme, // <--- USANDO A COR DO TEMA AQUI
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 5,
                        ),
                        child: const Text(
                          'Entrar',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                
                const SizedBox(height: 15),

                // Botão de Registro
                TextButton(
                  onPressed: _signUp,
                  child: Text(
                    'Não tem uma conta? Registre-se',
                    style: TextStyle(color: primaryColorFromTheme), // <--- USANDO A COR DO TEMA AQUI
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}