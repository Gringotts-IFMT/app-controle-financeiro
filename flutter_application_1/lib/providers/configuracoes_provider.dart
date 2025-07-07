import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/configuracoesApp.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ConfiguracoesProvider with ChangeNotifier {
  ConfiguracoesApp? _config;
  bool _isLoading = false;
  bool _isInitialized = false;

  ConfiguracoesApp? get config => _config;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;

  final _firestore = FirebaseFirestore.instance;

  Future<void> carregarConfiguracoes() async {
    if (_isInitialized) return; // Evita carregar múltiplas vezes

    _setLoading(true);
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      _setLoading(false);
      return;
    }

    try {
      final doc = await _firestore.collection('configuracoes').doc(uid).get();
      if (doc.exists) {
        _config = ConfiguracoesApp.fromMap(doc.data()!);
      } else {
        _config = ConfiguracoesApp(
          modoEscuro: false,
          idioma: 'pt',
          notificacoesAtivas: true,
          tamanhoFonte: 14.0,
          sincronizacaoAutomatica: true,
        );
        await salvarConfiguracoes();
      }
      _isInitialized = true;
    } catch (e) {
      // Em caso de erro, usar configurações padrão
      _config = ConfiguracoesApp(
        modoEscuro: false,
        idioma: 'pt',
        notificacoesAtivas: true,
        tamanhoFonte: 14.0,
        sincronizacaoAutomatica: true,
      );
      _isInitialized = true;
    }
    _setLoading(false);
  }

  Future<void> salvarConfiguracoes() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || _config == null) return;

    try {
      await _firestore
          .collection('configuracoes')
          .doc(uid)
          .set(_config!.toMap(), SetOptions(merge: true));
    } catch (e) {
      // Silenciosamente falha se não conseguir salvar
      debugPrint('Erro ao salvar configurações: $e');
    }
    notifyListeners();
  }

  void atualizarConfiguracoes(ConfiguracoesApp novaConfig) {
    _config = novaConfig;
    notifyListeners(); // Notifica ANTES de salvar para mudança imediata na UI
    salvarConfiguracoes(); // Salva em background
  }

  void resetarConfiguracoes() {
    _config = ConfiguracoesApp(
      modoEscuro: false,
      idioma: 'pt',
      notificacoesAtivas: true,
      tamanhoFonte: 14.0,
      sincronizacaoAutomatica: true,
    );
    notifyListeners();
    salvarConfiguracoes(); // Salva em background
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
