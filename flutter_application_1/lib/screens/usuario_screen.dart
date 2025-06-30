import 'package:flutter/material.dart';

class UsuarioPage extends StatelessWidget {
  const UsuarioPage({super.key});

  @override
  Widget build(BuildContext context) {
    const nome = 'João da Silva';
    const email = 'joao@email.com';
    const saldo = 1200.50;

    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              radius: 40,
              child: Icon(Icons.person, size: 40),
            ),
            const SizedBox(height: 16),
            Text('Nome: $nome', style: const TextStyle(fontSize: 18)),
            Text('Email: $email', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            Text('Saldo atual: R\$ ${saldo.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 18)),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}