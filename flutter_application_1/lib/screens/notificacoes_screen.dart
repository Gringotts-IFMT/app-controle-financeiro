import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/notificacao.dart';
import '../services/notificacao_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificacoesScreen extends StatelessWidget {
  const NotificacoesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Usuário não autenticado')),
      );
    }

    final int idUsuario = user.uid.hashCode; // substitua por ID real se tiver

    return Scaffold(
      appBar: AppBar(title: const Text('Notificações')),
      body: StreamBuilder<List<Notificacao>>(
        stream: NotificacaoService().getNotificacoes(idUsuario),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhuma notificação encontrada.'));
          }

          final notificacoes = snapshot.data!;
          return ListView.builder(
            itemCount: notificacoes.length,
            itemBuilder: (context, index) {
              final n = notificacoes[index];
              return ListTile(
                title: Text(n.titulo),
                subtitle: Text(n.mensagem),
                trailing: n.lida
                    ? const Icon(Icons.check, color: Colors.green)
                    : IconButton(
                        icon: const Icon(Icons.mark_email_read),
                        onPressed: () {
                          NotificacaoService().marcarComoLida(n.id);
                        },
                      ),
                leading: Icon(_iconPorTipo(n.tipo)),
                tileColor: n.lida ? Colors.grey[200] : null,
              );
            },
          );
        },
      ),
    );
  }

  IconData _iconPorTipo(TipoNotificacao tipo) {
    switch (tipo) {
      case TipoNotificacao.lembrete:
        return Icons.alarm;
      case TipoNotificacao.alerta:
        return Icons.warning;
      case TipoNotificacao.sistema:
        return Icons.notifications;
    }
  }
}
