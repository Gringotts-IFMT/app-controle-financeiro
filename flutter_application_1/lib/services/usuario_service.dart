// lib/services/usuario_service.dart (OU lib/services/auth_service.dart se preferir um nome mais específico)
import 'package:firebase_auth/firebase_auth.dart'; // Para autenticação Firebase
import 'package:cloud_firestore/cloud_firestore.dart'; // Para salvar/ler dados do perfil
import 'package:flutter/material.dart'; // Para ChangeNotifier (se este serviço for um provider)
import '../Models/usuario.dart'; // Importa a classe Usuario (já atualizada para Firebase)

// Este serviço pode ser um ChangeNotifier se você quiser que outras partes da UI escutem mudanças no usuário
class UsuarioService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Usuario? _currentAppUser; // Objeto Usuario do seu modelo (com nome, foto, configs, etc.)

  Usuario? get currentAppUser => _currentAppUser;

  // Construtor: Opcional, pode inicializar o listener do Auth aqui
  UsuarioService() {
    _auth.authStateChanges().listen((firebaseUser) async {
      if (firebaseUser != null) {
        // Se há um usuário logado no Firebase Auth, tenta carregar o perfil do Firestore
        _currentAppUser = await _getUserProfileFromFirestore(firebaseUser.uid);
        if (_currentAppUser == null) {
          // Se o perfil não existe no Firestore (primeiro login/registro), cria um perfil básico
          _currentAppUser = Usuario.fromFirebaseUser(firebaseUser);
          await _saveUserProfileToFirestore(_currentAppUser!);
        }
      } else {
        _currentAppUser = null; // Nenhum usuário logado
      }
      notifyListeners(); // Notifica a UI sobre a mudança no usuário
    });
  }

  // Método para registrar um novo usuário com Email e Senha (Firebase Auth)
  Future<UserCredential?> signUpWithEmailAndPassword(String email, String password, String name) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Após o registro no Auth, crie um perfil básico no Firestore
      if (userCredential.user != null) {
        final newAppUser = Usuario.fromFirebaseUser(userCredential.user!);
        // Tenta atualizar o displayName imediatamente
        await userCredential.user!.updateDisplayName(name);
        await _saveUserProfileToFirestore(newAppUser.copyWith(nome: name)); // Salva com o nome fornecido
        _currentAppUser = newAppUser.copyWith(nome: name); // Atualiza o estado local
      }
      return userCredential;
    } catch (e) {
      print('Erro ao registrar usuário: $e');
      rethrow; // Relança o erro para ser tratado na UI (LoginScreen)
    }
  }

  // Método para fazer login com Email e Senha (Firebase Auth)
  Future<UserCredential?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Se o login for bem-sucedido, carrega o perfil do Firestore
      if (userCredential.user != null) {
        _currentAppUser = await _getUserProfileFromFirestore(userCredential.user!.uid);
        if (_currentAppUser == null) {
           // Isso pode acontecer se o perfil foi excluído ou nunca foi criado corretamente
           // Criar um perfil básico se não encontrar (ou redirecionar para tela de completude de perfil)
           _currentAppUser = Usuario.fromFirebaseUser(userCredential.user!);
           await _saveUserProfileToFirestore(_currentAppUser!);
        }
      }
      return userCredential;
    } catch (e) {
      print('Erro ao fazer login: $e');
      rethrow;
    }
  }

  // Método para fazer logout (Firebase Auth)
  Future<void> signOut() async {
    await _auth.signOut();
    _currentAppUser = null; // Limpa o usuário local
    notifyListeners();
  }

  // Método para recuperar senha (Firebase Auth)
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Erro ao enviar email de recuperação: $e');
      rethrow;
    }
  }

  // Método para salvar/atualizar o perfil do usuário no Firestore
  Future<void> _saveUserProfileToFirestore(Usuario user) async {
    try {
      await _firestore.collection('users').doc(user.id).set(user.toFirestore());
      _currentAppUser = user; // Atualiza o estado local após salvar
      notifyListeners();
    } catch (e) {
      print('Erro ao salvar perfil do usuário no Firestore: $e');
      rethrow;
    }
  }

  // Método para carregar o perfil do usuário do Firestore
  Future<Usuario?> _getUserProfileFromFirestore(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return Usuario.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>);
      }
      return null;
    } catch (e) {
      print('Erro ao carregar perfil do usuário do Firestore: $e');
      return null;
    }
  }

  // Método para atualizar informações do perfil (ex: nome, foto)
  Future<void> updateProfile(String name, String? photoUrl) async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      try {
        if (name != firebaseUser.displayName) {
          await firebaseUser.updateDisplayName(name);
        }
        if (photoUrl != null && photoUrl != firebaseUser.photoURL) {
          await firebaseUser.updatePhotoURL(photoUrl);
        }
        // Atualiza o perfil no Firestore
        final updatedAppUser = _currentAppUser!.copyWith(
          nome: name,
          fotoPerfil: photoUrl,
        );
        await _saveUserProfileToFirestore(updatedAppUser);
      } catch (e) {
        print('Erro ao atualizar perfil: $e');
        rethrow;
      }
    }
  }

  // Você pode adicionar outros métodos relacionados ao usuário aqui, como:
  // - deleteUserAccount()
  // - updateEmail()
}