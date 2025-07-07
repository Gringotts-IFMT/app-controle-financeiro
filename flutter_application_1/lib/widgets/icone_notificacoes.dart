import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/notificacoes_screen.dart';

class IconeNotificacoes extends StatelessWidget {
  const IconeNotificacoes({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox();

    final int idUsuario = user.uid.hashCode; // ou seu ID real

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('notificacoes')
          .where('idUsuario', isEqualTo: idUsuario)
          .where('lida', isEqualTo: false)
          .snapshots(),
      builder: (context, snapshot) {
        int totalNaoLidas = snapshot.data?.docs.length ?? 0;

        return Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NotificacoesScreen(),
                  ),
                );
              },
            ),
            if (totalNaoLidas > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints:
                      const BoxConstraints(minWidth: 20, minHeight: 20),
                  child: Text(
                    '$totalNaoLidas',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
