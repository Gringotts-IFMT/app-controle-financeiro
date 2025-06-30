import '../models/usuario.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Importe o Firebase Auth
import 'package:cloud_firestore/cloud_firestore.dart'; // Importe o Firestore
import 'dart:convert'; // Já existia
import 'package:flutter/material.dart'; // Já existia, mas não é usado diretamente aqui, pode ser removido se não houver uso futuro



// Serviço para gerenciar usuários
class UsuarioService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

// Método para cadastrar um novo usuário no Firebase Authentication e no Firestore
  Future<User?> cadastrarUsuario(Usuario usuario) async {
    try {
      // 1. Criar o usuário no Firebase Authentication
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(  
        email: usuario.email,
        password: usuario.senha,
      );

      User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        // 2. Salvar dados adicionais do usuário no Firestore
        await _firestore.collection('users').doc(firebaseUser.uid).set({
          'nome': usuario.nome,
          'email': usuario.email,
          'dataCriacaoConta': Timestamp.fromDate(usuario.dataCriacaoConta),
          'ultimoAcesso': Timestamp.fromDate(usuario.ultimoAcesso),
          'saldoAtual': usuario.saldoAtual,
          'configuracoes': {
            'notificacoesAtivas': usuario.configuracoes.notificacoesAtivas,
            'idioma': usuario.configuracoes.idioma,
          },
        });
        print('Usuário ${usuario.email} cadastrado com sucesso!');
        return firebaseUser; // Retorna o usuário do Firebase
      }
    } on FirebaseAuthException catch (e) {
      print('Erro ao cadastrar usuário: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      print('Erro desconhecido ao cadastrar usuário: $e');
      rethrow;
    }
    return null; // Caso algo dê errado e não seja uma FirebaseAuthException
  }

  // Método para autenticar um usuário usando Firebase Authentication
  Future<User?> autenticar(String email, String senha) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: senha,
      );
      print('Usuário $email autenticado com sucesso!');
      return userCredential.user; // Retorna o usuário do Firebase
    } on FirebaseAuthException catch (e) {
      print('Erro de autenticação: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      print('Erro desconhecido na autenticação: $e');
      rethrow;
    }
  }

  // Método para alterar a senha do usuário (usando Firebase)
  Future<bool> recuperarSenha(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      print('Email de recuperação de senha enviado para $email');
      return true;
    } on FirebaseAuthException catch (e) {
      print('Erro ao recuperar senha: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      print('Erro desconhecido na recuperação de senha: $e');
      rethrow;
    }
  }

// Método para editar o perfil do usuário
  Future<bool> editarPerfil(Usuario usuario) async {
    try {
      // Atualiza os dados do usuário no Firestore
      await _firestore.collection('users').doc(usuario.id.toString()).update({
        'nome': usuario.nome,
        'email': usuario.email,
        'configuracoes': {
          'notificacoesAtivas': usuario.configuracoes.notificacoesAtivas,
          'idioma': usuario.configuracoes.idioma,
        },
      });
      print('Perfil do usuário ${usuario.email} atualizado com sucesso!');
      return true;
    } catch (e) {
      print('Erro ao editar perfil: $e');
      return false;
    }
  }

// Método para buscar dados adicionais do usuário no Firestore
  Future<Usuario?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return  Usuario.fromFirestore(
            doc.data() as Map<String, dynamic>, doc.id);
      }
    } catch (e) {
      print('Erro ao buscar dados do usuário: $e');
      // Opcional: rethrow e para tratamento de erro na UI
    }
    return null;
  }

   User? getCurrentUserFirebase() {
    // Renomeado para evitar conflito com seu modelo Usuario
    return _auth.currentUser;
  }

  //método para sair do sistema
  Future<void> logout() async {
    try {
      await _auth.signOut();
      print('Usuário deslogado com sucesso!');
    } catch (e) {
      print('Erro ao deslogar: $e');
      rethrow;
    }
  }

}
